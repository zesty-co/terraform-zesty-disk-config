# Zesty Block Device Terraform Module
This module provides a Zesty disk resource that can be attached to any EC2 instance

## Usage (example)

```hcl
resource "aws_instance" "this" {
  ami           = "ami-063d4ab14480ac177"
  instance_type = "t3.micro"
  user_data = module.zesty_disk.user_data

  # Note: this is *not* the root block device
  ebs_block_device {
    # Do not change "gp2", this is currently the only volume_type supported
    volume_type = "gp2"
    device_name = var.zesty_disk_config.device_name
    # The initial volume size given to Zesty Disk. The recommendation is at least 10GB
    volume_size = var.zesty_disk_config.initial_size
    tags        = var.volume_tags
    snapshot_id = module.zesty_disk.snapshot_id
  }

  # Make sure lifecycle is set to ignore ebs_block_device (and others if you have) to prevent them from being changed on future Terraform runs
  lifecycle {
    ignore_changes = [ebs_block_device]
  }
}

module "zesty_disk" {
  source            = "github.com/zesty-co/terraform-zesty-disk-config"
  aws_region        = var.aws_region
  zesty_disk_config = var.zesty_disk_config
}
```

---

## Breakdown of required components

1. Include the Zesty Disk Configuration module in your code:
```hcl
module "zesty_disk" {
  source            = "github.com/zesty-co/terraform-zesty-disk-config"
  aws_region        = var.aws_region
  zesty_disk_config = var.zesty_disk_config
}
```

2. Add Zesty Disk Configuration object to your `variables.tf`:
```hcl
variable "zesty_disk_config" {
  type = map(any)
  default = {
    api_key      = "myzestyapikey"
    mount_point  = "/mnt"
    device_name  = "/dev/sdb"
    initial_size = 10
  }
}
```

3. Add an `ebs_block_device` to your instance:

```hcl
resource "aws_instance" "this" {
  # ebs_block_device is a non-root volume that's provisioned with the instance, you can have up to three that are configured as Zesty Disks
  ebs_block_device {
    volume_type = "gp2"
    device_name = var.zesty_disk_config.device_name
    volume_size = var.zesty_disk_config.initial_size
    tags        = var.volume_tags
    snapshot_id = module.zesty_disk.snapshot_id
  }

  # Keeps ebs_block_device unchanged on next iterations
  lifecycle {
    ignore_changes = [ebs_block_device]
  }
}
```

4. Add a `user_data` to your instance to install the Zesty Disk Agent and mount the new volume
```hcl
resource "aws_instance" "this" {
  user_data = module.zesty_disk.user_data
}
```

<details>
<summary>Adding additional Zesty Disks</summary>
If you with to add more than one Zesty disks (up to three are supported), here's an expanded configuration:
```hcl
resource "aws_instance" "this" {
  ami           = "ami-063d4ab14480ac177"
  instance_type = "t3.micro"
  user_data = module.zesty_disk.user_data

  ebs_block_device {
    volume_type = "gp2"
    device_name = var.zesty_disk_config.device_name
    volume_size = var.zesty_disk_config.initial_size
    tags        = var.volume_tags
    snapshot_id = module.zesty_disk.snapshot_id
  }

  ebs_block_device {
    volume_type = "gp2"
    device_name = var.zesty_disk_config_2.device_name
    volume_size = var.zesty_disk_config_2.initial_size
    tags        = var.volume_tags
    snapshot_id = module.zesty_disk.snapshot_id
  }

  ebs_block_device {
    volume_type = "gp2"
    device_name = var.zesty_disk_config_3.device_name
    volume_size = var.zesty_disk_config_3.initial_size
    tags        = var.volume_tags
    snapshot_id = module.zesty_disk.snapshot_id
  }

  lifecycle {
    ignore_changes = [ebs_block_device]
  }
}

module "zesty_disk" {
  source            = "github.com/zesty-co/terraform-zesty-disk-config"
  aws_region        = var.aws_region
  zesty_disk_config = var.zesty_disk_config
}
```

This would also require an additional configuration for the additional disk(s):
```hcl
# variables.tf:
# Note that api_key is not required as the same key can be used from the first disk config object

variable "zesty_disk_config_2" {
  type = map(any)
  default = {
    mount_point  = ""
    device_name  = ""
    initial_size = 10
  }
}

variable "zesty_disk_config_3" {
  type = map(any)
  default = {
    mount_point  = ""
    device_name  = ""
    initial_size = 10
  }
}
```
</details>

