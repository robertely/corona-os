####
# Generates corona-os with aditions for electron front ends.
##
build_root=build_root
device="/dev/sda"
bootsize="64M"
rootsize="2G"

all:
	make clean
	make base
	make configure
	make extras
	make electron
#	make burn

deps:
	apt-get update
	apt-get install -y debootstrap device-tree-compiler rpi-update
	rpi-update

base:
	debootstrap jessie build_root

configure:
	cp build_scripts/configure.sh build_root/
	chroot build_root ./configure.sh
	rm build_root/configure.sh

extras:
	chroot build_root apt-get update
	chroot build_root apt-get install -y sudo vim tree htop git raspi-config rpi-update

electron:
	chroot build_root apt-get install -y libgtk2.0-0 libnotify4 libgconf2-4 libnss3 npm xinit unzip
	chroot build_root ln -s /usr/bin/nodejs /usr/bin/node
	chroot build_root npm install -g react-tools
	chroot build_root mkdir -p /opt/electron
	chroot build_root wget -P /opt/electron https://github.com/atom/electron/releases/download/v0.33.0/electron-v0.33.0-linux-arm.zip
	chroot build_root unzip /opt/electron/electron-v0.33.0-linux-arm.zip -d /opt/electron
	chroot build_root ln -s /opt/electron/electron /usr/local/bin/electron

overlay:
#	cp /etc/wpa_supplicant/wpa_supplicant.conf build_root/etc/wpa_supplicant/wpa_supplicant.conf # Copy wireless config from host
	rsync -av root_overlay/ $(build_root)

burn:
	./build_scripts/burn.sh $(device) $(build_root) $(bootsize) $(rootsize)

clean:
	rm -rf build_root
