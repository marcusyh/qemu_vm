##### create image:
```
qemu-img create -f qcow2 00.beowulf_pure.qcow2 100G
```


##### create image by backing image:
```
qemu-img create -f qcow2 -b 01.00.nvidia460.73_cuda11.2.2.qcow2 -F qcow2 02.01.00.python_tensorflow_gpu.qcow2
```

##### shrink size
in linux guest:
```
dd if=/dev/zero of=/tmp/test
rm -rf /tmp/test
```
in windows guest:
```
sdelete64 -z c:
sdelete64 -z d:
...
```
on the host:
```
qemu-img convert -O qcow2 -B 00.beowulf_pure.qcow2 01.00.nvidia460.73_cuda11.2.2.qcow2.ori 01.00.nvidia460.73_cuda11.2.2.qcow2
```
