# syslinux setup, qemu stuff

couldn't quite get this to work yet, but here's where i'm at so far:

## background

syslinux is a dead simple BIOS bootloader.
it works simplest when you're using a single mbr partition (DOS disklabel)
formatted with a vfat fs.

it's usable off of that single partition without any weird subdirectory stuff.
everything should be top level in the boot partition (which is also the main partition)

## usage

### partitioning

```bash
sudo fdisk <path/to/disk>
```

then type 'o' to set a DOS disklabel onto the device.
partition the entire drive as a linux filesystem partition onto the DOS
mbr partitioning scheme.
type 'a' then 1 to set the first partition as bootable.
then 'w' to write, and it should be fine.

### syslinux setup

on the partitioned drive, run

```bash
syslinux --install <path/to/disk>
```

copy over whatever kernel/initramfs images you want into the mounted disk
directory.

syslinux runs live off of the syslinux.cfg, this is how it decides which
parameters to pass to the kernel.

THIS is how the bootloader influences the kernel, by passing parameters. this
is also how the rootfs is specified, either through a device name or a proper, consistent UUID.

here's an example syslinux.cfg, put into the root of the disk filesystem partition.

```
DEFAULT Linux
TIMEOUT 0
PROMPT 0

LABEL Linux
    KERNEL /vmlinuz
    APPEND root=/dev/sdXY loglevel=7 rw
```

syslinux does have support for multiple labels/kernels, but that's not shown off here.

note: loglevel param goes from 0-7, 7 being the most logs.
we could use an initramfs img here using the initrd=<path_to_initramfs.img>
kernel parameter in the APPEND statement, but that's not necessary for my build.

in most bootloaders, APPEND always means "add these params to the kernel bootup".

to specify a UUID, do

```
    APPEND root=UUID=<uuid>
```

as the kernel param. this is unrelated to the bootloader, though, it's more of
a kernel thing.
