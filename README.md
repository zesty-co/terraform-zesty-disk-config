# Zesty Block Device Terraform Module
This module provides a Zesty disk resource that can be attached to any EC2 instance
Or for quick creation and test use the managed deployment

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.55 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.55 |

## Usage (example) Self Managed
``` hcl
# If you with to add more than one Zesty disks (up to three are supported
variable "disks" {
  default = [
      {
        disk_type = "gp3"
        mount_point = "/mnt"
        name = "/dev/sdb"
        size = 15
      },
      {
        disk_type = "gp3"
        mount_point = "/mnt2"
        name = "/dev/sdc"
        size = 20
      }
  ]
}

data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

module "zesty-disk" {
    source     = "github.com/zesty-co/terraform-zesty-disk-config"
    aws_region = var.aws_region
    api_key    = "my-zesty-api-key"
    disks      = var.disks
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.this.id
  instance_type = "t3.micro"
  user_data     = module.zesty-disk.user_data

  # Note: this is *not* the root block device
  dynamic "ebs_block_device" {
    for_each = var.disks
    content {
      device_name           = ebs_block_device.value.name
      volume_size           = ebs_block_device.value.size
      volume_type           = ebs_block_device.value.disk_type
      delete_on_termination = true
      tags                  = merge(var.ebs_tags, {
        ZestyDisk = true
      })
    }
  }

  # Make sure lifecycle is set to ignore ebs_block_device (and others if you have) to prevent them from being changed on future Terraform runs
  lifecycle {
    ignore_changes = [ebs_block_device]
  }
}

```
## Usage (example) Managed Deployment

```hcl
module "zesty-disk" {
    source             = "github.com/zesty-co/terraform-zesty-disk-config"
    aws_region         = var.aws_region
    api_key            = "my-zesty-api-key"
    managed_deployment = true

    # Optional Parameters

    # EC2 Instance type defaults to t2.micro
    instance_type      = m5.large

    # Create iam-role with AWS-SSMCore policy for connecting the instance using ssm instead of ssh
    enable_ssm         = true

    # For old fashion ssh access (make sure the default vpc sg allow inbound rule for ssh)
    kay_pair           = "my-key-pair"

    # The default value for disks creates one ebs_block_device
    # In case you want to create more then one disk
    # Supported volume types are gp2, and gp3
    # Max
    disks               = [
      {
        disk_type = "gp3"
        mount_point = "/mnt"
        name = "/dev/sdb"
        size = 15
      },
      {
        disk_type = "gp3"
        mount_point = "/mnt2"
        name = "/dev/sdc"
        size = 20
      }
    ]
}
```

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws_region](#input\_aws_region) | AWS Region on which the resources are getting deployed | `string` | `null` | yes |
| <a name="input_api_key"></a> [api_key](#input\_api_key) | The api_key can be found in the Zesty Disk dashboard by clicking Install Collector | `string` | `null` | yes |
| <a name="input_managed_deployment"></a> [managed_deployment](#input\_managed_deployment) | Used to auto deploy EC2 instance with Zesty-Disk Agent | `bool` | `false` | no |
| <a name="input_enable_ssm"></a> [enable_ssm](#input\_enable_ssm) | Use to create iam-role with SSM-CORE policy for ssm access to the instance only work when [managed_deployment](#input\_managed_deployment) set to true | `bool` | `false` | no |
| <a name="input_kay_pair"></a> [kay_pair](#input\_kay_pair) | Used for old fasion ssh access with user created key-pair by in the AWS Console | `string` | `null` | no |
| <a name="input_disks"></a> [disks](#input\_disks) | List of Disk to configure the  | `list(object({name = string,size = number,disk_type = string,mount_point = string}))` | `[{name = "/dev/sdb",size = 15,disk_type = "gp3",mount_point = "/mnt"}]` | no |

## Authors

Module is maintained by [Omer Hamerman](https://github.com/omerxx) with help from [Regev Agabi](https://github.com/ragabi-ops).

![alt text](https://zesty.co/wp-content/uploads/2020/10/cropped-logo-1.png)
