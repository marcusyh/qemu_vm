# Linux sysv init sequence


## brief picture

 - [zh_CN: Linux 系统启动的演进模型与发展变化](https://www.codenong.com/cs106070891/)
 - [zh_CN: Linux 启动过程分析 （SysV init启动模式）](https://blog.csdn.net/yellowblue2/article/details/78745172) 
 - [zh_CN: Linux根文件之SysV系统启动方式总结](https://blog.csdn.net/wade_510/article/details/71946271)
 - [wikipedia: linux startup process](https://en.wikipedia.org/wiki/Linux_startup_process) 
![linux booting flow](https://github.com/marcusyh/system/blob/master/raspiberry/images/boot_process_01.png) 


## Grub

[grub](http://glennastory.net/boot/grub2.html)
 - grub load itself and the related modules
 - init itself
 - analysis grub.cfg
 - load kernel and initramfs
 - tel kernel the initramfs' address, and hand the controller ship to  kernel


## Kernel mode

### initramfs

 - [wikipedia: initial ramdisk](https://en.wikipedia.org/wiki/Initial_ramdisk) 
 - [quora: What-exactly-is-the-initramfs-program](https://www.quora.com/What-exactly-is-the-initramfs-program-in-Linux-Is-it-a-script-binary-or-what) 
 - [stackexchange: why do i need initramfs](https://unix.stackexchange.com/questions/122100/why-do-i-need-initramfs) 
 - [debian.org: initramfs](https://wiki.debian.org/initramfs)

initramfs is a temporary / filesystem before the real / is mounted. initramfs can provide the kernel modules and other needed info and tool for kernel before it mount the real /


### kernel init

[Kernel Initialization](http://glennastory.net/boot/linux.html)

When the kernal initilization finished, it will do the following tasks:
```
The kernel therefore creates the first task in the task queue. This task (process ID 1) is called the init task. 
The kernel then creates a second task, known as kthreadd.
The kthreadd task, running as a kernel thread then manages the other kernel threads which kthreadd creates.
The init task, also running as a kernel thread, does additional initialization.
After the above is completed, the init thread executes the program init which is found in the root directory of the initrd file system. 
```

### /init stage

There is a /init script in the initramfs, it's the first program the kernel is called. 

Here is [a detailed description](http://glennastory.net/boot/initrd.html). The folloing paragraph copied from this link for backup purpose:

```
The /init file is the first program run by the kernel during initialization. For most systems, this is a shell script. 
There are several shells available, and the one that is in the initrd file system depends on which Linux distro is being used. In Fedora, the initial shell is bash; in Red Hat it is NASH, and in Ubuntu it is Busybox. 
Whether a shell script or an executable, the initial init program does a number of things and the details vary from one distro to another. 
```
![initramfs booting /init 02](https://github.com/marcusyh/system/blob/master/raspiberry/images/boot_process_04.png)

```
In general, the following things are accomplished by the init program running from the init RAM disk: 
```
![initramfs booting /init 03](https://github.com/marcusyh/system/blob/master/raspiberry/images/boot_process_03.png)

At the last stage of /init script, the real root filesystem is mounted to /root:
```
export rootmnt=/root
```
```
        if [ -z "${ROOT}" ]; then
                panic "No root device specified. Boot arguments must include a root= parameter."
        fi
        local_device_setup "${ROOT}" "root file system"
        ROOT="${DEV}"

        # Get the root filesystem type if not set
        if [ -z "${ROOTFSTYPE}" ] || [ "${ROOTFSTYPE}" = auto ]; then
                FSTYPE=$(get_fstype "${ROOT}")
        else
                FSTYPE=${ROOTFSTYPE}
        fi

        local_premount

        if [ "${readonly?}" = "y" ]; then
                roflag=-r
        else
                roflag=-w
        fi

        checkfs "${ROOT}" root "${FSTYPE}"

        # Mount root
        # shellcheck disable=SC2086
        if ! mount ${roflag} ${FSTYPE:+-t "${FSTYPE}"} ${ROOTFLAGS} "${ROOT}" "${rootmnt?}"; then
                panic "Failed to mount ${ROOT} as root file system."
        fi
```

mount /usr if it's a seperate partitition
```
if read_fstab_entry /usr; then
        log_begin_msg "Mounting /usr file system"
        mountfs /usr
        log_end_msg
fi
```

move /proc, /dev, /run, /sys to the real root system
```
mount -n -o move /sys ${rootmnt}/sys
mount -n -o move /proc ${rootmnt}/proc
mount -n -o move /run ${rootmnt}/run
mount -n -o move /dev ${rootmnt}/dev
```

check user space /sbin/init programme
```
validate_init() {
        run-init -n "${rootmnt}" "${1}"
}       
                
# Check init is really there
if ! validate_init "$init"; then
        echo "Target filesystem doesn't have requested ${init}."
        init=
        for inittest in /sbin/init /etc/init /bin/init /bin/sh; do
                if validate_init "${inittest}"; then
                        init="$inittest"
                        break
                fi
        done    
fi           
```

relase the pusodu root fs initramfs and switch to real root fs. Use /sbin/init program to replace this script.
```
exec run-init ${drop_caps} "${rootmnt}" "${init}" "$@" <"${rootmnt}/dev/console" >"${rootmnt}/dev/console" 2>&1
```
```
./run-init --help
BusyBox v*.**.* multi-call binary.

Usage: run-init [-d CAP,CAP...] [-n] [-c CONSOLE_DEV] NEW_ROOT NEW_INIT [ARGS]

Free initramfs and switch to another root fs:
chroot to NEW_ROOT, delete all in /, move NEW_ROOT to /,
execute NEW_INIT. PID must be 1. NEW_ROOT must be a mountpoint.

        -c DEV  Reopen stdio to DEV after switch
        -d CAPS Drop capabilities
        -n      Dry run
```

## /sbin/init
### /sbin/init and /etc/inittab stage

![initramfs booting /init 04](https://github.com/marcusyh/system/blob/master/raspiberry/images/boot_process_05.png)

For devuan arm64, /sbin/init first read /etc/inittab, the inittab configure file tell /sbin/init what to do. /sbin/init program and it's configure file /etc/inittab are the main keeper to execute the initlization. 

All the other files, such as /etc/init.d/?.sh and /etc/rc?/?.sh are just some addon to the /sbin/init program.

The manual page of init and inittab have gave a very clear description. `man init` and `man inittab`.



### Just execute some dynamic addons of /sbin/init

For devuan arm64, the /etc/inittab tells the /etc/first to execute /etc/init.d/rcS. /etc/init.d/rcS is a symbolink to /lib/init.d/rcS. /lib/init/rcS infact has just one line code `/etc/init.d/rc S`, 

 - ls -l /etc/init.d/rcS
```
/etc/init.d/rcS -> /lib/init/rcS
```
 - cat /lib/init/rcS
```
exec /etc/init.d/rc S
```
 - ls -l /etc/init.d/rc
```
/etc/init.d/rc -> /lib/init/rc
```

/lib/init/rc is the main script to exec all the user space initlization, including execute all the /etc/init.d/rc?.d scripts for example.



### dynamic addons of addons

/lib/init/rc is an addon of /sbin/init and /etc/inittab

/etc/init.d/?.sh and /etc/rc?.d/?.sh are some addons of /lib/init/rc
