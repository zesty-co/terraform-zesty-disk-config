data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
    #!/bin/bash
    API_KEY=${var.zesty_disk_config.api_key}
    MOUNT_POINT=${var.zesty_disk_config.mount_point}
    MOUNT_DEVICE=${var.zesty_disk_config.device_name}
    INSTALL_URL="https://static.zesty.co/ZX-InfraStructure-Agent-release/install.sh"

    install_agent() {
      if [ -z "$INSTALL_URL" ]; then
      echo "Missing API Key, aborting installation" && exit 1
      fi
      curl -s "$INSTALL_URL" | sudo bash -s apikey="$API_KEY"
    }

    mount_disk() {
      if [ -z "$MOUNT_POINT" ]; then
      echo "Missing mount point, aborting installation" && exit 1
      fi
      /opt/zx-infra/zmount.sh "$MOUNT_DEVICE" "$MOUNT_POINT"
    }

    install_agent
    mount_disk
    EOF
  }
}
