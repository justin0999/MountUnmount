#!/bin/bash

# Define variables
DEVICE="/dev/sdb"
MOUNT_POINT="/mnt/lvm_mount"
PARTITIONS=("1" "2" "3" "4" "5")

# Unmount the logical volume
if mount | grep "$MOUNT_POINT" > /dev/null; then
  sudo umount "$MOUNT_POINT"
  echo "Unmounted logical volume from $MOUNT_POINT"
fi

# Deactivate the logical volume
if sudo lvdisplay /dev/my_vg/my_lv > /dev/null 2>&1; then
  sudo lvchange -an /dev/my_vg/my_lv
  echo "Deactivated logical volume my_lv"
fi

# Remove the logical volume
if sudo lvdisplay /dev/my_vg/my_lv > /dev/null 2>&1; then
  sudo lvremove -y /dev/my_vg/my_lv
  echo "Removed logical volume my_lv"
fi

# Remove the volume group
if sudo vgdisplay my_vg > /dev/null 2>&1; then
  sudo vgremove -y my_vg
  echo "Removed volume group my_vg"
fi

# Remove the physical volumes
for PARTITION in "${PARTITIONS[@]}"; do
  if sudo pvdisplay "${DEVICE}${PARTITION}" > /dev/null 2>&1; then
    sudo pvremove -y "${DEVICE}${PARTITION}"
    echo "Removed physical volume ${DEVICE}${PARTITION}"
  fi
done

# Unmount any remaining mounted partitions
for PARTITION in "${PARTITIONS[@]}"; do
  if mount | grep "${DEVICE}${PARTITION}" > /dev/null; then
    sudo umount "${DEVICE}${PARTITION}"
    echo "Unmounted ${DEVICE}${PARTITION}"
  fi
done

# Remove entries from /etc/fstab
sudo sed -i "\|${DEVICE}|d" /etc/fstab
echo "Removed ${DEVICE} entries from /etc/fstab"

# Delete all partitions using fdisk
echo "Deleting all partitions on $DEVICE"
(
echo d  # Delete partition
echo 1
echo d  # Delete partition
echo 2
echo d  # Delete partition
echo 3
echo d  # Delete partition
echo 4
echo d  # Delete partition
echo 5
echo w  # Write changes
) | sudo fdisk $DEVICE
echo "Deleted all partitions on $DEVICE"

# Output confirmation message
echo "Clean-up tasks done: Logical volumes, volume groups, physical volumes, and partitions have been removed."

