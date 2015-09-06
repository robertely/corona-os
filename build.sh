#/bin/sh

if [ "$(id -u)" != "0" ]; then
	echo "You should be root."
	exit 1
fi


if [ -d "buildroot" ]; then
  rm -rf buildroot
fi

debootstrap jessie buildroot

cp configure.sh buildroot/

chroot buildroot ./configure.sh

