#!/bin/bash

# Define variables
DEVICE="/dev/sdb"
PARTITION1="${DEVICE}1"
PARTITION2="${DEVICE}2"
SWAP_PARTITION="${DEVICE}3"
MOUNT_POINT1="/mnt/mountA"
MOUNT_POINT2="/mnt/mountB"

# Create new partitions using fdisk with sizes
echo "Creating new partitions on $DEVICE"
(
echo n  # Add a new partition
echo p  # Primary partition
echo 1  # Partition number 1
echo    # Default - start at beginning of disk
echo +300M  # 300 MB partition
echo n  # Add a new partition
echo p  # Primary partition
echo 2  # Partition number 2
echo    # Default - next available sector
echo +300M  # 300 MB partition
echo n  # Add a new partition
echo p  # Primary partition
echo 3  # Partition number 3
echo    # Default - next available sector
echo    # Default - extend to end of disk
echo w  # Write changes
) | sudo fdisk $DEVICE

# Format the first two partitions with ext4 file system
sudo mkfs.ext4 $PARTITION1
sudo mkfs.ext4 $PARTITION2

# Create mount point directories if they don't exist
sudo mkdir -p $MOUNT_POINT1
sudo mkdir -p $MOUNT_POINT2

# Mount the first two partitions to the specified mount points
sudo mount $PARTITION1 $MOUNT_POINT1
sudo mount $PARTITION2 $MOUNT_POINT2

# Update /etc/fstab to mount the partitions automatically on boot
echo "$PARTITION1 $MOUNT_POINT1 ext4 defaults 0 0" | sudo tee -a /etc/fstab
echo "$PARTITION2 $MOUNT_POINT2 ext4 defaults 0 0" | sudo tee -a /etc/fstab

# Format the third partition as swap
sudo mkswap $SWAP_PARTITION

# Activate the swap partition
sudo swapon $SWAP_PARTITION

# Add the swap entry to /etc/fstab to enable it on boot
echo "$SWAP_PARTITION none swap sw 0 0" | sudo tee -a /etc/fstab

# Verify the swap space
sudo swapon --show

# Output confirmation message
echo "All tasks done: Partitions created, mounted, and swap space created and activated successfully."

# Verification commands 
echo "Verifying partitions, mount points, and swap space:" 
lsblk 
df -h | grep /mnt/mount 
swapon --show
