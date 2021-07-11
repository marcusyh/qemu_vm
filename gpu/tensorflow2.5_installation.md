debian 10 and devuan 2's default nvidia driver is 460.73 and the default cuda-toolkit version is 11.2.2.

the installation location of cuda-toolkit like
```
/usr/lib/nvidia-cuda-toolkit
/usr/lib/nvidia-cuda-toolkit/bin
/usr/lib/nvidia-cuda-toolkit/bin/cicc
/usr/lib/nvidia-cuda-toolkit/bin/crt
/usr/lib/nvidia-cuda-toolkit/bin/crt/link.stub
/usr/lib/nvidia-cuda-toolkit/bin/crt/prelink.stub
/usr/lib/nvidia-cuda-toolkit/bin/g++
/usr/lib/nvidia-cuda-toolkit/bin/gcc
/usr/lib/nvidia-cuda-toolkit/bin/nvcc
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/include
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/include/generated_cudaGL_meta.h
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/include/generated_cudaVDPAU_meta.h
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/include/generated_cuda_gl_interop_meta.h
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/include/generated_cuda_meta.h
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/include/generated_cuda_profiler_api_meta.h
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/include/generated_cuda_runtime_api_meta.h
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/include/generated_cuda_vdpau_interop_meta.h
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/include/sanitizer.h
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/include/sanitizer_callbacks.h
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/include/sanitizer_driver_cbid.h
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/include/sanitizer_memory.h
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/include/sanitizer_patching.h
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/include/sanitizer_result.h
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/include/sanitizer_runtime_cbid.h
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/include/sanitizer_stream.h
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/libInterceptorInjectionTarget.so
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/libTreeLauncherPlaceholder.so
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/libTreeLauncherTargetInjection.so
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/libTreeLauncherTargetUpdatePreloadInjection.so
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/libsanitizer-collection.so
/usr/lib/nvidia-cuda-toolkit/compute-sanitizer/libsanitizer-public.so
/usr/lib/nvidia-cuda-toolkit/libdevice
```

but by the guide of cudnn's installation. the cudnn file should copy to:
```
$ sudo cp cuda/include/cudnn*.h /usr/local/cuda/include 
$ sudo cp -P cuda/lib64/libcudnn* /usr/local/cuda/lib64 
$ sudo chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn*
```

I'm not sure where is the lib64 directory of cuda. So, for a lazy person, it's maybe a good idea to install all the components from nvidia's source. 


So, let's begin:

### Follow Tensorflow's guide.
[tensorflow](https://www.tensorflow.org/install/gpu)


### Install the driver
Download driver from [link](https://www.nvidia.com/en-us/drivers/unix/linux-amd64-display-archive/)

I have a latest nvidia gpu card. So, any of driver 460, 465, 470 can be my choice. but the the 470 marked as 'beta', so, for the stability, I choosed 460.84.
  

### Check the compatibility of cuda and driver
[cuda relase note](https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html)

[cuda-compatibility](https://docs.nvidia.com/deploy/cuda-compatibility/index.html)

[cuda-compatibility-and-upgrades](https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html#cuda-compatibility-and-upgrades)

For Corresponding compatibility, cuda11.2.2 maybe a better choice.

[The CUDA download link](https://developer.nvidia.com/cuda-toolkit-archive)


### choose cudnn
[cudnn and cuda compatibility matrix](https://docs.nvidia.com/deeplearning/cudnn/support-matrix/index.html)

it seems that 8.2.2 is a nice choice.

[latest version download link](https://developer.nvidia.com/rdp/cudnn-download)

[older version download link](https://developer.nvidia.com/rdp/cudnn-download)

[cudnn installation guide](https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html)


### choose tensorRT
for TensorRT, I've choosed the latest version [link](https://developer.nvidia.com/nvidia-tensorrt-download)

For 8.0.x, GA means Genearal Acesss. EA means Easy Access.

[tensorRT installation guide](https://docs.nvidia.com/deeplearning/tensorrt/archives/tensorrt-801/quick-start-guide/index.html#install)


### Prepare installation
 - uninstall linux kernel 4.19
 - install linux kernel 5.10, it's header file
 - install linux kernel 5.10 source package.
 - disable nouveau
```
echo -e "blacklist nouveau\noptions nouveau modeset=0" > /etc/modprobe.d/blacklist.conf
reboot
```

### run nvidia driver installer.

If there is a error like the flowing, the linux header package is need to install
```
ERROR：Unable to find the kernel source tree for the currently running kernel. Please make sure you have installed the kernel source files for your kernel and that they are properly configured on Red Hat Linux system, for exzmple ,be sure you have the 'kernel-source' or 'kernel-devel' RPM installed .If you know the correct kernel source files are installed ,you may specify the kernel source path with the '--kernel-source-path' command line option.
```
[refer link](https://www.nvidia.com/en-us/geforce/forums/geforce-graphics-cards/5/285883/problem-to-install-driver/)

There was a warning 
```
WARNING: nvidia-installer was forced to guess the X library path '/usr/lib' and X module path '/usr/lib/xorg/modules'; these paths were not queryable from the system.  If X fails to find the NVIDIA X driver module, please install the `pkg-config` utility and the X.Org SDK/development package for your distribution and reinstall the driver. 
```
It is not a matter for me. i don't need x. 

There is another error:
```
WARNING: Unable to find a suitable destination to install 32-bit compatibility libraries. Your system may not be set up for 32-bit compatibility. 32-bit compatibility files will not be installed; if you wish to install them, re-run the installation and set a valid directory with the --compat32-libdir option.
```

### run cuda toolkit installer.
follow the official [cuda installation guide](https://docs.nvidia.com/cuda/archive/11.2.2/cuda-installation-guide-linux/index.html)

The installation finished popup summary info:
```
Driver:   Installed
Toolkit:  Installed in /usr/local/cuda-11.2/
Samples:  Installed in /root/, but missing recommended libraries

Please make sure that
 -   PATH includes /usr/local/cuda-11.2/bin
 -   LD_LIBRARY_PATH includes /usr/local/cuda-11.2/lib64, or, add /usr/local/cuda-11.2/lib64 to /etc/ld.so.conf and run ldconfig as root

To uninstall the CUDA Toolkit, run cuda-uninstaller in /usr/local/cuda-11.2/bin
To uninstall the NVIDIA Driver, run nvidia-uninstall
Logfile is /var/log/cuda-installer.log
```

#### install cudnn
follow the office [cudnn installation guide]() to install and verify the installation.

the cudnn tgz file doesn't have the exmaples used to verify the installation. So, use the rpm or deb version of sample package. I've choose the [libcudnn8-samples_8.2.2.26-1+cuda11.4_amd64.deb](https://developer.nvidia.com/compute/machine-learning/cudnn/secure/8.2.2/11.4_07062021/Ubuntu18_04-x64/libcudnn8-samples_8.2.2.26-1+cuda11.4_amd64.deb) package for my system.

unpack it:
```
dpkg-deb -R original.deb tmp
```
Then, follow the official [verify steps](https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#verify)

I've met a error like when compiling the sample code:
```
test.c:1:10: fatal error: FreeImage.h: No such file or directory             
 #include "FreeImage.h"
```
Just install the libfreeimage by ```apt-get install libfreeimage3 libfreeimage-dev```, please refer [this link](https://forums.developer.nvidia.com/t/freeimage-is-not-set-up-correctly-please-ensure-freeimae-is-set-up-correctly/66950)


### install TensorRT
follow the [official guide](https://docs.nvidia.com/deeplearning/tensorrt/install-guide/index.html) to install and verify tensorRT

