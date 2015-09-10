####
# Generates corona-os with aditions for electron front ends.
##
device="/dev/sda"
bootsize="64M"
rootsize="1G"

deps:
	apt-get update
	apt-get install debootstrap device-tree-compiler rpi-update
	rpi-update
base:
	debootstrap jessie buildroot
configure:
	cp configure.sh buildroot/
	chroot buildroot ./configure.sh
	rm buildroot/configure.sh
extras:
	chroot buildroot apt-get update
	chroot buildroot apt-get install -y htop vim tree git raspi-config rpi-update raspi-config

electron:
	chroot buildroot apt-get install libgtk2.0-0 libnotify4 libgconf2-4 libnss3 npm
	chroot buildroot npm install -g react-tools

overlay:
	rsync -av root_overlay/ buildroot
burn:
	./burn.sh
clean:
	rm -rf buildroot  
