
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "zesty-disk.sh"
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/user-data.sh", {
      api_key      = var.api_key
      mount_points = [for mount in var.disks : mount.mount_point]
    })
  }
}

resource "aws_iam_role" "this" {
  count       = var.enable_ssm ? 1 : 0
  name_prefix = "zesty-disk-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

resource "aws_iam_instance_profile" "this" {
  count       = var.enable_ssm ? 1 : 0
  name_prefix = "zesty-disk-instance-profile-"
  role        = aws_iam_role.this[0].id
}

resource "aws_instance" "this" {
  count                = var.managed_deployment ? 1 : 0
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  iam_instance_profile = try( aws_iam_instance_profile.this[0].name, var.iam_instance_profile)
  key_name             = try(var.key_pair)
  user_data            = data.cloudinit_config.config.rendered
  tags                 = var.tags

  dynamic "ebs_block_device" {
    for_each = var.disks
    content {
      device_name           = ebs_block_device.value.name
      volume_size           = ebs_block_device.value.size
      volume_type           = ebs_block_device.value.disk_type
      delete_on_termination = true
      tags = merge(var.ebs_tags, {
        ZestyDisk = true
      })
    }
  }

  lifecycle {
    ignore_changes = [
      ebs_block_device
    ]
  }
}