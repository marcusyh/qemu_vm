
## ddcutil

#### /boot/config.txt
```
dtparam=i2c_vc=on
dtoverlay=vc4-kms-v3d
```
or 
```
dtparam=i2c_vc=on
dtoverlay=vc4-kms-v3d-pi4
```
do not use ```vc4-fkms-v3d```

- There are 3 kms mode, described by [this link](https://www.raspberrypi.org/forums/viewtopic.php?t=260994):
    - "legacy" mode, the legacy 3D driver which runs on the VPU and avoids all the usual linux mechanisms, videocore firmware manages everything.
    - "full kms" mode, v3d is the videocore 3D driver for the standard mesa/linux 3D stack that runs on the CPU, the kernel manages everything.
    - "fake kms mode", kernel selects the screen mode(s) for the screen(s) but the videocore firmware manages the video output path.

- For detail of the description of etch config.txt item, refer these links: 
    - [raspberrypi firmware boot overlays](https://raw.githubusercontent.com/raspberrypi/firmware/master/boot/overlays/README)
    - [config.txt manual](https://www.raspberrypi.org/documentation/configuration/config-txt/) 
    - [Device Trees, overlays, and parameters](https://www.raspberrypi.org/documentation/configuration/device-tree.md)


#### /etc/modules

add follow line
```
i2c-dev
```

#### /etc/udev/rules.d/99-i2c.rules

```
SUBSYSTEM=="i2c-dev", MODE="0666"
```

#### reference links:

 - [How to activate Raspberry-pi’s i2c bus](https://openest.io/en/2020/01/18/activate-raspberry-pi-4-i2c-bus/)
 - [i2c-dev does not create an i2c-* in /dev](https://www.raspberrypi.org/forums/viewtopic.php?f=29&t=203990)
 - [Enable I2C Interface on the Raspberry Pi](https://www.raspberrypi-spy.co.uk/2014/11/enabling-the-i2c-interface-on-the-raspberry-pi/)
 - [config i2c](https://github.com/fivdi/i2c-bus/blob/master/doc/raspberry-pi-i2c.md)
 - [stackexchange](https://raspberrypi.stackexchange.com/questions/116726/enabling-of-i2c-0-via-dtparam-i2c-vc-on-on-pi-3b-causes-i2c-10-i2c-11-t)
 - [ddcutil config and debug](https://www.ddcutil.com/config/)
 - [ddcutil on raspberrypi](https://www.ddcutil.com/raspberry/)
 - [build linux kernel for raspberrypi](https://www.raspberrypi.org/documentation/linux/kernel/building.md) 
 - [Compiling Loadable Kernel Module](https://www.raspberrypi.org/forums/viewtopic.php?t=265682)
 - [to solve git clone always fails with “Failed sending HTTP request”](https://stackoverflow.com/questions/65556397/git-clone-always-fails-with-failed-sending-http-request) by command `apt reinstall libcurl3-gnutls/stable`
