# getting the initial kernel config

## from scratch

the 

```bash
make defconfig
```

.config file for the kernel is just a starting point. you still need to compile stuff
in, like maybe nvme support if you're running off an SSD.

if you're not compiling from an already running linux build, you can get some
sensible defaults here:

https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel#Optional:_Building_an_initramfs

in general, the gentoo wiki has a very solid guide on manual kernel compilations through the 
amd64 installation guide.

## if you're building from a running OS

from https://www.youtube.com/watch?v=VVunP3yDgm4
the kernel config of the currently running kernel is in /proc/config.gz on arch.

to setup the kernel source tree, we can just zcat /proc/config.gz > .config
right into the root of the kernel source. then, configuration works like normal
with all the usual config tui tools and make menuconfig.
