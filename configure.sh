#/bin/sh

echo '#######################################'
echo '# Set Hostname                        #'
echo '#######################################'
echo "jessie" > /etc/hostname

echo '#######################################'
echo '# Set root password                   #'
echo '#######################################'

passwd 


echo '#######################################'
echo '# Set Timezone                        #'
echo '#######################################'
echo "Etc/UTC" >/etc/timezone 
ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime

echo '#######################################'
echo '# Setup fstab                         #'
echo '#######################################'
cat > /etc/fstab << EOF
/dev/mmcblk0p1 /boot vfat noatime 0 2
/dev/mmcblk0p2 / ext4 noatime 0 1
EOF

echo '#######################################'
echo '# Setup basic networking              #'
echo '#######################################'
cat > /etc/network/interfaces.d/eth0 << EOF
auto lo
iface lo inet loopback

auto eth0
allow-hotplug eth0
iface eth0 inet manual

auto wlan0
allow-hotplug wlan0
iface wlan0 inet manual
wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
EOF

echo '#######################################'
echo '# Setup Apt                           #'
echo '#######################################'
cat > /etc/apt/sources.list << EOF
deb http://ftp.de.debian.org/debian jessie main contrib non-free
deb http://ftp.de.debian.org/debian jessie-updates main contrib non-free
deb http://security.debian.org jessie/updates main contrib non-free
deb http://archive.raspberrypi.org/debian wheezy main
EOF

wget http://archive.raspberrypi.org/debian/raspberrypi.gpg.key -O - | apt-key add -

cat > /etc/apt/preferences.d/raspberrypi << EOF
Package: *
Pin: origin archive.raspberrypi.org
Pin-Priority: 1

Package: raspberrypi-bootloader
Pin: origin archive.raspberrypi.org
Pin-Priority: 1000

Package: libraspberrypi0
Pin: origin archive.raspberrypi.org
Pin-Priority: 1000

Package: libraspberrypi-bin
Pin: origin archive.raspberrypi.org
Pin-Priority: 1000
EOF

echo '#######################################'
echo '# Install supplements                 #'
echo '#######################################'
apt update
apt upgrade -y
apt install -y \
    dhcpcd5 \
    resolvconf \
    locales \
    dbus \
    openssh-server \
    dosfstools \
    libraspberrypi-bin \
    wpasupplicant 
apt-get clean

locale-gen --purge en_US.UTF-8
echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale


echo '#######################################'
echo '# Setup SSH                           #'
echo '#######################################'
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

cat > /etc/systemd/system/sshdgenkeys.service << EOF
[Unit]
Description=SSH key generation on first startup
Before=ssh.service
ConditionPathExists=|!/etc/ssh/ssh_host_key
ConditionPathExists=|!/etc/ssh/ssh_host_key.pub
ConditionPathExists=|!/etc/ssh/ssh_host_rsa_key
ConditionPathExists=|!/etc/ssh/ssh_host_rsa_key.pub
ConditionPathExists=|!/etc/ssh/ssh_host_dsa_key
ConditionPathExists=|!/etc/ssh/ssh_host_dsa_key.pub
ConditionPathExists=|!/etc/ssh/ssh_host_ecdsa_key
ConditionPathExists=|!/etc/ssh/ssh_host_ecdsa_key.pub
ConditionPathExists=|!/etc/ssh/ssh_host_ed25519_key
ConditionPathExists=|!/etc/ssh/ssh_host_ed25519_key.pub

[Service]
ExecStart=/usr/bin/ssh-keygen -A
Type=oneshot
RemainAfterExit=yes

[Install]
WantedBy=ssh.service
EOF

mkdir /etc/systemd/system/ssh.service.wants
ln -s /etc/systemd/system/sshdgenkeys.service /etc/systemd/system/ssh.service.wants


echo '#######################################'
echo '# Setup Clocks                        #'
echo '#######################################'
systemctl enable systemd-timesyncd
systemctl disable hwclock-save


echo 'Setup complete...'


