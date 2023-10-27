# preventing lockout after missing the sudo password

[from the archwiki](https://wiki.archlinux.org/title/Security#Lock_out_user_after_three_failed_login_attempts)

## background, some stuff about PAM.

just like the gentoo install stuff, the security on arch is handled with the same library,
PAM (Pluggable Authentication Module).

most distros use pam, but it IS optional. it's not part of the kernel itself.

from GPT3:
>Apologies for any confusion caused. Let me clarify: PAM (Pluggable
>Authentication Modules) is a framework for authentication management in
>Linux-based operating systems. It is not a module for the Linux kernel but
>rather a set of modules that can be dynamically loaded by applications and
>services to handle various authentication tasks.

pam isn't a kernel module, it's just a modular system of several modules 
that various things can use for whatever. all the modules are uniquely configurable,
and pam is just a framework that's initially configured in a specific way per distro.

some are just more secure than others by default.

## how can we prevent it

as per the link above, we just have to configure the relevant PAM modules.

open in a text editor, then set the "deny" param to 0.
that'll deactivate the whole system.

```bash
sudo nvim /etc/security/faillock.conf
```
