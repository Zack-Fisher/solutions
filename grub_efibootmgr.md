# grub and efi booting

efibootmgr is just the package that grub uses to communicate with the efi firmware
on the system.
it's not a bootloader at all.

whenever the grub configs change, use `grub-mkconfig -o /boot/grub/grub.cfg`.

grub should be modified to point at different operating systems through the
/etc/grub.d config directory.

grub-mkconfig does a lot of stuff, more than you'd think. it runs a bunch of scripts
in the grub.d config dir, so it also enumerates through the linux images
and initramfs stuff available on your system.

how can we point grub at different OS partitions not on the normal boot drive? is that
possible? how can we point it at a windows filesystem on a different partition
without another windows image on the /boot drive itself?
