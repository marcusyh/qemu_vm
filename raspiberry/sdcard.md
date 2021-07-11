### life time cycle of sdcard

sdcard's block has very limited life time [link](https://www.zhihu.com/question/21419030). So, we need to prepare for the broken down time of the sdcard.

[wkikpedia: Wear leveling](https://en.wikipedia.org/wiki/Wear_leveling)


### UBIFS is the soluation

[Choice of filesystem for GNU/Linux on an SD card](https://superuser.com/questions/248078/choice-of-filesystem-for-gnu-linux-on-an-sd-card)

[UBIFS - UBI File-System](http://www.linux-mtd.infradead.org/doc/ubifs.html)


### It's time costing to let UBIFS works
[How to use JFFS2 or UBIFS to avoid data corruption and increase life of the SD card?](https://raspberrypi.stackexchange.com/questions/11932/how-to-use-jffs2-or-ubifs-to-avoid-data-corruption-and-increase-life-of-the-sd-c)


### simple salution

#### use ext2
```
I was facing the same problem and did some research as well. Eventually I decided to go with ext2.

It seems that some SDHC cards implement their own wear-leveling at the hardware layer. If you can get hold of SDHC cards that have wear-leveling buit-in.

Filesystems that provide wear-leveling can interfere with the Flash-level wear-leveling so it can actually be bad for the flash to use them (the IBM article cited above talks about how JFFS does it, so it's clear that that won't work with flash-level WL). I decided I didn't need ext3's journaling since I'm not storing critical data on it and I usually backup regularly anyway (cron).

I also mounted /tmp and /var as tmpfs to speed things up. If you have enough RAM you should do that (but be sure to rotate or delete your logs regularly)

HINT: Mount your ext SD cards with the "noatime" option
```
--- by Khaled at [link](https://superuser.com/questions/248078/choice-of-filesystem-for-gnu-linux-on-an-sd-card)

#### use read only file system such as unionFS
[How to make your Raspberry Pi file system read-only (Raspbian Stretch)](https://medium.com/@andreas.schallwig/how-to-make-your-raspberry-pi-file-system-read-only-raspbian-stretch-80c0f7be7353)

#### ext2 solution

  - disable ext4 journaling [link](https://foxutech.com/how-to-disable-enable-journaling/)
```
tune2fs -O ^has_journal /dev/sda2
e2fsck -f /dev/sda2
```
There is no tune4fs on debian 10, use tune2fs insteed.

  - add `noatime,nodiratime` flag to mount option [link](https://blog.51cto.com/lee90/2376385)
  
  - mount ~/.cache and /tmp as tmpfs
```
tmpfs                   /tmp            tmpfs   mode=1777,nosuid,nodev          0       0
tmpfs                   /root/.cache    tmpfs   mode=1777,nosuid,nodev          0       0
```
  - 

