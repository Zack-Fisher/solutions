# making temp IO faster

i heard tmpfs was faster, and i wanted to see if it was actually true on 
my machine.

## is it true?

i ran these quick benchmarks:

```bash
zack@zackartix ~ $ time ( dd if=/dev/zero of=/tmp/write_test bs=1M count=4096 )
4096+0 records in
4096+0 records out
4294967296 bytes (4.3 GB, 4.0 GiB) copied, 1.8127 s, 2.4 GB/s

real    0m1.815s
user    0m0.001s
sys     0m1.233s
zack@zackartix ~ $ time ( dd if=/dev/zero of=write_test bs=1M count=4096 )
4096+0 records in
4096+0 records out
4294967296 bytes (4.3 GB, 4.0 GiB) copied, 1.75078 s, 2.5 GB/s

real    0m1.753s
user    0m0.008s
sys     0m1.204s
```

damn! what the hell. why is /tmp slower?

from [the archwiki](https://wiki.archlinux.org/title/tmpfs)

>Under systemd, /tmp is automatically mounted as a tmpfs, if it is not already a
>dedicated mountpoint (either tmpfs or on-disk) in /etc/fstab. To disable the
>automatic mount, mask the tmp.mount systemd unit. 

so it's just a systemd thing.

again from the archwiki, adding this to my fstab:

```bash
/dev/MyVolGrp/root      /       ext4    defaults        0       1
/dev/nvme0n1p1          /boot   vfat    defaults        0       2
tmpfs   /tmp    tmpfs   defaults,nosuid,nodev   0  0
```

(sudo mount -a to reload the fstab without a reboot)
(i wonder how mount -a is implemented??? isn't fstab
init-system dependent? does it know about my init system?)
worked perfectly. rerunning the same benchmark gave:

```bash
zack@zackartix ~ $ time ( dd if=/dev/zero of=/tmp/write_test bs=1M count=4096 )
4096+0 records in
4096+0 records out
4294967296 bytes (4.3 GB, 4.0 GiB) copied, 0.779043 s, 5.5 GB/s

real    0m0.781s
user    0m0.001s
sys     0m0.780s
```

apparently, under tmpfs, it's supposed to be writing as RAM rather
than an actual filesystem. so it's more like sharing global memory, rather
than doing real IO operations on a normal filesystem, which makes
lazy IPC a LOT LOT easier.

## why is it true?

from the [man pages](https://man.archlinux.org/man/tmpfs.5)

>The tmpfs facility allows the creation of filesystems whose contents reside in
>virtual memory. Since the files on such filesystems typically reside in RAM,
>file access is extremely fast.

is it ACTUALLY taking up RAM?

in the benchmark, i wrote 4gb to an empty disk image in the filesystem.
the output of htop still puts my ram usage at 2gb, though.

what the hell. magic sucks.

gpt says:

>First, tmpfs file systems are only allocated as much memory as they need for
>the files they're currently storing. If you create a tmpfs with a maximum size
>of 4GB but only store 1GB of files in it, it will only use 1GB of memory.

so i'm just writing files that the OS can ignore? ok, let's try copying something
non-trivial to /tmp.

```bash
zack@zackartix ~/Downloads/Final Fantasy VII (T) $ ls -liah
total 714M
1869745 drwx------ 2 zack zack 4.0K Dec 24  2018  .
 559079 drwxr-xr-x 7 zack zack 4.0K Jun 22 18:57  ..
1869746 -rw-r--r-- 1 zack zack 714M Nov 27  2016 'Final Fantasy VII (T).bin'
1869747 -rw-r--r-- 1 zack zack   85 Dec 24  2018 'Final Fantasy VII (T).cue'
zack@zackartix ~/Downloads/Final Fantasy VII (T) $ time ( cp Final\ Fantasy\ VII\ \(T\).bin /tmp )

real    0m0.526s
user    0m0.004s
sys     0m0.273s
```

but STILL, ram usage is at 2gb. 

from `free -h`:

```bash
               total        used        free      shared  buff/cache   available
Mem:            15Gi       1.9Gi       412Mi       5.0Gi        12Gi       8.0Gi
Swap:             0B          0B          0B
```

## mounting tmpfs manually

```bash
sudo mount -t tmpfs -o size=10M tmpfs /mnt/mytmpfs
```
