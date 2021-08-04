#### There is a project [worproject](https://worproject.ml/)

It's possible to install windows10 on raspberry pi4. Should be closely follow the official tutorial. The windows version 19041 maybe better than 19043, I'm not very sure.

The english version win10 seems works normally. The chinese version will crash soon. Maybe coused by QQ or the Chinese MUI. It's just my guess. Change to A1 SSD card won't help.

The performance is not bad, it can be used as a work environment.

#### Setting of raspberrypi

The raspberrypi boot loader should be update by `raspberrypi imager` [link](https://www.raspberrypi.org/documentation/hardware/raspberrypi/booteeprom.md)

The windows default memory size is 3G, it can be changed by the boot loader's setting.


#### Setting of windows.

There is **FreeNFS** software can be used as nfs server on windows, to share file to linux by NFS protocol. A 'RPC' error always occure, followed all the steps by searching, it still not work. 

Windows's cifs protocol works normally and is easy to setting.


#### The crash

I've give up. 

