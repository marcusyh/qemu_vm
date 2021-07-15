#!/bin/bash

case "$1" in

    start|"")
	# create /cache and mount tmpfs on it
	mkdir -p /cache
	mount -t tmpfs /cache

	# mount disk partitiion3 to /writable
	mount -t ext4 -o noatime,nodiratime /dev/mmcblk0p3 /writable/

	# create overlay mount dir
	mkdir -p /cache/var /cache/opt /cache/overlay/var /cache/overlay/opt
	mkdir -p /writable/var /writable/opt

	# mount /var
	mount -o remount,ro,defaults /dev/sda2 /
	mount -t overlay overlay -o lowerdir=/writable/var:/var_bak,upperdir=/cache/var,workdir=/cache/overlay/var /var

	# mount /opt
	mount -t overlay overlay -o lowerdir=/writable/opt,upperdir=/cache/opt,workdir=/cache/overlay/opt /opt

	systemctl daemon-reload
	systemctl start systemd-timesyncd

	exit $?
	;;

    restart|reload|force-reload)
	exit 3
	;;

    stop)
	umount /opt
	umount /var
	rsync -avr /cache/var/ /writable/var
	umount /cache
	umount /writable

	exit $?
	;;

    *)
	exit 3
	;;

esac
