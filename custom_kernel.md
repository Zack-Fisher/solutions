---
title: custom_kernel
date: June 17, 2023
---

# using a custom version of the linux kernel

## important: choosing a name for the build

the easiest thing to do is to use the truncated version as the name.
eg bzImage -> bzImage-640
if we're making linux 6.4.0.

grub will identify the kernel by the name in the selector.

all files should be appended with the same name!!! we need the automatic
mkinitcpio stuff to play nice, or we have to play around with the configs.

## building modules

we need kernel modules to insert into the initramfs.
so, we need to build them.

>Build the kernel modules for the initramfs:
>
> -Return to the kernel source code directory.
>
> -Run `make prepare` to prepare the build environment.
>
> -Run `make modules_prepare` to ensure the necessary dependencies are available.
>
> -Run `make modules` to build the kernel modules. This will build all the modules
>
> -specified in the initramfs_list file.

# overview

after compilation, we need to handle three files:
System.map, vmlinuz/bzImage, and the initramfs image.

System.map is a kernel symbol table used for resolution and debugging.
vmlinuz is the kernel image itself.

when moving the files over, choose a common name for the linux kernel version you're
recompiling. then, name everything
<filename> -> <filename>-<kernel_name>
so that you can easily replace and point mkinitcpio and other stuff
to the proper versions of the kernel image.

## System.map

is this necessary?

gpt says:

>No, the Linux kernel typically requires a System.map file to boot successfully.
>The System.map file contains the symbol table for the kernel, which is
>essential for resolving memory addresses and debugging purposes.

so i guess not.

after make install in the kernel directory, the System.map file should be
in the pwd.

copy that over as System.map-custom in /boot, or something.

## initramfs

more details on initramfs in
https://www.linuxfromscratch.org/blfs/view/svn/postlfs/initramfs.html

### most important thing:

from [this video](https://www.youtube.com/watch?v=VVunP3yDgm4)

we can basically skip creating the config file if it doesn't matter, and use all the default system modules.
run the command
```bash
mkinitcpio -k <full_version> -g <output_file>
```

### why is mkinitcpio called that

cpio is a file archival format.

ram images use cpio because:

>Ram images, such as initramfs or initrd, use the cpio compression format for
>several reasons:
> -Simplicity: The cpio format is straightforward and relatively easy to work
> with. It provides a simple and efficient way to package files and directories
> into a single archive.
>
> -Compatibility: The cpio format is widely supported across various Unix-like
> systems, making it a suitable choice for creating ram images that need to work
> on different platforms. The tools and libraries for handling cpio archives are
> commonly available, ensuring compatibility across different environments.
>
> -File preservation: The cpio format preserves file metadata, such as
> permissions, ownership, timestamps, and symbolic links. This is important when
> creating ram images because it allows the initramfs or initrd to accurately
> reflect the file attributes as they should be when the system boots.
>
> -Boot loader support: Many boot loaders, such as GRUB, expect the ram image to
> be in the cpio format. By using cpio compression, the ram image can be directly
> loaded and processed by the boot loader without the need for additional
> decompression steps.
>
> -Size efficiency: The cpio format provides reasonably efficient compression for
> ram images while still maintaining fast decompression speeds. This is important
> for reducing the size of the ram image, which can be crucial in constrained
> environments or during the boot process, where loading and decompression time
> can impact boot speed.

### notes

use mkinitcpio on arch to generate an initramfs image from a kernel image.
the image is loaded to boot and mount the root filesystem to /.

the image can be automatically generated based on the kernel compilation, 
but it is apparently DEPENDENT on the kernel version/build, so we need to make
it each time as part of the recompilation process.

this is an example /boot:

```
zack@zackarchmain ~/Documents/c/linux/arch/x86_64/boot $ ls /boot
EFI                grub                          vmlinuz
System.map         initramfs-linux-fallback.img  vmlinuz-custom
System.map-custom  initramfs-linux.img           vmlinuz-linux
System.old         syslinux                      vmlinuz.old
```

with some custom stuff and normal linux downloads.
the linux downloads are from the arch repos.

### configuring the image

here's an example mkinitcpio.d/custom.preset file
use the name of your kernel compilation.

```
# mkinitcpio preset file for the 'custom' package

#ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-custom"
ALL_microcode=(/boot/*-ucode.img)

PRESETS=('default' 'fallback')

#default_config="/etc/mkinitcpio.conf"
default_image="/boot/initramfs-custom.img"
#default_uki="/efi/EFI/Linux/arch-custom.efi"
#default_options="--splash /usr/share/systemd/bootctl/splash-arch.bmp"

#fallback_config="/etc/mkinitcpio.conf"
fallback_image="/boot/initramfs-custom-fallback.img"
#fallback_uki="/efi/EFI/Linux/arch-custom-fallback.efi"
fallback_options="-S autodetect"
```

### generating the image, setting up defaults

```bash
cp /etc/mkinitcpio.d/linux.preset /etc/mkinitcpio.d/<kernel_name>.preset
```

it'll read all of the presets from there, we can use this preset to generate
the ram image.

just run `%s/linux/<kernel_name>/g` in the preset file, and it should work.

then, run `mkinitcpio -p <kernel_name>` to generate the image.

it'll automatically build the ram image and a fallback image.

### notes on ram images

what's this about? what's in a ram image?

```
==> Starting build: '6.4.0-rc6-gb6dad5178cea'
  -> Running build hook: [base]
  -> Running build hook: [udev]
  -> Running build hook: [autodetect]
  -> Running build hook: [modconf]
  -> Running build hook: [kms]
  -> Running build hook: [keyboard]
  -> Running build hook: [keymap]
  -> Running build hook: [consolefont]
  -> Running build hook: [block]
  -> Running build hook: [filesystems]
  -> Running build hook: [fsck]
==> WARNING: No modules were added to the image. This is probably not what you want.
```

it's literally all the stuff that gets dumped into the computer's ram at runtime to mount the system.
this is basically a minimal linux system that gets loaded into ram.
it's like a very very tiny install disk.

this is probably also why it needs the literal path to the linux kernel image, since it's 
using that to build the ram image and mount the linux filesystem to /.

```
690 -rwxr-xr-x  1 root root  68M Jun 17 01:46 initramfs-linux-fallback.img
689 -rwxr-xr-x  1 root root  16M Jun 17 01:46 initramfs-linux.img
```

wow that's quite small

### modules

apparently this works?
`MODULES="module1 module2 module3"`

literally loading kernel modules into the ram image. 

it'll by default load a certain set of modules, more in the fallback image.

### fallback

the fallback is bigger, i guess because it's loading more stuff, just in case we don't have enough.
it's significantly larger, too. (still not that big.)

## vmlinuz/bzImage

this should be in ./arch/<cpu_arch>/boot
it's just a file, needs a bootloader to do anything in qemu.
actually, trying to run the bzImage in qemu-system-x86_64 gives a message that
you should be using a bootloader. neat.

## getting grub to work with it

apparently, upon making the configuration, grub will search /boot for
ram images and kernel images.

it will generate the bootloader based on this, so i guess guess renew the grub config?

`sudo grub-mkconfig -o /boot/grub/grub.cfg`

from the header of grub.cfg:

```bash
# It is automatically generated by grub-mkconfig using templates
# from /etc/grub.d and settings from /etc/default/grub
```

and those grub.d scripts search the /boot directory for all your linux images and ram images.
so yeah, grub handles all of this stuff kindof automatically.

THIS is why you're not supposed to modify by hand. you're expected to have the grub.cfg
be overwritten.

modify with the config rules in grub.d

once this is setup, reboot the system and the grub config should be updated and ready.
the "<kernel_name>" kernel should be ready to use in the loader?
