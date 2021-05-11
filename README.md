# Zesty Block Device Terraform Module
This module provides a Zesty disk resource that can be attached to any EC2 instance

## Usage

1. Include the Zesty Disk Configuration module in your code:
```hcl
module "zesty-disk" {
  source = "github.com/zestyco/zbs-tf-config"
}
```

1. Add Zesty Disk Configuration object to your `variables.tf`:
```hcl
variable "zesty_disk_config" {
  type = map(any)
  default = {
    api_key      = ""
    mount_point  = "/mnt"
    device_name  = "/dev/sdb"
    initial_size = 10
  }
}
```

1. Add an `ebs_block_device` to your instance:

```hcl
resource "aws_instance" "this" {
  ebs_block_device {
    device_name = var.zesty_disk_config.device_name
    volume_size = var.zesty_disk_config.initial_size
    tags        = var.volume_tags
    volume_type = "gp2"
    snapshot_id = lookup(var.zesty_disk_snapshot_ids, var.aws_region)
  }

  # Keeps ebs_block_device unchanged on next iterations
  lifecycle {
    ignore_changes = [ebs_block_device]
  }
}
```

1. Add a `user_data` to your instance to install the Zesty Disk Agent and mount the new volume
```hcl
resource "aws_instance" "this" {
  user_data     = module.zesty_disk.data.cloudinit_config.config.rendered
}
```
