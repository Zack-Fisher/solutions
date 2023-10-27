# the /tmp and /run filesystems on linux

tldr;
they're both for temporary stuff
/tmp is for userspace applications
/run is for root and kernel stuff, not to be used
or even accessible by typical processes

they're both (typically) implemented as RAM vfs.
meaning, they're both flushed out when the system reboots
(since RAM is usually volatile).

## /tmp

a filesystem for user-space scratch work.
if it's really a tmpfs, writing will be faster.
processes can use /tmp files as a really simple form of IPC,
without too much of the IO overhead, since it's really just
modifying RAM instead of anybody's disk.

/tmp is pretty old, and was a core part of unix all the way back.

## /run

fairly new, introduced around 2011 to the filesystem spec.
for processes that users generally aren't supposed to be 
messing around in.

stuff like kernel locks, init system temp files.

/run is guaranteed to be loaded early, so it can be safely used
during the init process. 

therefore, you'll see a bunch of /run shenanigans if you likely check
your init logs.
