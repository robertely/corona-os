#!/bin/bash

device="/dev/sda"
bootsize="64M"
rootsize="1G"

# to shreads you say
dd if=/dev/zero of=$device  bs=512  count=10

fdisk $device << EOF
n
p
1

+$bootsize
t
c
n
p
2

+$rootsize
w
EOF


mkfs.vfat /dev/sda1
mkfs.ext4 /dev/sda2
mkdir /mnt/boot
mkdir /mnt/system

#sleep 5
mount /dev/sda1 /mnt/boot
mount /dev/sda2 /mnt/system

#sleep 5
rsync -av buildroot/boot/ /mnt/boot
rsync -av --exclude=/etc/ssh/*_key* \
          --exclude=/var/log/* \
          --exclude=/root/* \
          --exclude=/etc/machine-id \
          --exclude=/boot/* \
          buildroot/ /mnt/system

touch /mnt/system/var/log/lastlog
touch /mnt/system/etc/machine-id


# /boot/dt-blob.bin /mnt/boot/
# /boot/config.txt /mnt/boot/

umount /mnt/boot
umount /mnt/system
echo Write complete
