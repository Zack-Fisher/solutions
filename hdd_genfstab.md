# genfstab

## fstab

example of my fstab right now:

```
# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>
# /dev/nvme0n1p2
UUID=a8bd1e1e-f9bd-4feb-88a1-2be50162d619	/         	ext4      	rw,relatime	0 1

# /dev/nvme0n1p1
UUID=0EC2-91D4      	/boot     	vfat      	rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro	0 2

# automount the external gpt drive
# each partition has a uuid that we can get with sudo blkid <partition>
# we use that for less flimsy fstab setups.
# the blkid is generated at filesystem creation on the partition.
UUID=0082-ECD5 /mnt/drive exfat defaults 0 0
```

## genfstab

### main usage

during the arch install, it's usually used like this:

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

since the main partition is mounted to the /mnt.

we write the fstab to /etc/fstab
so that it'll mount all the UUIDs to the right places when we boot.

### breakdown

based on the passed path, genfstab will look at all the drives mounted
and their locations, and fix them  there. 

if the -U option is passed, it'll use drive UUIDs rather than the temp
names that are given when they're mounted, eg /dev/sdXY

## other UUID information

the UUID of the drive is created when the filesystem is created.
this means that the genfstab will be redone if the filesystem is recreated on a drive,
so be careful.

### getting drive UUID

use 

```bash
blkid <partition>
```

to get the UUID.
