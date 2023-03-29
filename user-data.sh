#!/bin/bash

API_KEY=${api_key}
INSTALL_URL="https://static.zesty.co/ZX-InfraStructure-Agent-release/install.sh"

MountPoint=(${join(" ", mount_points)})

MountArray=()

# Get the root volume
root_volume=$(df | awk '$6 == "/" { print $1 }')

# List all block devices, filter out those with partitions, and check if they are unmounted and not the root volume
while read -r volume; do
  if ! grep -q "^$volume" /proc/mounts && [ "$volume" != "$root_volume" ]; then
    echo "Unmounted volume: $volume"
    MountArray+=("$volume")
  fi
done < <(lsblk -dpno NAME,TYPE | awk '$2 == "disk" { print $1 }')

install_agent() {
    if [ -z "$API_KEY" ]; then
    echo "Missing API Key, aborting installation" && exit 1
    fi
    curl -s "$INSTALL_URL" | sudo bash -s apikey="$API_KEY"
}

mount_disks() {
  for index in "$${!MountPoint[@]}"; do
    echo Device Name: "$${MountArray[$index]}" '|' Mount Point: "$${MountPoint[$index]}"
    zmount "$${MountArray[$index]}" "$${MountPoint[$index]}"
  done
}

install_agent
mount_disks
