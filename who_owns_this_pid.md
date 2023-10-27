# figuring out who owns a pid

## basic use

```bash
zack@zackartix ~/Documents/bash/music_util $ ps p 27779 -F
UID        PID  PPID  C    SZ   RSS PSR STIME TTY      STAT   TIME CMD
zack     27779     1  0 128446 18224  8 03:09 ?        Ssl    0:00 mpd
```

use the -F option, or the output won't say the uid.
pass either p or -p.

why is it so hard to get good answers about ps? maybe i have a weird version.
whatever, the manpages were still fine.

## more ps stuff

ps has a bunch of "selector" and "formatting" options.

```bash
zack@zackartix ~ $ ps -C mpd -F
UID        PID  PPID  C    SZ   RSS PSR STIME TTY          TIME CMD
zack     27779     1  0 128446 18224  8 03:09 ?        00:00:00 mpd
```

-C and -p are examples of selectors, -C selects and commandname and
-p selects a pid.

-F is a formatting one, specifying the format of the output.

manpages have more stuff about this, including the full list
of selectors and formats for ps.

## bloat

```bash
zack@zackartix ~ $ ls -liah $(type -p ps)
24789159 -rwxr-xr-x 1 root root 135K Feb 13  2021 /usr/bin/ps
```

WAAUGH!!

isn't that kindof bloated?
doesn't look like there's a good alternative.
for C, there's [libproc](https://docs.oracle.com/cd/E88353_01/html/E37842/libproc-3lib.html).
for psychos, there's awking the /proc vfs manually:
```bash
awk '/Uid:/ { print $2 }' /proc/[PID]/status
```
