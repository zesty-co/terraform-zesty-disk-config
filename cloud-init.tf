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
    MOUNT_POINT_2=${var.zesty_disk_config_2.mount_point}
    MOUNT_DEVICE_2=${var.zesty_disk_config_2.device_name}
    MOUNT_POINT_3=${var.zesty_disk_config_3.mount_point}
    MOUNT_DEVICE_3=${var.zesty_disk_config_3.device_name}
    INSTALL_URL="https://static.zesty.co/ZX-InfraStructure-Agent-release/install.sh"

    install_agent() {
      if [ -z "$INSTALL_URL" ]; then
      echo "Missing API Key, aborting installation" && exit 1
      fi
      curl -s "$INSTALL_URL" | sudo bash -s apikey="$API_KEY"
    }

    mount_disk_1() {
      if [ -z "$MOUNT_POINT" ]; then
        echo "Missing mount point, aborting installation" && exit 1
      fi
      /opt/zx-infra/zmount.sh "$MOUNT_DEVICE" "$MOUNT_POINT"
    }

    mount_disk_2() {
      if [ -z "$MOUNT_POINT_2" ]; then
        echo "Mount point 2 not set, skipping"
      else
        /opt/zx-infra/zmount.sh "$MOUNT_DEVICE_2" "$MOUNT_POINT_2"
      fi
    }

    mount_disk_3() {
      if [ -z "$MOUNT_POINT_3" ]; then
        echo "Mount point 3 not set, skipping"
      else
        /opt/zx-infra/zmount.sh "$MOUNT_DEVICE_3" "$MOUNT_POINT_3"
      fi
    }

    mount_disks() {
      mount_disk_1
      mount_disk_2
      mount_disk_3
    }


    install_agent
    mount_disks
    EOF
  }
}
