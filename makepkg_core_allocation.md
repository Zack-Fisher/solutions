# makepkg core alloc

https://bbs.archlinux.org/viewtopic.php?id=91592

>MAKEFLAGS="-j5" in /etc/makepkg.conf will use them all.
>Edit: warning - some packages do not like this and you need to add options=('!makeflags') to the PKGBUILD.

so it's just like the gentoo global make flags for 
emerge compilation, cool.
