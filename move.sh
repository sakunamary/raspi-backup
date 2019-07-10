
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


target_boot=/dev/sda1
target_root=/dev/sdb1

echo



# mount
echo "Mounting ..."



sleep 1
sudo mkfs.vfat $target_boot  #-n boot  
sleep 1
sudo mkfs.ext4 $target_root
sleep 1



echo "====== copy file to img========="
sleep 2

# backup /dev/boot
echo "Backing up disk /dev/boot ..."
sleep 1


dst_boot_path=$BACK_UP_DIR/dst_boot
sudo mkdir  $dst_boot_path 
mount -t vfat $target_boot $dst_boot_path  
ls $dst_boot_path  

sleep 3

echo "dst_boot_path is $dst_boot_path"


sudo chmod 777  $dst_boot_path/
sudo rsync -ax /boot/   $dst_boot_path
#sudo cp -rfp /boot/* $dst_boot_path 


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
sudo mount -t ext4 $target_root $dst_root_path
cd $dst_root_path
echo "dst_root_path is $dst_root_path"
sudo chmod 777  $dst_root_path/

sudo rsync -ax     --exclude=/sys/* --exclude=/proc/*  --exclude=/tmp/* /  $dst_root_path/ 
echo "Finish."
echo "back folder  $BACKUP_DIR"
cd $BACKUP_DIR
sync

echo


# replace PARTUUID
echo "====== replace PARTUUID========="
opartuuidb=`blkid -o export /dev/mmcblk0p1 | grep PARTUUID`
opartuuidr=`blkid -o export /dev/mmcblk0p2| grep PARTUUID`
npartuuidb=`blkid -o export $target_boot | grep PARTUUID`
npartuuidr=`blkid -o export $target_root | grep PARTUUID`
echo "BOOT uuid old=$opartuuidb -> new=$npartuuidb"
echo "ROOT uuid old=$opartuuidr -> new=$npartuuidr"
sudo sed -i "s/$opartuuidr/$npartuuidr/g" $dst_boot_path/cmdline.txt
sudo sed -i "s/$opartuuidb/$npartuuidb/g" $dst_root_path/etc/fstab
sudo sed -i "s/$opartuuidr/$npartuuidr/g" $dst_root_path/etc/fstab
 

echo "====== cleaning ========="

echo "Create backup img done, clear job ? Y/N"
read key
if [ "$key" = "y" -o "$key" = "Y" ]; then
sleep 15


#sudo umount $dst_boot_path
#sudo rm -rf  $dst_boot_path

#sudo umount $dst_root_path


sleep 5
#sudo rm -rf  $dst_root_path



 # sudo   kpartx  -d ${device_dst}p1 
#  sudo   kpartx -d ${device_dst}p2 
#  sudo   losetup -d $loopdevice_dst    

fi
echo "==========Done==================="
exit 0


