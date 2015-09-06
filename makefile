####
#
#
#
##
device="/dev/sda"
bootsize="64M"
rootsize="1G"

deps:
	apt-get update
	apt-get install debootstrap device-tree-compiler

build:
	debootstrap jessie buildroot

configure:
	cp configure.sh buildroot/
	chroot buildroot ./configure.sh
	rm buildroot/configure.sh

overlay:
	rsync -av root_overlay/ buildroot
	
install_extras:
	chroot buildroot apt-get update
	chroot buildroot apt-get install -y htop vim tree git raspi-config 
burn:
	./burn.sh

clean:
	rm -rf buildroot  

