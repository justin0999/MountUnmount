#!/bin/bash

# Define variables
DEVICE="/dev/sdb"
PARTITIONS=("1" "2" "3")

# Unmount all partitions
for PARTITION in "${PARTITIONS[@]}"; do
  MOUNT_POINT=$(mount | grep "${DEVICE}${PARTITION}" | awk '{print $3}')
  if [ -n "$MOUNT_POINT" ]; then
    echo "Unmounting ${DEVICE}${PARTITION} from $MOUNT_POINT"
    sudo umount "${DEVICE}${PARTITION}"
  fi
done

# Deactivate swap if it is on one of the partitions
SWAP_PARTITION=$(swapon --show=NAME | grep "${DEVICE}")
if [ -n "$SWAP_PARTITION" ]; then
  echo "Deactivating swap on $SWAP_PARTITION"
  sudo swapoff "$SWAP_PARTITION"
fi

# Remove entries from /etc/fstab
sudo sed -i "\|${DEVICE}|d" /etc/fstab

# Use parted to delete all partitions
echo "Deleting partitions on $DEVICE"
for PARTITION in "${PARTITIONS[@]}"; do
  sudo parted $DEVICE rm $PARTITION
done

# Verify changes
echo "All partitions have been deleted and swap space has been deactivated."

# List partitions to confirm deletion
sudo parted $DEVICE print

# Verification commands 
echo "Verifying deleting partitions, mount points, and swap space:" 
lsblk 
df -h | grep /mnt/mount 
swapon --show
