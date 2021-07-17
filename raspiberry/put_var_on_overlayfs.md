### Linux sysv init sequence

refer

 - [zh_CN: Linux 系统启动的演进模型与发展变化](https://www.codenong.com/cs106070891/) 
 - [zh_CN: Linux 启动过程分析 （SysV init启动模式）](https://blog.csdn.net/yellowblue2/article/details/78745172) 
 - [zh_CN: Linux根文件之SysV系统启动方式总结](https://blog.csdn.net/wade_510/article/details/71946271)
 - [wikipedia: linux startup process](https://en.wikipedia.org/wiki/Linux_startup_process) 
 - [wikipedia: initial ramdisk](https://en.wikipedia.org/wiki/Initial_ramdisk) 
 - [quora: What-exactly-is-the-initramfs-program](https://www.quora.com/What-exactly-is-the-initramfs-program-in-Linux-Is-it-a-script-binary-or-what) 
 - [stackexchange: why do i need initramfs](https://unix.stackexchange.com/questions/122100/why-do-i-need-initramfs) 
 - [debian.org: initramfs](https://wiki.debian.org/initramfs)

In a brief: Grub load linux kernel and the initramfs, then the kernel init the hardware and itself, initramfs is a temporary / filesystem before the real / is mounted. initramfs can provide the kernel modules and other needed info and tool for kernel before it mount the real /.
There is a /init script in the initramfs, it's the first program the kernel is called. here is [a detailed description](http://glennastory.net/boot/initrd.html):

```
The /init file is the first program run by the kernel during initialization.

Actually, for most systems, this is a shell script. A shell script is a text file containing shell commands that is read and interpreted by the shell program which is the Unix/Linux command processor. There are several shells available, and the one that is in the initrd file system depends on which Linux distro is being used. (In fact several of the details of what happens during this stage depend on which distro is invoked.) In Fedora, the initial shell is bash, the normal system shell; in Red Hat it is NASH, and in Ubuntu it is Busybox.

(Look here for additional details about how the /init script is started.)

For current versions of Fedora (and presumably Red Hat and CentOS) the /init file is actually a symbolic link to systemd.

Whether a shell script or an executable, the initial init program does a number of things and the details vary from one distro to another. You can look at the following pages for the notes I took on a couple of common distros:

    Ubuntu 12.04
    Fedora 17
    Ubuntu 20.04
    Fedora 23 

The first two references above are older 32-bit distros; the latter two are current (at the time of this writing) 64-bit distros.

In general, the following things are accomplished by the init program running from the init RAM disk:

    The /sys and /proc file systems are mounted. These are really "pseudo" file systems. When a program opens a "file" in one of these file systems, it is really opening an interface directly into the kernel. These are thus used as mechanisms for setting kernel parameters ("writing to a file") and retrieving kernel status ("reading from a file"). The normal file-system permissions protect the files from inappropriate access. (The "file", /proc/cmdline, mentioned below, is an example of the use of the /proc psuedo-file system.)
    The /dev file system is created and partially populated. /dev is used as the home for "special" files that describe virtually all of the I/O devices in the system.
    Init creates a set of environment variables and then parses the kernel command line and sets the environment variables accordingly. The kernel command line was passed to the kernel from the boot loader. The init script retrieves it by reading the "file" /proc/cmdline.
    A set of drivers are loaded. Drivers are generally used to provide a software interface to a specific type of hardware, such as a disk drive, mouse, etc. Because there are many more hardware devices in the world than will be used on any given computer, these drivers are normally stored in dynamic modules, meaning they are in separate files that can be loaded into the kernel when and if needed. (Not all drivers are loaded at this point, only those needed by the early system boot process.)
    The "real" root file system is now mounted. The address of this file system on disk was passed to the kernel on the kernel command line and captured above. Eventually the real root file system will be mounted on "/", but that spot is currently occupied by the initrd file system and so the real root file system is initially mounted somewhere else. (The exact mount point is dependent on which distro is being used.)
    /sys, /proc, and /dev file systems are moved to be under the "real" root file system.
    An init program is located in the "real" root file system. Several locations are checked, but generally the program is found in /sbin/init.
    The init script now executes a program that accomplishes three steps (which cannot be done directly by a shell script):
        The initrd file system is unmounted.
        The "real" root file system is mounted at "/" (it's normal location).
        The init program located in the previous step above is then executed. 
    All three of these steps are done within the same process, the process with process ID 1. At the end of this sequence the init program is running (normally /sbin/init).

    There are now several versions of this init program including:
        SysV INIT mimics the mechanism originally used in Unix System V.
        Upstart incorporates more parallelism and thus starts the system faster.
        Systemd is another attempt at a more parallel startup mechanism. 

    Which version of init is run depends on the distro, but most modern distros, are now using systemd. 
```
