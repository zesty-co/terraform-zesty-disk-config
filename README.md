# Zesty Block Device Terraform Module
This module provides a Zesty disk resource that can be attached to any EC2 instance

## Usage

```hcl
resource "aws_instance" "this" {
  ami           = "ami-063d4ab14480ac177"
  instance_type = "t3.micro"
  user_data = module.zesty_disk.user_data

  # Note: this is *not* the root block device
  ebs_block_device {
    volume_type = "gp2"
    device_name = var.zesty_disk_config.device_name
    volume_size = var.zesty_disk_config.initial_size
    tags        = var.volume_tags
    snapshot_id = module.zesty_disk.snapshot_id
  }

}

module "zesty_disk" {
  source            = "github.com/zesty-co/terraform-zesty-disk-config"
  aws_region        = var.aws_region
  zesty_disk_config = var.zesty_disk_config
}
```

---

## Breakdown of added components

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
