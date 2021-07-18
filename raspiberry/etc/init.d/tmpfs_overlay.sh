#!/bin/sh

### BEGIN INIT INFO
# Provides: var opt
# Required-Start: mountkernfs udev eudev
# Required-Stop: umountfs
# Default-Start: S
# Default-Stop: 0 6
# Short-Description:  mount /var and /opt to overlayfs
# Description:
### END INIT INFO

# update-rc.d tmpfs_overlay defaults S

PATH=/sbin:/bin:/usr/sbin:/usr/bin
. /lib/init/vars.sh
. /lib/init/tmpfs.sh

. /lib/lsb/init-functions
. /lib/init/mount-functions.sh


# domount function: Mount kernel and device file systems.
# $1: mount mode (mount, remount)
# $2: file system type
# $3: alternative file system type (or empty string if none)
# $4: mount point
# $5: mount device name
# $6... : extra mount program options


do_start(){
    # create /cache and mount tmpfs on it
    log_daemon_msg "Mounting /cache"
    domount mount tmpfs "" /cache tmpfs "-omode=1777,nosuid,nodev "
    
    # mount disk partitiion3 to /writable
    log_daemon_msg "Mounting /writable"
    domount mount ext4 "" /writable /dev/mmcblk0p3 "-onoatime,nodiratime"
    
    # create overlay mount dir
    log_daemon_msg "Creating dirs for /var and /opt"
    mkdir -p /cache/var /cache/opt /cache/overlay/var /cache/overlay/opt
    mkdir -p /writable/var /writable/opt
    
    # mount /var
    log_daemon_msg "mounting /var"
    mount -t overlay overlay -o lowerdir=/writable/var:/var_ro,upperdir=/cache/var,workdir=/cache/overlay/var /var
    
    # mount /opt
    log_daemon_msg "mounting /opt"
    mount -t overlay overlay -o lowerdir=/writable/opt,upperdir=/cache/opt,workdir=/cache/overlay/opt /opt
    
    #log_daemon_msg "change / to ro mode"
    #mount -o remount,ro,defaults /dev/sda2 /
    
    exit $?
}

do_stop(){
    log_daemon_msg "umount /opt"
    umount /opt
    
    log_daemon_msg "umount /var"
    umount /var
    
    log_daemon_msg "save /cache/var to /writable/var"
    rsync -ar /cache/var/ /writable/var
    
    log_daemon_msg "save /cache/opt to /writable/opt"
    rsync -ar /cache/opt/ /writable/opt
    
    log_daemon_msg "umount /cache"
    umount /cache
    
    log_daemon_msg "umount /writable"
    umount /writable
    
    exit $?
}


case "$1" in

    start|"")
	do_start
	;;

    restart)
	do_stop
	do_start
	;;

    stop)
	do_stop
	;;

    status)
	df -h --output | egrep '(/var$)|(/opt$)|(/cache$)|(/writable$)|(Filesystem\s*Type\s*Inodes\s*IUsed\s*IFree)'
	;;

    reload|force-reload)
	echo "Only start, stop, restart, status supported at current time"
	exit 1
	;;
    *)
        echo "Usage: ${0:-} {start|stop|restart|status}" >&2
        exit 1
	;;

esac
