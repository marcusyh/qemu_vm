To choose a web based vm management software. I use kvm and qemu. There is a list on [kvm's office list](http://www.linux-kvm.org/page/Management_Tools).

## Software List

It's for personal usage, so, i need it as simple as possible:

#### Local UI
- [AQemu](https://sourceforge.net/projects/aqemu/): Qemu's qt UI
- [GKVM](http://gkvm.sourceforge.net/): Qemu's gtk UI
- [Virt-manager](https://virt-manager.org/): virsh and libvirt's UI.


#### CLI
- [kvmadm](https://code.google.com/archive/p/kvmadm/): A minimalistic administrative suite to control multiuser usage of KVM
- [kvm-admin](http://www.linux-kvm.org/page/Kvmtools): Python scripts for managing the guests (boot, shutdown ...) and include a commandline monitor . 
- [kvm-wrapper](https://codewreck.org/kvm-wrapper/): kvm-wrapper is a lightweight, simple and intended to be hackable set of shell scripts that help manage kvm virtual machines a great deal.
- [nbsvm](https://github.com/ChoHag/nbsvm): shell script used to manage vm, only core function, on other bullshit.
- [virsh](https://libvirt.org/): A minimal shell around libvirt for managing VMs 
- [Virt-manager](https://virt-manager.org/): virt-manager have a cli mode.
- [vmmaestro](https://github.com/mzch/vmmaestro): a simple command line tool to start, shutdown VMs and help to connect to the screens from your client PC, by pure shell script 


#### Web UI
- [kimchi](https://github.com/kimchi-project/kimchi): Web based, works as a plugin as work, pure pythonic, cherry framework based.
- [WebVirtMgr](http://retspen.github.io/): libvirt-based Web interface for managing virtual machines. django framework based.
- [phpvirtualbox](https://wiki.archlinux.org/title/PhpVirtualBox): phpVirtualBox is an open source, AJAX implementation of the VirtualBox user interface written in PHP. As a modern web interface, it allows you to access and control remote VirtualBox instances. Much of its verbage and some of its code is based on the (inactive) vboxweb project. phpVirtualBox was designed to allow users to administer VirtualBox in a headless environment - mirroring the VirtualBox GUI through its web interface. 


#### Other
- [Kubvirt](https://kubevirt.io/): Virtualization API for Kubernetes 
- [cloonix](http://clownix.net/doc_stored/build-16-00/html/index.html): Focus on network simulation


#### server
- [ovirt](https://ovirt.org/): headless vm server by kvm and libvirt.


## docker version of kimchi

#### kimchi vs WebVirtMgr
 - [link1](https://www.linuxquestions.org/questions/linux-virtualization-and-cloud-90/web-kvm-management-4175509506/) WebVirtMgr is a libvirt-based Web interface to manage kvm virtual machines and support almost all basic vm lifecycle tasks, If need more feature-rich alternative, look for Kimchi Project.

#### My choice
Maybe virt-manager is much easier to deploy for my situation. But, the customer, my wife want a webpage version. I prefer webVirtMgr if installing on the host directly. But dockerlized kimchi seems a better idea. Clean, feature rich, pythonic. Excellent.

#### refer link
- [How to launch qemu-kvm from inside a Docker container?](https://stackoverflow.com/questions/48422001/how-to-launch-qemu-kvm-from-inside-a-docker-container)
- [Privileged Docker containers—do you really need them?](https://snyk.io/blog/privileged-docker-containers/)
- [Using Docker Machine with KVM and Libvirt](https://blog.scottlowe.org/2017/11/24/using-docker-machine-kvm-libvirt/)

so, use `--device=/dev/kvm` rather than `--privileged`

#### existing docker file
- [tylerszabo's solution](https://github.com/kimchi-project/kimchi/issues/1108)
- [ptylenda's solution](https://github.com/ptylenda/kimchi-docker/blob/master/Dockerfile)
- [mbentley's solution](https://github.com/mbentley/docker-kimchi/blob/master/Dockerfile)

