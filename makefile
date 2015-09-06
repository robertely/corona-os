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
burn:
	./burn.sh

clean:
	rm -rf buildroot  

