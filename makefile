####
#
#
#
##
device="/dev/sda"
bootsize="64M"
rootsize="1G"

build:
	debootstrap jessie buildroot

configure:
	cp configure.sh buildroot/
	chroot buildroot ./configure.sh
	rm buildroot/configure.sh

burn:
	./burn.sh

clean:
	rm -rf buildroot  

