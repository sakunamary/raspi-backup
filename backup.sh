#!/bin/bash

set -e

# start
if [ -z $1 ]; then
  echo "Backup directory not set, required."
  exit 1
fi
BACKUP_DIR=$1

BACK_UP_DIR=$BACKUP_DIR/backup 
sudo mkdir $BACK_UP_DIR

echo



# install
echo "Installing package ..."
apt-get install dosfstools dump parted kpartx rsync -y
echo "Finish."
echo

# create image
echo "Creating image ..."
ROOT=`df -P | grep /dev/root | awk '{print $3}'`
MMCBLK0P1=`df -P | grep /dev/mmcblk0p1 | awk '{print $2}'`
ALL=`echo $ROOT $MMCBLK0P1 |awk '{print int(($1+$2)*1.2)}'`
#TIME=`date "+%Y%m%d%H%M%S"`
FILE=$BACK_UP_DIR/backup.img
dd if=/dev/zero of=$FILE bs=1K count=$ALL 
echo "Root size is $ROOT"
echo "root size is $MMCBLK0P1"
echo "FILE Path is $FILE"
echo "Finish."
echo

# part
echo "Parting image ..."
P1_START=`fdisk -l /dev/mmcblk0 | grep /dev/mmcblk0p1 | awk '{print $2}'`
P1_END=`fdisk -l /dev/mmcblk0 | grep /dev/mmcblk0p1 | awk '{print $3}'`
P2_START=`fdisk -l /dev/mmcblk0 | grep /dev/mmcblk0p2 | awk '{print $2}'`

echo "P1_start is :$P1_START .P1_end is : $P1_END  .P2_start is :$P2_START"

parted $FILE --script -- mklabel msdos
parted $FILE --script -- mkpart primary fat32 ${P1_START}s ${P1_END}s
parted $FILE --script -- mkpart primary ext4 ${P2_START}s -1
parted $FILE --script -- quit
echo "Finish."
echo

# mount
echo "Mounting ..."

loopdevice_dst=`sudo losetup -f --show $FILE`  

echo "loopdevice_dst is $loopdevice_dst"


PART_BOOT="/dev/dm-0"
PART_ROOT="/dev/dm-1"
sleep 1 

device_dst=`kpartx -va $loopdevice_dst | sed -E 's/.*(loop[0-9])p.*/\1/g' | head -1`
echo "device_dst Time 1 is $device_dst"

sleep 1
device_dst="/dev/mapper/${device_dst}"

echo "device_dst is Time 2 $device_dst"

sleep 1
sudo mkfs.vfat ${device_dst}p1  #-n boot  
sleep 1
sudo mkfs.ext4 ${device_dst}p2
sleep 1

echo "======4 copy file to img========="
sleep 2

# backup /dev/boot
echo "Backing up disk /dev/boot ..."
sleep 1


dst_boot_path=$BACK_UP_DIR/dst_boot
sudo mkdir  $dst_boot_path 
mount -t vfat ${device_dst}p1 $dst_boot_path  
#sudo rsync -ax /boot/   $dst_root_path
cp -rfp /boot/* $dst_boot_path 

echo "Finish."
echo


# backup /dev/root
echo "Backing up disk /dev/root ..."

sleep 1 
dst_root_path=$BACK_UP_DIR/dst_root
sudo mkdir  $dst_root_path

#echo "do not backup $FILE"

#sudo chattr +d $FILE
sleep 1
sudo mount -t ext4 ${device_dst}p2 $dst_root_path
cd $dst_root_path
echo "dst_root_path is $dst_root_path"
sudo chmod 777  $dst_root_path/

sudo rsync -ax  -q --exclude="$FILE" --exclude=$BACK_UP_DIR/*   --exclude=/sys/* --exclude=/proc/*  --exclude=/tmp/* /  $dst_root_path/ 
echo "Finish."
echo "back folder  $BACKUP_DIR"
cd $BACKUP_DIR
sync

echo


# replace PARTUUID
echo "======5 replace PARTUUID========="
opartuuidb=`blkid -o export /dev/mmcblk0p1 | grep PARTUUID`
opartuuidr=`blkid -o export /dev/mmcblk0p2| grep PARTUUID`
npartuuidb=`blkid -o export ${device_dst}p1 | grep PARTUUID`
npartuuidr=`blkid -o export ${device_dst}p2 | grep PARTUUID`
echo "BOOT uuid old=$opartuuidb -> new=$npartuuidb"
echo "ROOT uuid old=$opartuuidr -> new=$npartuuidr"
sudo sed -i "s/$opartuuidr/$npartuuidr/g" $dst_boot_path/cmdline.txt
sudo sed -i "s/$opartuuidb/$npartuuidb/g" $dst_root_path/etc/fstab
sudo sed -i "s/$opartuuidr/$npartuuidr/g" $dst_root_path/etc/fstab
 

echo "======6 cleaning ========="

echo "Create backup img done, clear job ? Y/N"
read key
if [ "$key" = "y" -o "$key" = "Y" ]; then
sleep 15
sudo umount $dst_boot_path
sudo umount $dst_root_path

  sudo   kpartx  -d ${device_dst}p1 
  sudo   kpartx -d ${device_dst}p2 
 sudo   losetup -d $loopdevice_dst    
sudo rm -rf  $dst_boot_path
sudo rm -rf  $dst_root_path
fi
echo "==========Done==================="
exit 0


