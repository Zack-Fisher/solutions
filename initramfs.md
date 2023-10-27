# initramfs

the initramfs is a construct that helps
encourage modularity in the kernel build process,
rather than compiling in all of the modules to the base image.
see below, it's not necessary in all cases, especially if 
your image already has the modules you need to mount root.

## demonstration

we'll check the size of the compiled image for my kernel build on arch.

```bash
zack@zackarchmain ~/Documents/c/custom_kernel/arch/x86/boot $ ls -liah | grep bz
27698005 -rw-r--r--  1 zack zack  157 Jun 17 05:05 .bzImage.cmd
27698004 -rw-r--r--  1 zack zack  13M Jun 17 05:05 bzImage
```

then the initramfs image size (not the fallback):
```bash
zack@zackarchmain /boot $ ls -liah | grep 640
436 -rwxr-xr-x  1 root root 7.4M Jun 17 05:31 System.map-640
437 -rwxr-xr-x  1 root root  95M Jun 17 05:33 initramfs-640.img
435 -rwxr-xr-x  1 root root  13M Jun 17 05:30 vmlinuz-640
```

as we could guess from the theory, the initramfs image is much larger than the
kernel image.

this is the point of initramfs

## building the kernel image to avoid an initramfs requirement

https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel#Optional:_Building_an_initramfs

compile in the options there.
in menuconfig, most options will let you optionally compile it as a kernel module.
do not do this. if we're avoiding initramfs requirements, then we'll compile all the
necessary stuff INTO the kernel image, which has the "*" next to the feature flag.

## important basic creation

```bash
initramfs -k <version> -g <output>
```

where version is the name of the modules you compiled with make modules_install
in /lib/modules.

## initramfs order

create the initramfs based on the kernel image/build/version that you're using.

initramfs is a file that has a small RAM image of the operating system,
it exists to run an init script that loads the filesystem into /.

GRUB -> initramfs -> kernel

***
GRUB execution: GRUB takes control after being loaded and provides a menu (if
configured) or automatically selects the default kernel to execute.
|
|
\/
Initramfs loading: GRUB loads the initramfs (initial RAM filesystem) into
memory. The initramfs is a temporary file system containing essential files,
modules, and drivers required to boot the system.
|
|
\/
Kernel loading: GRUB locates the kernel image file (vmlinuz) from the
designated location on the disk, typically in the root file system. It loads
the kernel into memory.
***

## initramfs modules

there are different modules for different versions of the kernel, you need to look in
/lib/modules and see all the different versions for different architectures.

everything needs to be named right. the mkinitcpio command will go by the name of the
kernel version, which is determined right at the top of the kernel Makefile.

## when is it necessary?

### only in "unusual" scenarios?

from https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel

***
 Optional: Building an initramfs

 In certain cases it is necessary to build an initramfs - an initial ram-based
 file system. The most common reason is when important file system locations
 (like /usr/ or /var/) are on separate partitions. With an initramfs, these
 partitions can be mounted using the tools available inside the initramfs.

 Without an initramfs, there is a risk that the system will not boot properly
 as the tools that are responsible for mounting the file systems require
 information that resides on unmounted file systems. An initramfs will pull in
 the necessary files into an archive which is used right after the kernel
 boots, but before the control is handed over to the init tool. Scripts on the
 initramfs will then make sure that the partitions are properly mounted before
 the system continues booting. 
***

### what does it do without an initramfs image?

so apparently, it's optional in not-strange scenarios.
without an initramfs image, it'll fallback to the init system and run the normal
init process.

interestingly, running `make install` in the kernel repo will not do anything related
to initramfs.

what does it actually do?

***
Modern kernels and systems are capable of including necessary storage drivers
directly into the kernel image itself, which is known as a monolithic kernel.
If the driver needed to read the root file system and any other critical
drivers are built into the kernel, it's not necessary to have an initramfs. The
kernel can directly mount and use the root file system.

For these types of kernels, the boot process goes something like this:

    -The bootloader loads the kernel into memory. 

    -The kernel initializes devices, memory management, etc. 

    -The kernel uses its built-in drivers to directly mount the root file system. 
    It doesn't need an initramfs to do this because the
    necessary driver is already built into the kernel image. 

    -The kernel starts the init process from the real root file system, 
    and the rest of the boot process continues from there.
***

so the kernel can start itself, if all the complexity can be handled in the kernel.
this requires that the kernel image directly includes all the filesystem drivers that
you need to mount root.

for example, you couldn't have a setup where you compile everything as modules that are
inserted at runtime, because then they wouldn't be baked into the kernel image you
have installed at root.

so the initramfs image is just a way to push complexity and bloat out of the main
kernel image.

***
The initramfs (initial ram filesystem) provides a solution to this problem. It
is a temporary root filesystem that gets loaded into memory during the boot
process before the actual root filesystem is mounted. It can contain essential
drivers and other modules that the kernel might need to start the system,
including the drivers needed to mount the root filesystem.
***


### why modularize the kernel and minimize the main image?

from gpt4:

***
Keeping the kernel image as lean as possible is beneficial for several reasons:

    -Performance: A smaller kernel uses less memory and loads more quickly during
    system startup. This can be especially significant in resource-constrained
    environments, such as embedded systems or high-performance computing
    environments where every bit of memory and every millisecond of boot time
    counts.

    -Stability: The more features and drivers are compiled into the kernel, the more
    potential there is for bugs and conflicts. By only including what's necessary,
    you can minimize the potential for issues that could impact system stability.

    -Security: Every line of code in the kernel is a potential attack vector for
    hackers. Minimizing the amount of code in the kernel therefore reduces the
    potential surface area for attacks.

    -Modularity: Compiling drivers as modules allows for greater flexibility.
    Modules can be inserted or removed at runtime without needing to reboot the
    system or recompile the kernel. This is beneficial for testing new drivers,
    updating existing ones, or dealing with hardware that's only occasionally used.

    -Portability: Keeping the kernel generic and adding hardware-specific features
    through modules can make it easier to move your setup to a different machine
    with different hardware.
***

i think for me, the main benefit is modularity. 
