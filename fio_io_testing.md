# benchmarking filesystems with fio

for example, to do a random write task on the /home/zack directory...

```bash
fio --name=random-write --ioengine=posixaio --rw=randwrite --bs=4k --numjobs=1 --size=1g --time_based --runtime=30s --end_fsync=1 --directory=/home/zack
```

a lot of the time, writing benchmarks yourself overlooks
complicated OS stuff. especially filesystem tests, since
there's a lot of shenanigans with IO caching and the kernel.

## example

writing to tmpfs is faster than writing to a normal ssd linux filesystem.

proof:

run a fio random-write on the /tmp directory (make sure that it's actually
a tmpfs and not something else, run `mount` in the terminal).

```bash
write: IOPS=249k, BW=973MiB/s (1020MB/s)(28.5GiB/30001msec);
```

now, run the same fio operation on the ssd filesystem, let's say the ~ directory:

```bash
write: IOPS=146k, BW=569MiB/s (597MB/s)(17.0GiB/30512msec);
```

(but don't believe me. try it yourself!)
