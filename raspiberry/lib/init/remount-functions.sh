#!/bin/sh

# if $ROOTFS_PARTITION if mounted as rw, return 0 (true), else return 1 (false)
rootfs_is_rw(){
    cat /proc/mounts  |awk '{if($2 == "/") {print $0}}' | grep "[[:space:]]rw[[:space:],]" >/dev/null
    rslt=$?
    echo $rslt
    return $rslt
}

ROOTFS_MNT_RW=$(rootfs_is_rw)
ROOTFS_PARTITION=$(awk '{if($2 == "/") {print $1}}' /proc/mounts)

remount_rootfs_rw(){
    MNT_TYPE=$1

    if [ "$MNT_TYPE" = 1 ]
    then
        mount -o remount,ro $ROOTFS_PARTITION /
    else
        mount -o remount,rw,noatime,nodiratime $ROOTFS_PARTITION /
    fi
}

restore_rootfs_mount_type(){
    current_mnt_rw=$(rootfs_is_rw)
    echo $ROOTFS_MNT_RW $current_mnt_rw
    if [ "$cuurent_mnt_rw" != "$ROOTFS_MNT_RW" ]
    then
        remount_rootfs_rw $ROOTFS_MNT_RW
    fi
}

set_inittab_roofs_rw(){
    # ro, rw
    MODE=$1

    if [ "$MODE" = 1 ]
    then
        sed -i '/PARTUUID=5e5cfa9e-02/ s/defaults,noatime,nodiratime/ro,defaults/' /etc/fstab
    else
        sed -i '/PARTUUID=5e5cfa9e-02/ s/ro,defaults/defaults,noatime,nodiratime/' /etc/fstab
    fi
}

