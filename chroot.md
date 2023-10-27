# chrooting properly

have to link all the directories, it's annoying.

```bash
zack@zackarchmain ~/Documents/bash $ sudo !!
sudo ./full_chroot.sh questions/
chroot: failed to run command ‘/bin/bash’: No such file or directory
```

why can it never find /bin/bash? it's literally RIGHT THERE
in the stupid chroot dir

whatever

```bash
#!/bin/sh

# Error handling
set -e
set -o pipefail

# Check if root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Check if the chroot directory is supplied
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <chroot_directory>"
    exit 1
fi

CHROOT_DIR=$1

# Create chroot directory if it does not exist
mkdir -p $CHROOT_DIR

mkdir -p $CHROOT_DIR/{dev,proc,sys,bin}

# Mount necessary filesystems
mount --types proc /proc $CHROOT_DIR/proc
mount --rbind /sys $CHROOT_DIR/sys
mount --make-rslave $CHROOT_DIR/sys
mount --rbind /dev $CHROOT_DIR/dev
mount --make-rslave $CHROOT_DIR/dev

# force-copy /bin/bash to the chrooted env
cp -f "/bin/bash" "$CHROOT_DIR/bin"

# On script exit, unmount the bound directories
trap 'umount -R $CHROOT_DIR/dev; umount -R $CHROOT_DIR/sys; umount $CHROOT_DIR/proc' EXIT

# Change root into new environment
chroot $CHROOT_DIR /bin/bash
```
