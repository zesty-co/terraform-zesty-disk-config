# The aws_region variable is required for Zesty Disk.
# If it is not already configured in your code, or set in this exact name, provide it below.
variable "aws_region" {
  type    = string
  default = "us-west-2"
}
variable "api_key" {
  description = "The api_key can be found in the Zesty Disk dashboard by clicking Install Collector"
  type        = string
  default     = ""
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "managed_deployment" {
  type    = bool
  default = false
}

variable "enable_ssm" {
  type    = bool
  default = false
}
variable "tags" {
  type    = map(any)
  default = {}
}
variable "ebs_tags" {
  type    = map(any)
  default = {}
}
variable "iam_instance_profile" {
  type    = string
  default = null
}
variable "key_pair" {
  type    = string
  default = null
}
variable "disks" {
  type = list(object({
    name        = string,
    size        = number,
    disk_type   = string,
    mount_point = string
  }))
  default = [
    {
      name        = "/dev/sdb",
      size        = 15,
      disk_type   = "gp3",
      mount_point = "/mnt"
    }
  ]
}
