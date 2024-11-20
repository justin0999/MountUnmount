#!/bin/bash

# Define variables
DEVICE="/dev/sdb"
MOUNT_POINT="/mnt/lvm_mount"
PARTITIONS=("1" "2" "3" "4" "5")

# Unmount any existing mounts
for PARTITION in "${PARTITIONS[@]}"; do
  MOUNTED=$(mount | grep "${DEVICE}${PARTITION}")
  if [ -n "$MOUNTED" ]; then
    sudo umount "${DEVICE}${PARTITION}"
    echo "Unmounted ${DEVICE}${PARTITION}"
  fi
done

# Remove entries from /etc/fstab
sudo sed -i "\|${DEVICE}|d" /etc/fstab

# Create 5 partitions using fdisk
echo "Creating 5 partitions on $DEVICE"
(
echo n  # Add a new partition
echo p  # Primary partition
echo 1  # Partition number 1
echo    # Default - start at beginning of disk
echo +200M  # 200 MB partition
echo n  # Add a new partition
echo p  # Primary partition
echo 2  # Partition number 2
echo    # Default - next available sector
echo +200M  # 200 MB partition
echo n  # Add a new partition
echo p  # Primary partition
echo 3  # Partition number 3
echo    # Default - next available sector
echo +200M  # 200 MB partition
echo n  # Add a new partition
echo p  # Primary partition
echo 4  # Partition number 4
echo    # Default - next available sector
echo +200M  # 200 MB partition
echo n  # Add a new partition
echo p  # Primary partition
echo 5  # Partition number 5
echo    # Default - next available sector
echo    # Default - extend to end of disk
echo w  # Write changes
) | sudo fdisk $DEVICE

# Create the physical volume (PV)
sudo pvcreate ${DEVICE}1 ${DEVICE}2 ${DEVICE}3 ${DEVICE}4 ${DEVICE}5

# Create the volume group (VG)
sudo vgcreate my_vg ${DEVICE}1 ${DEVICE}2 ${DEVICE}3 ${DEVICE}4 ${DEVICE}5

# Create the logical volume (LV)
sudo lvcreate -l 100%FREE -n my_lv my_vg

# Create a filesystem on the logical volume
sudo mkfs.ext4 /dev/my_vg/my_lv

# Create the mount point directory if it doesn't exist
sudo mkdir -p $MOUNT_POINT

# Mount the logical volume
sudo mount /dev/my_vg/my_lv $MOUNT_POINT

# Update /etc/fstab to mount the logical volume automatically on boot
echo "/dev/my_vg/my_lv $MOUNT_POINT ext4 defaults 0 0" | sudo tee -a /etc/fstab

# Verification commands
echo "Verifying partitions, LVM setup, and mount points:"
lsblk
df -h | grep $MOUNT_POINT
sudo pvs
sudo vgs
sudo lvs

