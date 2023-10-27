# making a one letter password in gentoo

unlike arch, gentoo forces a secure password on you using
something called PAM.

there's a solution here: https://forums.gentoo.org/viewtopic-t-1117656-start-0.html

from the link:

***
nevermind, I found it

comment out with # the line from /etc/pam.d/system-auth
password required pam_passwdqc.so min=8,8,8,8,8 retry=3

and making next one
to be
password required pam_unix.so nullok sha512 shadow

instead of
password required pam_unix.so try_first_pass use_authtok nullok sha512 shadow

made me happy.
***

after editing this, using passwd should have everything deactivated.
