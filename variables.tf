variable "aws_region" {}

variable "zesty_disk_config" {
  description = "Configuration elements used to configure Zesty Disk"
  type        = map(any)
  default = {
    api_key      = ""
    mount_point  = "/mnt"
    device_name  = "/dev/sdb"
    initial_size = 10
  }
}
