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
. /lib/init/remount-functions.sh


# domount function: Mount kernel and device file systems.
# $1: mount mode (mount, remount)
# $2: file system type
# $3: alternative file system type (or empty string if none)
# $4: mount point
# $5: mount device name
# $6... : extra mount program options

DEBUG=0 #0 print debug info. other, ignore debug
TMP_NORMAL_MODE_START=/etc/init.d/.tmpfs_overlay_normal_mode_start
TMP_NORMAL_MODE_STOP=/etc/init.d/.tmpfs_overlay_normal_mode_stop
TMP_DEPLOY=/etc/init.d/.tmpfs_overlay_deploy
USERS_LIST=$(ls /home |grep _ro$ |sed 's/_ro$//g' |xargs)

make_move(){
    SRC=$1
    DST=$2
    FLAG=$3

    test -d $SRC || return 1

    test -d $DST && "$FLAG"_"$DST"_$(date +%Y%m%d%H%M%S.%N)
    while $(lsof $SRC)
    do
	lsof -t $SRC | xargs kill -9
	sleep 1
    done

    if [ -d $DST ]
    then
    	while $(lsof $DST)
    	do
    	    lsof -t $DST | xargs kill -9
    	    sleep 1
    	done
    fi

    while ! $(mv $SRC $DST)
    do
	lsof -t $SRC | xargs kill -9
	test -d $DST && lsof -t $DST | xargs kill -9
	sleep 1
    done

    return 0
}

make_umount(){
    MNT=$1

    count=0
    while ! $(umount $MNT)
    do
	pid=$(lsof -t $MNT)
	if [ -z "$pid" -o $count -gt 3 ]
	then
	    break
	fi
	kill -9 $pid
    done

    umount -f $MNT
}

save_user(){
    CACHE_PATH=$1
    DISK_PATH=$2

    test -d $CACHE_PATH || return
    cd $CACHE_PATH
    rsync -ar --ignore-missing-args \
        .aptitude \
        .bash_history \
        .config \
        .gnuplot_history \
        .ipython \
        .sqlite_history \
        .ratpoison_history \
        .viminfo \
        .ssh \
        .recently-used \
        .mozilla \
        $DISK_PATH/

    test -d $CACHE_PATH/.config || return
    cd $CACHE_PATH/.config
    rsync -ar --ignore-missing-args \
        fcitx \
        libreoffice \
        Google \
        sublime-text \
        $DISK_PATH/.config/
 
}


start_normal_mode(){
    rootfs_is_rw || remount_rootfs_rw 0

    set_fstab_rootfs_rw 0
    set_fstab_bootfs_rw 0
    touch $TMP_NORMAL_MODE_START

    reboot
}

do_deploy(){
    rootfs_is_rw || remount_rootfs_rw 0

    set_fstab_rootfs_rw 1
    set_fstab_bootfs_rw 1
    touch $TMP_DEPLOY
    update-rc.d tmpfs_overlay.sh defaults

    reboot
}


do_start(){
    # create /cache and mount tmpfs on it
    log_daemon_msg "Mounting /cache"
    domount mount tmpfs "" /cache tmpfs "-omode=1777,nosuid,nodev "
    
    # mount disk partitiion3 to /writable
    log_daemon_msg "Mounting /writable"
    domount mount ext4 "" /writable /dev/mmcblk0p3 "-onoatime,nodiratime"
    
    # create overlay mount dir
    log_daemon_msg "Creating dirs for /var and /opt"
    mkdir -p /cache/var /cache/overlay/var
    mkdir -p /cache/root /cache/overlay/root
    mkdir -p /cache/opt /cache/overlay/opt && chown -R marcusyh:marcusyh /cache/opt
    for user_name in $USERS_LIST
    do
        mkdir -p /cache/home_"$user_name" /cache/overlay/home_"$user_name"
        chown -R $user_name:$(id -g $user_name) /cache/home_"$user_name" /cache/overlay/home_"$user_name"
    done

    test -f /writable/var || mkdir -p /writable/var
    test -f /writable/opt || mkdir -p /writable/opt
    test -f /writable/root || mkdir -p /writable/root
    for user_name in $USERS_LIST
    do
    	test -d /writable/home_"$user_name" || \
        mkdir -p /writable/home_"$user_name" && \
        chown -R $user_name:$(id -g $user_name) /writable/home_"$user_name"
    done

    # mount /var
    if [ -f $TMP_NORMAL_MODE_START ]
    then
    	rootfs_is_rw || remount_rootfs_rw 0
        log_daemon_msg "booting in normal mode"
        mv $TMP_NORMAL_MODE_START $TMP_NORMAL_MODE_STOP
    else
    	log_daemon_msg "mounting /var /root /home/<user>"
    	mount -t overlay overlay -o lowerdir=/writable/var:/var_ro,upperdir=/cache/var,workdir=/cache/overlay/var /var
    fi

    mount -t overlay overlay -o lowerdir=/writable/root:/root_ro,upperdir=/cache/root,workdir=/cache/overlay/root /root
    for user_name in $USERS_LIST
    do
        mount -t overlay overlay -o lowerdir=/writable/home_"$user_name":/home/"$user_name"_ro,upperdir=/cache/home_"$user_name",workdir=/cache/overlay/home_"$user_name" /home/$user_name
    done

    test -f $TMP_DEPLOY && rm -rf $TMP_DEPLOY
    
    # mount /opt
    log_daemon_msg "mounting /opt"
    mount -t overlay overlay -o lowerdir=/writable/opt,upperdir=/cache/opt,workdir=/cache/overlay/opt /opt
}

stop_for_normal_start(){
    if [ -f $TMP_DEPLOY -o -f $TMP_NORMAL_MODE_START ]
    then
	test -f $TMP_NORMAL_MODE_STOP && return 0

    	rootfs_is_rw || remount_rootfs_rw 0

    	make_move /var /var_tmpfs_overlay stop_for_normal && make_move /var_ro /var stop_for_normal

	rsync -ar /writable/var/ /var/  && rm -rf /writable/var && mkdir -p /writable/var

    fi
}

stop_for_overlay_start(){
    test -f $TMP_NORMAL_MODE_STOP || return 0
    test -f $TMP_NORMAL_MODE_START && return 0

    rootfs_is_rw || remount_rootfs_rw 0
    set_fstab_rootfs_rw 1
    set_fstab_bootfs_rw 1

    make_move /var /var_ro stop_for_overlay
    make_move /var_tmpfs_overlay /var stop_for_overlay || mkdir /var

    test -d /cache || mkdir /cache
    test -d /writable || mkdir /writable

    rm -rf $TMP_NORMAL_MODE_STOP
}

save_var_overlay_cache(){
    test -f $TMP_DEPLOY && return 0 
    test -f $TMP_NORMAL_MODE_STOP && return 0

    log_daemon_msg "save /cache/var to /writable/var"
    rsync -ar /cache/var/ /writable/var
    make_umount /var
}
    
save_other_overlay_cache(){
    log_daemon_msg "save /cache/opt to /writable/opt"
    rsync -ar /cache/opt/ /writable/opt
    make_umount /opt
    
    log_daemon_msg "save /cache/root to /writable/root"
    save_user /cache/root /writable/root
    make_umount /root

    log_daemon_msg "save /cache/home_<user name> to /writable/home_<user_name>"
    for user_name in $USERS_LIST
    do
        save_user /cache/home_"$user_name" /writable/home_"$user_name"
    	make_umount /home/"$user_name"
    done
}

do_stop(){
    save_other_overlay_cache
    save_var_overlay_cache
    stop_for_normal_start
    stop_for_overlay_start
    
    log_daemon_msg "umount /cache"
    make_umount /cache
    
    log_daemon_msg "umount /writable"
    make_umount /writable
}


case "$1" in

    start|"")
	do_start
	exit $?
	;;

    stop)
	do_stop
	exit $?
	;;

    status)
	df -h --output | egrep '(/var$)|(/opt$)|(/cache$)|(/writable$)|(Filesystem\s*Type\s*Inodes\s*IUsed\s*IFree)'
	exit $?
	;;

    normal)
	start_normal_mode
	exit $?
	;;

    deploy)
	log_begin_msg "Deploy the cached version docker"
        do_deploy
	log_end_msg $?
	;;

    reload|force-reload|restart)
	echo "Only start, stop, status, deploy, normal are supported at current time"
	exit 1
	;;


    *)
        echo "Usage: ${0:-} {start|stop|status|deploy|normal}" >&2
        exit 1
	;;

esac
