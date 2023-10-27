# debugging

it is always a programmer problem first, then a hardware problem second.

this is a collection of debugging stories, to reference back whenever i'm 
having trouble with something.

CHECK THE LOGS!

## openrc error

one time, my artix rc.conf wouldn't open. 
i assumed that i could never do any wrong, and there were some fsck (?) errors
at the BOTTOM of the startup logs that i could see, so it was probably
harddrive corruption.

i spent a few hours running pointless commands and chrooting into my env with
the iso, when i FINALLY thought to take the effort and look up where the log
files were.

let's take a look at the problem with the openrc startup:

```bash
 * Caching service dependencies ...
/etc/rc.conf: line 315: :wq: command not found
/etc/rc.conf: line 315: :wq: command not found
/etc/rc.conf: line 315: :wq: command not found
/etc/rc.conf: line 315: :wq: command not found
/etc/rc.conf: line 315: :wq: command not found
/etc/rc.conf: line 315: :wq: command not found
```

huh. really?

let's look at the rc.conf:

```bash
... other rc.conf stuff
:wq
... other rc.conf stuff
```

huh.

the easiest, dumbest error ever, could've been solved just by taking a cursory
glance at /var/log/rc.log.

i removed the :wq, and it ran fine.

## start from the bottom up?

should debugging start from the bottom or the top? 
it should start from the bottom in the sense of doing the simplest possible 
things first before we start the showoff-y linux stuff.

check if the router is plugged in before you tcpdump.
