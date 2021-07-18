#!/bin/bash

### BEGIN INIT INFO
# Provides: cached_docker
# Required-Start: $all
# Required-Stop: $remote_fs $syslog
# Required-Stop: 
# Default-Start: 2 3 4 5
# Default-Stop: 0 6
# Short-Description: put docker's root dir to a cache fs
# Description:
### END INIT INFO

BASE_DIR=/docker
CACHE_DIR=/cache/docker
ROOTFS_PARTITION=/dev/rootfs
ROOTFS_PARTITION_ALIAS=/dev/mmcblk0p2
DEBUG=0 #0 print debug info. other, ignore debug

# Get lsb functions
. /lib/lsb/init-functions

# if $ROOTFS_PARTITION if mounted as rw, return 0 (true), else return 1 (false)
function rootfs_is_rw(){
    grep "[[:space:]]rw[[:space:],]" /proc/mounts  |egrep "($ROOTFS_PARTITION)|($ROOTFS_PARTITION_ALIAS)" >/dev/null
    rslt=$?
    echo $rslt
    return $rslt
}
ROOTFS_MNT_RW=$(rootfs_is_rw)

function remount_rootfs_rw(){
    MNT_TYPE=$1

    if [ "$MNT_TYPE" = 1 ]
    then
        mount -o remount,ro $ROOTFS_PARTITION /
    else
        mount -o remount,rw,noatime,nodiratime $ROOTFS_PARTITION /
    fi
}

function restore_rootfs_mount_type(){
    current_mnt_rw=$(rootfs_is_rw)
    echo $ROOTFS_MNT_RW $current_mnt_rw
    if [ "$cuurent_mnt_rw" != "$ROOTFS_MNT_RW" ]
    then
        remount_rootfs_rw $ROOTFS_MNT_RW
    fi
}

# In bash,
# 0 means true
# not 0 means false
function config_need_update(){
    ROOT_DIR=$1

    # check is /etc/docker/daemon.json need to update
    if [ -f /etc/docker/daemon.json ]
    then
        rslt=$(cat /etc/docker/daemon.json | grep "data-root" |sed "s/.*data-root.*: *\"\(.*\)\".*/\1/g")
        if [ $rslt = $ROOT_DIR ]
        then
            return 1
        fi
    fi

    return 0
}

function update_config(){
    ROOT_DIR=$1

    # update docker root dir if /etc/docker/daemon.json is not exists
    rootfs_is_rw || remount_rootfs_rw 0
    if [ ! -f /etc/docker/daemon.json ]
    then 
    
        cat <<EOT > /etc/docker/daemon.json
{ 
   "data-root": "$ROOT_DIR" 
}
EOT
    else
        sed -i "s,\"data-root\": *.*,\"data-root\": \"$ROOT_DIR\",g"  /etc/docker/daemon.json
    fi
}

# In bash,
# 0 means true
# not 0 means false
function docker_is_live(){
    docker images >/dev/null 2>&1
    if [ $? -ne 0 ]
    then
        return 1
    fi

    if [ -f /var/run/docker.pid ]
    then
        return 0
    else
        return 1
    fi
}

function operate_docker(){
    OPERATION=$1

    if [ $DEBUG -eq 0 ]
    then
        /etc/init.d/docker $OPERATION
    else
        /etc/init.d/docker $OPERATION >/dev/null 2>&1
    fi

}

function purge_cached_docker(){
    docker_is_live || operate_docker start 

    test $DEBUG -eq 0 && echo "cleaning up the the existing containers ..."
    for container_id in $(docker ps --format '{{.ID}}' 2>/dev/null)
    do
	docker stop $container_id >/dev/null 2&>1
	docker rm $container_id >/dev/null 2&>1
    done
    
    for container_id in $(docker ps -a --format '{{.ID}}' 2>/dev/null)
    do
	docker rm $container_id >/dev/null 2&>1
    done

    # stop docker service
    docker_is_live && operate_docker stop

    # make sure a clean cache dir is exists
    test $DEBUG -eq 0 && echo "deleting root_data_dir of the cached varsion docker ..."
    rm -rf $CACHE_DIR/* >/dev/null 2&>1
}


function deploy_cached_docker(){
    docker_is_live && operate_docker stop

    # make sure a clean cache dir is exists
    mkdir -p $CACHE_DIR && rm -rf $CACHE_DIR/*

    image_layers_id=$(cat $BASE_DIR/base_layers_list.txt)
    
    # copy all files except for the images layers
    test $DEBUG -eq 0 && echo "deploying the new version cache from /docker"
    for layer_id in $(echo $image_layers_id)
    do
        PARAMS="$PARAMS --exclude=overlay2/$layer_id"
    done
    rsync -ar --delete $PARAMS $BASE_DIR/ $CACHE_DIR/
    
    
    # link all the docker images layers to cache dir
    for layer_id in $image_layers_id
    do
        ln -s $BASE_DIR/overlay2/$layer_id $CACHE_DIR/overlay2/$layer_id
    done

    # It's strange, we must to stop and start again to see the docker images.
    # A sleep is also needed before start. 
    # or, there will be a error: The unit docker.service has entered the 'failed' state with result 'start-limit-hit
    # looks like the firewll or the fucking systemd was set a limit in somewhere.
    operate_docker start
}


function check_baselayers_list(){
    # get images' layers list
    if [ ! -f $BASE_DIR/base_layers_list.txt ]
    then
	test $DEBUG -eq 0 && echo $BASE_DIR/base_layers_list.txt is not found, please run "/etc/init.d/cache_docker.sh deploy" first.
	exit 1
    fi
}

function analysis_image_baselayers(){
    docker_is_live || operate_docker start

    image_layers_id=""
    for image_id in $(docker images --format '{{.ID}}' |xargs)
    do
	for layer_id in $(docker inspect $image_id |grep LowerDir |sed 's#\s*"LowerDir": "\(.*\)",#\1#g' |sed 's#/diff# #g' |sed 's#:##g')
	do
	    layer_id=$(echo $layer_id |awk -F '/' '{print $(NF)}')
	    image_layers_id="$image_layers_id $layer_id"
	done
    done
    echo $image_layers_id
}

function update_baselayers_list(){
    new_base_layers=$(analysis_image_baselayers)

    if [ -f $BASE_DIR/base_layers_list.txt ]
    then
        old_base_layers=$(cat $BASE_DIR/base_layers_list.txt |xargs)
        if [ "$new_base_layers" = "$old_base_layers" ]
        then
            return
        fi
    fi

    rootfs_is_rw || remount_rootfs_rw 0
    echo $new_base_layers > $BASE_DIR/base_layers_list.txt
}


case "$1" in
    start)
	log_begin_msg "Starting cached version docker"
	check_baselayers_list
	deploy_cached_docker

	log_end_msg $?
	;;

    restart)
	log_begin_msg "Restarting cached version docker"

	check_baselayers_list

        purge_cached_docker
	deploy_cached_docker

	log_end_msg $?
	;;

    stop)
	log_begin_msg "Stopping cached version docker"

        purge_cached_docker

	log_end_msg $?
	;;

    deploy)
	log_begin_msg "Deploy the cached version docker"

	config_need_update $BASE_DIR && update_config $BASE_DIR
        update_baselayers_list

	config_need_update $CACHE_DIR && update_config $CACHE_DIR
        restore_rootfs_mount_type

        purge_cached_docker
	deploy_cached_docker

	log_end_msg $?
	;;

    active|enable)
	log_begin_msg "Active the deployed cached version docker"

	check_baselayers_list

	config_need_update $CACHE_DIR && update_config $CACHE_DIR
        restore_rootfs_mount_type

        purge_cached_docker
	deploy_cached_docker

	log_end_msg $?
	;;

    restore)
	log_begin_msg "Restore docker to it's original setting"

        purge_cached_docker
	config_need_update $BASE_DIR && update_config $BASE_DIR

        rootfs_is_rw || remount_rootfs_rw 0
	operate_docker start

	log_end_msg $?
	;;

    *)
	exit 3
	;;

esac
