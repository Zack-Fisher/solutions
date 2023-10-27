# qemu notes

qemu is really useful and has a ton of stuff you'd never really expect.
qemu has support for basically every CPU ever (?), and can be used to test 
cross-compilation work.

## visuals with qemu

running the command:

```bash
qemu-system-<arch>
```

will make a graphical display with the system running inside.
for example,

```bash
qemu-system-x86_64 -hda hdd_image.qcow2 -m 2G
```

will run an x86_64 bit system in a GUI window with the hdd created with
qemu-img. the -m specifies the amount of RAM passed to the virtual machine.

pass it a boot ISO or a hdd with -cdrom or -hda.

## booting from a specific drive

pass the -boot option to choose the drive you want to boot from
through the qemu BIOS.

>-boot d: Boot from a CD-ROM or ISO image.
>-boot c: Boot from the first hard disk.
>-boot n: Boot from a network device (PXE boot).

so if you're putting multiple drives in, you might do something like

```bash
qemu-system-x86_64 -cdrom debian_livecd.iso -hda hdd.qcow2 -m 2G -boot d
```

to boot from the livecd, and install to the hda on the first
boot of the operating system.

## making drives

to make an hdd image for use with a virtual machine, use:

```bash
qemu-img create -f qcow2 hdd_image.qcow2 10G
```

## running the kernel directly

since qemu's so good, we can cheat a little here and 
not even make a bootable harddrive image. just specify the kernel
image (and maybe the ramfs image, if you need it), and we're good
to go.

all the other stuff is redirecting the stdout of the qemu machine to the
starting tty's stdio streams.

```bash
qemu-system-x86_64 -kernel /boot/vmlinuz-linux -initrd /boot/initramfs-linux.img -m 2G -append "console=ttyS0" -serial stdio
```

## specifying bios firmware image

qemu will use a default bios that can do basic BIOS mode booting.

if you need other options, pass the firmware image with the -bios 
option, and qemu should just use that instead.

```bash
qemu-system-x86_64 -bios <path_to_firmware> [other options]
```
