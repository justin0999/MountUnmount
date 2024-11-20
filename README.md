SWAPMOUNT.sh Script Explanation
Script Explanation
Shebang Line:
#!/bin/bash
This line tells the system to run the script using the Bash shell.

Defining Variables:
DEVICE="/dev/sdb"
PARTITION1="${DEVICE}1"
PARTITION2="${DEVICE}2"
SWAP_PARTITION="${DEVICE}3"
MOUNT_POINT1="/mnt/mountA"
MOUNT_POINT2="/mnt/mountB"
These lines define variables used in the script for the device, partitions, and mount points.

Creating New Partitions:
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
This block uses fdisk to create three primary partitions on the specified device.
Partition 1 is 300MB.
Partition 2 is 300MB.
Partition 3 takes up the remaining space.

Formatting Partitions with ext4:
sudo mkfs.ext4 $PARTITION1
sudo mkfs.ext4 $PARTITION2
These commands format the first two partitions with the ext4 filesystem.

Creating Mount Point Directories:
sudo mkdir -p $MOUNT_POINT1
sudo mkdir -p $MOUNT_POINT2
These commands create the mount point directories if they do not already exist.

Mounting Partitions:
sudo mount $PARTITION1 $MOUNT_POINT1
sudo mount $PARTITION2 $MOUNT_POINT2
These commands mount the first two partitions to the specified mount points.

Updating /etc/fstab:
echo "$PARTITION1 $MOUNT_POINT1 ext4 defaults 0 0" | sudo tee -a /etc/fstab
echo "$PARTITION2 $MOUNT_POINT2 ext4 defaults 0 0" | sudo tee -a /etc/fstab
These commands update the /etc/fstab file to ensure the partitions are mounted automatically on boot.

Formatting and Activating Swap Partition:
sudo mkswap $SWAP_PARTITION
sudo swapon $SWAP_PARTITION
These commands format the third partition as swap space and activate it.

Updating /etc/fstab for Swap:
echo "$SWAP_PARTITION none swap sw 0 0" | sudo tee -a /etc/fstab
This command adds an entry to the /etc/fstab file to enable the swap partition on boot.

Verifying Swap Space:
sudo swapon --show
This command verifies the swap space by displaying active swap areas.

Output Confirmation Message:
echo "All tasks done: Partitions created, mounted, and swap space created and activated successfully."
This prints a confirmation message to indicate that all tasks have been completed successfully.

Verification Commands:
echo "Verifying partitions, mount points, and swap space:"
lsblk
df -h | grep /mnt/mount
swapon --show
These commands display the partition layout (lsblk), mounted file systems (df -h | grep /mnt/mount), and active swap space (swapon --show) to verify the setup.

Summary
This script automates the process of creating, formatting, and mounting partitions, as well as setting up swap space on a specified disk device. It also ensures that these partitions are mounted automatically on boot by updating the /etc/fstab file and provides verification commands to check the results.

UNMOUNT.sh Script Explanation
Script Explanation
Shebang Line:
#!/bin/bash
This line specifies that the script should be run using the Bash shell.

Defining Variables:
DEVICE="/dev/sdb"
PARTITIONS=("1" "2" "3")

These lines define variables:
DEVICE specifies the disk device.
PARTITIONS is an array containing the numbers of the partitions to manage.

Unmounting All Partitions:
for PARTITION in "${PARTITIONS[@]}"; do
  MOUNT_POINT=$(mount | grep "${DEVICE}${PARTITION}" | awk '{print $3}')
  if [ -n "$MOUNT_POINT" ]; then
    echo "Unmounting ${DEVICE}${PARTITION} from $MOUNT_POINT"
    sudo umount "${DEVICE}${PARTITION}"
  fi
done
This loop unmounts each partition if it is mounted.

It uses the mount command to find the mount point and awk to extract it.
If the partition is mounted, it is unmounted using sudo umount.

Deactivating Swap:
SWAP_PARTITION=$(swapon --show=NAME | grep "${DEVICE}")
if [ -n "$SWAP_PARTITION" ]; then
  echo "Deactivating swap on $SWAP_PARTITION"
  sudo swapoff "$SWAP_PARTITION"
fi
This part deactivates swap space if it is on one of the partitions.

It checks for active swap partitions using swapon --show=NAME and filters the results with grep.
If swap is active on the specified device, it is deactivated using sudo swapoff.

Removing Entries from /etc/fstab:
sudo sed -i "\|${DEVICE}|d" /etc/fstab
This line removes any entries related to the specified device from the /etc/fstab file to prevent them from being mounted automatically on boot.

Deleting Partitions:
echo "Deleting partitions on $DEVICE"
for PARTITION in "${PARTITIONS[@]}"; do
  sudo parted $DEVICE rm $PARTITION
done
This loop deletes all specified partitions on the device using sudo parted.

Verification and Confirmation:
echo "All partitions have been deleted and swap space has been deactivated."

# List partitions to confirm deletion
sudo parted $DEVICE print

# Verification commands
echo "Verifying deleting partitions, mount points, and swap space:"
lsblk
df -h | grep /mnt/mount
swapon --show
This section prints a confirmation message.
It lists the partitions on the device to confirm deletion using sudo parted $DEVICE print.
It verifies the status of partitions, mount points, and swap space using lsblk, df -h | grep /mnt/mount, and swapon --show.

Summary
This script automates the process of unmounting partitions, deactivating swap space, removing /etc/fstab entries, deleting partitions, and verifying the changes. It ensures that all specified partitions on the device /dev/sdb are managed correctly and that any active swap space is deactivated.

SWAPMOUNT.sh 
Script Explanation
Shebang Line:
#!/bin/bash
This line specifies that the script should be executed using the Bash shell.

Define Variables:
DEVICE="/dev/sdb"
MOUNT_POINT="/mnt/lvm_mount"
PARTITIONS=("1" "2" "3" "4" "5")
DEVICE: The disk device to be partitioned and used.
MOUNT_POINT: The directory where the logical volume will be mounted.
PARTITIONS: An array containing partition numbers.

Unmount Any Existing Mounts:
for PARTITION in "${PARTITIONS[@]}"; do
  MOUNTED=$(mount | grep "${DEVICE}${PARTITION}")
  if [ -n "$MOUNTED" ]; then
    sudo umount "${DEVICE}${PARTITION}"
    echo "Unmounted ${DEVICE}${PARTITION}"
  fi
done
This loop unmounts any currently mounted partitions on the specified device.
It uses the mount command to check if a partition is mounted, and if so, it unmounts it using umount.

Remove Entries from /etc/fstab:
sudo sed -i "\|${DEVICE}|d" /etc/fstab
This line removes any entries related to the specified device from the /etc/fstab file to prevent automatic mounting on boot.

Create 5 Partitions Using fdisk:
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
This block of code uses fdisk to create five primary partitions on the specified device, each with a size of 200MB except for the last partition, which takes up the remaining space.

Create the Physical Volumes (PVs):
sudo pvcreate ${DEVICE}1 ${DEVICE}2 ${DEVICE}3 ${DEVICE}4 ${DEVICE}5
This command initializes the specified partitions as physical volumes for LVM.

Create the Volume Group (VG):
sudo vgcreate my_vg ${DEVICE}1 ${DEVICE}2 ${DEVICE}3 ${DEVICE}4 ${DEVICE}5
This command creates a volume group named my_vg from the physical volumes.

Create the Logical Volume (LV):
sudo lvcreate -l 100%FREE -n my_lv my_vg
This command creates a logical volume named my_lv using all available space in the volume group my_vg.

Create a Filesystem on the Logical Volume:
sudo mkfs.ext4 /dev/my_vg/my_lv
This command creates an ext4 filesystem on the logical volume.

Create the Mount Point Directory:
sudo mkdir -p $MOUNT_POINT
This command creates the mount point directory if it does not already exist.

Mountsudo mount the Logical Volume:
/dev/my_vg/my_lv $MOUNT_POINT
This command mounts the logical volume to the specified mount point.

Update /etc/fstab to Mount on Boot:
echo "/dev/my_vg/my_lv $MOUNT_POINT ext4 defaults 0 0" | sudo tee -a /etc/fstab
This command adds an entry to the /etc/fstab file to ensure the logical volume is mounted automatically on boot.

Verification Commands:
echo "Verifying partitions, LVM setup, and mount points:"
lsblk
df -h | grep $MOUNT_POINT
sudo pvs
sudo vgs
sudo lvs
These commands verify the setup by displaying:
The block devices and their mount points using lsblk.
The mounted file systems and their usage using df -h.
The physical volumes, volume groups, and logical volumes using pvs, vgs, and lvs.

Summary
This script automates the process of creating, formatting, and mounting partitions, setting up LVM, and ensuring everything is properly configured to mount on boot. It also includes verification steps to confirm that everything is set up correctly.

CLEANUP_LVM.sh Script Explanation
Script Explanation
Shebang Line:
#!/bin/bash
This line specifies that the script should be run using the Bash shell.

Defining Variables:
DEVICE="/dev/sdb"
MOUNT_POINT="/mnt/lvm_mount"
PARTITIONS=("1" "2" "3" "4" "5")
DEVICE: The disk device to be managed.
MOUNT_POINT: The directory where the logical volume is mounted.
PARTITIONS: An array containing the partition numbers.

Unmounting the Logical Volume:
if mount | grep "$MOUNT_POINT" > /dev/null; then
  sudo umount "$MOUNT_POINT"
  echo "Unmounted logical volume from $MOUNT_POINT"
fi
This block checks if the logical volume is mounted at the specified mount point and unmounts it if it is.

Deactivating the Logical Volume:
if sudo lvdisplay /dev/my_vg/my_lv > /dev/null 2>&1; then
  sudo lvchange -an /dev/my_vg/my_lv
  echo "Deactivated logical volume my_lv"
fi
This block checks if the logical volume exists and deactivates it.

Removing the Logical Volume:
if sudo lvdisplay /dev/my_vg/my_lv > /dev/null 2>&1; then
  sudo lvremove -y /dev/my_vg/my_lv
  echo "Removed logical volume my_lv"
fi
This block checks if the logical volume exists and removes it.

Removing the Volume Group:
if sudo vgdisplay my_vg > /dev/null 2>&1; then
  sudo vgremove -y my_vg
  echo "Removed volume group my_vg"
fi
This block checks if the volume group exists and removes it.

Removing the Physical Volumes:
for PARTITION in "${PARTITIONS[@]}"; do
  if sudo pvdisplay "${DEVICE}${PARTITION}" > /dev/null 2>&1; then
    sudo pvremove -y "${DEVICE}${PARTITION}"
    echo "Removed physical volume ${DEVICE}${PARTITION}"
  fi
done
This loop checks if each physical volume exists and removes it.

Unmounting Any Remaining Mounted Partitions:
for PARTITION in "${PARTITIONS[@]}"; do
  if mount | grep "${DEVICE}${PARTITION}" > /dev/null; then
    sudo umount "${DEVICE}${PARTITION}"
    echo "Unmounted ${DEVICE}${PARTITION}"
  fi
done
This loop checks if any of the partitions are mounted and unmounts them.

Removing Entries from /etc/fstab:
sudo sed -i "\|${DEVICE}|d" /etc/fstab
echo "Removed ${DEVICE} entries from /etc/fstab"
This line removes any entries related to the specified device from the /etc/fstab file to prevent automatic mounting on boot.

Deleting All Partitions Using fdisk:
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
This block uses fdisk to delete all partitions on the specified device.

Output Confirmation Message:
echo "Clean-up tasks done: Logical volumes, volume groups, physical volumes, and partitions have been removed."
This line prints a confirmation message indicating that the clean-up tasks have been completed successfully.

Summary
This script automates the process of unmounting and removing logical volumes, volume groups, and physical volumes, as well as deleting partitions on the specified device. It ensures that all specified partitions, logical volumes, and volume groups are removed correctly and provides verification of the clean-up process.
