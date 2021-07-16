Systemd is hard to use, so, I'm converting to devuan.

### Install

The official devuan is providing [a trial version of arm64](https://arm-files.devuan.org/).

Install it follow [the instruction](https://arm-files.devuan.org/README.txt).

I've already has a sdcard with debian10 in it, so, just need to copy the files to the related parittion. refer [this link](https://unix.stackexchange.com/questions/316401/how-to-mount-a-disk-image-from-the-command-line)
```
The offset value is in bytes, whereas fdisk shows a block count, so you should multiply the value from the "Begin" or "Start" column of the fdisk output by 512 (or whatever the block size is) to obtain the offset to mount at.
```
```
unzip devuan_beowulf_3.1.0_arm64_rpi4.img
fdisk -lu devuan_beowulf_3.1.0_arm64_rpi4.img
mount -o loop,offset=1048576 devuan_beowulf_3.1.0_arm64_rpi4.img /tmp/sda1
mount -o loop,offset=268435456 devuan_beowulf_3.1.0_arm64_rpi4.img /tmp/sda2
```

### boot

The default user/passwd is pi/board
```
sudo su -
run_setup
```

For keyboard configuration, run ```dpkg-reconfigure keyboard-configuration```. I'm using hhkb, some choose 'happy hacking', then 'us', all the following pages just choose the default.

Uninstall the not needed packages, install the needed ones.

uninstall all the non-free packages. (just work for me)

set up /etc/network/interface to proper values.

change root's password

change the default pi user's password, revert the supper permission from it. Follow [the official guide](https://www.raspberrypi.org/documentation/configuration/security.md).

install ntp 

reboot the system.


### configure it as a Router

just follow [this guide](https://gridscale.io/en/community/tutorials/debian-router-gateway/) 

install arno-iptables-firwall, and follow the guide to config it.


### Install docker
Follow [docker official guide](https://docs.docker.com/engine/install/debian/)

There will be an error like
```
E: The repository 'https://download.docker.com/linux/debian beowulf Release' does not have a Release file.
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
N: See apt-secure(8) manpage for repository creation and user configuration details.
```
change /etc/apt/sources.list.d/docker.list to following and try again.
```
deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian  buster stable
```
