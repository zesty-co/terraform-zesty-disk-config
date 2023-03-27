output "user_data" {
  value = data.cloudinit_config.config.rendered
}

output "instance_public_ip" {
  value = try(aws_instance.this[0].public_ip, "")
}
