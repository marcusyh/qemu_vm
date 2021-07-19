continued from [the learning notes of sdcard](https://github.com/marcusyh/system/blob/master/raspiberry/sdcard.md)

## LSB of init script

[How to LSBize an Init Script](https://wiki.debian.org/LSBInitScripts)

[wikipedia](https://en.wikipedia.org/wiki/Linux_Standard_Base#cite_note-2)

#### LSB official doc: System Initialization

[20.1. Cron Jobs](https://refspecs.linuxbase.org/LSB_3.1.1/LSB-Core-generic/LSB-Core-generic/sysinit.html)

[20.2. Init Script Actions](https://refspecs.linuxbase.org/LSB_3.1.1/LSB-Core-generic/LSB-Core-generic/iniscrptact.html)

[20.3. Comment Conventions for Init Scripts](https://refspecs.linuxbase.org/LSB_3.1.1/LSB-Core-generic/LSB-Core-generic/initscrcomconv.html)

[20.4. Installation and Removal of Init Scripts](https://refspecs.linuxbase.org/LSB_3.1.1/LSB-Core-generic/LSB-Core-generic/initsrcinstrm.html)

[20.5. Run Levels](https://refspecs.linuxbase.org/LSB_3.1.1/LSB-Core-generic/LSB-Core-generic/runlevels.html)

[20.6. Facility Names](https://refspecs.linuxbase.org/LSB_3.1.1/LSB-Core-generic/LSB-Core-generic/facilname.html)

[20.7. Script Names](https://refspecs.linuxbase.org/LSB_3.1.1/LSB-Core-generic/LSB-Core-generic/scrptnames.html)

[20.8. Init Script Functions](https://refspecs.linuxbase.org/LSB_3.1.1/LSB-Core-generic/LSB-Core-generic/iniscrptfunc.html)


## scripts
### put /var and /opt to tmpfs by overlayfs

[code](https://github.com/marcusyh/system/blob/master/raspiberry/etc/init.d/tmpfs_overlay.sh)

By this script to create a /var directory and make all the write operation happens on the tmpfs' directory /cache/var
```
  /var_ro       ... lowerdir, readly
  /writable/var ... lowerdir, read and write
  /cache/var    ... upperdir, tmpfs
```

The header of this script
```
### BEGIN INIT INFO
# Provides: var opt
# Required-Start: mountkernfs udev eudev
# Required-Stop: umountfs
# Default-Start: S
# Default-Stop: 0 6
# Short-Description:  mount /var and /opt to overlayfs
# Description:
### END INIT INFO
```

Some other /etc/init.d/ scripts's header need to update:
```
/etc/init.d/keyboard-setup.sh:# Required-Start:    mountkernfs var
/etc/init.d/mountdevsubfs.sh:# Required-Start:    mountkernfs var
/etc/init.d/procps:# Required-Start:    mountkernfs var $local_fs
/etc/init.d/bootlogd:# Required-Start:    mountdevsubfs var
/etc/init.d/rsyslog:# Required-Stop:     umountnfs $time var
/etc/init.d/networking:# Required-Start:    mountkernfs $local_fs urandom var
/etc/init.d/rpcbind:# Required-Stop:     $network $local_fs var
```

add to or remove from the system's sysv init:
```
update-rc.d cache_docker.sh defaults
update-rc.d cache_docker.sh remove
```

### put docker to tmpfs by overlayfs

[code](https://github.com/marcusyh/system/blob/master/raspiberry/etc/init.d/cache_docker.sh)

docer will report an error when put /var/lib/docker to a overlay dir, so, copy and symbolink is used.

header of script.
```
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
```

No other /etc/init.d/ scripts's header need to update.


add to or remove from the system's sysv init:
```
update-rc.d cache_docker.sh defaults
update-rc.d cache_docker.sh remove
```
