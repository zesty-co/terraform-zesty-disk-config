#!/bin/bash

API_KEY=${api_key}
INSTALL_URL="https://static.zesty.co/ZX-InfraStructure-Agent-release/install.sh"

MOUNT_POINTS=(${join(" ", mount_points)})


# Get the root volume
root_volume=$(mount|grep ' / '|cut -d' ' -f 1 | sed 's/p[0-9]*$//')

find_available_device() {
  requested_size=$1
  # List all block devices, filter out those with partitions, and check if they are unmounted and not the root volume
  while read -r volume_size_tuple; do
    IFS=' ' read -r volume size <<< "$volume_size_tuple"
    if ! grep -q "^$volume" /proc/mounts && [ "$volume" != "$root_volume" ] && [ "$size" == "$requested_size" ]; then
      echo "$volume"
      return
    fi
   done < <(lsblk -dpno NAME,TYPE,SIZE | awk '$2 == "disk"  { print $1,$3}')
}

mount_disks() {
for mount_size_tuple in "${MOUNT_POINTS[@]}"; do
  IFS=',' read -r mount_name mount_size <<< "$mount_size_tuple"
  volume_name=$(find_available_device $mount_size)
  echo "Found match for volume $volume_name and mount $mount_name"
  zestyctl disk mount "$volume_name" "$mount_name"
done
}

install_agent() {
    if [ -z "$API_KEY" ]; then
    echo "Missing API Key, aborting installation" && exit 1
    fi
    curl -s "$INSTALL_URL" | sudo bash -s apikey="$API_KEY"
}


install_agent
mount_disks
