# when grub boots, how does it choose the default kernel?

grub will default to the latest kernel.

it's just in /etc/default/grub.
the GRUB_DEFAULT variable is right at the top, and it can either be
expressed as a string or a number.

## configuring it to boot to a specific kernel/image

### by id

the number is less weird, but more brittle?

```bash
GRUB_DEFAULT=0
```

it's the order that it shows up the advanced options menu, which is the order
the images were last installed.

it starts at zero, so it uses the latest kernel by default.

to see them in the correct order, roughly, use

```bash
grep 'menuentry' /boot/grub/grub.cfg
```

and select the index of the initramfs/plain kernel image you want to boot.

### by string

```bash
GRUB_DEFAULT="Advanced options for Arch Linux>Arch Linux, with Linux linux-zen"
```
