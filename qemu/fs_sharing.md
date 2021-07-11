### TL;DR

There is a question at [superuser](https://superuser.com/questions/628169/how-to-share-a-directory-with-the-host-without-networking-in-qemu)

qumu-system parameter:
```
-virtfs local,path=/path/to/share,mount_tag=host0,security_model=passthrough,id=host0
```

guest mount:
```
mount -t 9p -o trans=virtio,version=9p2000.L,msize=33554432 host0 /mnt/mount_point_name
```

or in fstab
```
host0   /wherever    9p      trans=virtio,version=9p2000.L,size=33554432   0 0
```

The description of msize [link](https://wiki.qemu.org/Documentation/9psetup#msize)


### Official document of 9pfs
[https://wiki.qemu.org/Documentation/9psetup](https://wiki.qemu.org/Documentation/9psetup)


### kernel level 9pfs document
[https://www.kernel.org/doc/html/latest/filesystems/9p.html](https://www.kernel.org/doc/html/latest/filesystems/9p.html)
