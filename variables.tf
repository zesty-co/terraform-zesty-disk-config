# The aws_region variable is required for Zesty Disk.
# If it is not already configured in your code, or set in this exact name, provide it below.
variable "aws_region" {}

variable "zesty_disk_config" {
  description = "Configuration elements used to configure Zesty Disk"
  type        = map(any)
  default = {
    # The api_key can be found in the Zesty Disk dashboard by clicking "Install agent"
    api_key = ""
    # Mount point is the path on the machine where the volume will be mounted to
    mount_point = "/mnt"
    # The device name to mount
    device_name = "/dev/sdb"
    # The initial volume size given to Zesty Disk. The recommendation is at least 10GB
    initial_size = 10
  }
}

variable "zesty_disk_config_2" {
  type    = map(any)
  default = {}
}

variable "zesty_disk_config_3" {
  type    = map(any)
  default = {}
}
