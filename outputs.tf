output "user_data" {
  value = data.cloudinit_config.config.rendered
}

output "snapshot_id" {
  value = local.snapshot_id
}
