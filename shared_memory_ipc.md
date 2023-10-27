# shared memory on unix systems

shared memory is usually shorthanded as shm, that's what it's called in the 
syscall api.

## what is it

shared memory is very different from higher level IPC methods like
TCP, dbus and the like.
we're using syscalls and talking to the kernel directly to share memory
between programs using fast RAM storage, using "mmap" to map the memory
into both programs locally.

### benchmarking and performance

this way, it's even faster than storing globals in tmpfs and doing 
kernel file IO IPC that way (?? maybe, need to benchmark and make sure).

on benchmarking, gpt4 says:

>As for what the results will likely be, it's hard to predict without knowing
>more about your specific use case. However, one would generally expect using
>mmap with shared memory to be faster than using tmpfs.
>
>This is because tmpfs involves more layers of indirection - it is backed by
>virtual memory and can be swapped out to disk, which can introduce latency.
>Using shared memory via mmap on the other hand, involves less overhead as it
>operates directly on the physical memory.

## POSIX shm

this is the useful one with the fun C (syscall) api.

### simple implementation

here's two programs that should compile without linking shenanigans:

writer.c:
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/shm.h>
#include <sys/stat.h>
#include <sys/mman.h>

int main()
{
    const int SIZE = 4096;
    // shm segs are linked and managed by name.
    const char *name = "OS";
    const char *message_0 = "This is ";
    const char *message_1 = "POSIX shared memory IPC.\n";

    int shm_fd;
    void *ptr;

    /* create the shared memory segment */
    // it's just a file, again.
    shm_fd = shm_open(name, O_CREAT | O_RDWR, 0666);

    /* configure the size of the shared memory segment */
    ftruncate(shm_fd, SIZE);

    /* map the shared memory segment in the address space of the process */
    ptr = mmap(0, SIZE, PROT_WRITE, MAP_SHARED, shm_fd, 0);

    /* write to the shared memory segment */
    sprintf(ptr, "%s", message_0);
    ptr += strlen(message_0);
    sprintf(ptr, "%s", message_1);
    ptr += strlen(message_1);

    return 0;
}
```

reader.c:
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/shm.h>
#include <sys/stat.h>
#include <sys/mman.h>

int main()
{
    const int SIZE = 4096;
    const char *name = "OS";
    
    int shm_fd;
    void *ptr;

    /* open the shared memory segment */
    shm_fd = shm_open(name, O_RDONLY, 0666);

    /* map the shared memory segment in the address space of the process */
    ptr = mmap(0, SIZE, PROT_READ, MAP_SHARED, shm_fd, 0);
    // now the shm is in both procs address space.

    /* read from the shared memory segment */
    printf("%s", (char*)ptr);

    /* remove the shared memory segment */
    if (shm_unlink(name) == -1) {
        printf("Error removing %s\n", name);
        exit(-1);
    }

    return 0;
}
```

run the writer, then the reader. magic! IPC!

### what happened?

interestingly, the ID system is super basic. it's just a name.
better yet, if we look in /dev/shm (/dev/shared memory)...

```bash
zack@zackartix ~ $ ls /dev/shm
OS
```

huh.
so it's just a file, and it goes simply by the name you give it.

and yes, you can just read it like any other file:

```bash
zack@zackartix /dev/shm $ cat OS
This is POSIX shared memory IPC.
```

### so then what's the point?

if it's just making a file, then what benefits is this giving us over just
writing a file to a tmpfs mount and storing that in RAM anyway?

gpt4 says:

>Performance: When it comes to performance, shared memory can have an advantage
>over writing to a file in a tmpfs filesystem. While both are stored in RAM,
>tmpfs still goes through the file system layer, which introduces overhead.
>However, as mentioned earlier, the performance difference might be negligible
>in many cases, and this is why it's important to benchmark to get accurate
>results.

so the difference is, the shared memory is just a kernel device that has nothing
necessarily to do with the filesystem.

### benchmarking for realz this time

so let's prove it!
in the shared memory kernel device, reading out the raw input of the file
into /dev/null gives...

```bash
zack@zackartix /dev/shm $ time ( for i in {1..10000}; do dd if=OS of=/dev/null bs=4M 2>

real    0m11.042s
user    0m8.276s
sys     0m3.525s
```

```bash
zack@zackartix /tmp $ time ( for i in {1..10000}; do dd if=OS of=/dev/null bs=4M 2>/dev

real    0m10.851s
user    0m8.259s
sys     0m3.343s
```

what?

ok, maybe we need to use the POSIX syscalls to get the benefit out of the 
shared memory.

let's write a simple reader program for both cases, the filesystem and
the shm, both in C.

the file_read.c program:
```bash
#include <stdio.h>
#include <stdlib.h>

#define BUF_SIZE 4096 // 4KB buffer size

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <file>\n", argv[0]);
        return EXIT_FAILURE;
    }

    char *filename = argv[1];
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        perror("fopen");
        return EXIT_FAILURE;
    }

    char buf[BUF_SIZE];
    while (fread(buf, sizeof(char), BUF_SIZE, file) == BUF_SIZE);

    fclose(file);
    return EXIT_SUCCESS;
}
```

the shm_read.c program:
```bash
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>

#define BUF_SIZE 4096 // 4KB buffer size

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <shm_name>\n", argv[0]);
        return EXIT_FAILURE;
    }

    char *shm_name = argv[1];
    int fd = shm_open(shm_name, O_RDONLY, 0666);
    if (fd == -1) {
        perror("shm_open");
        return EXIT_FAILURE;
    }

    char *ptr = mmap(NULL, BUF_SIZE, PROT_READ, MAP_SHARED, fd, 0);
    if (ptr == MAP_FAILED) {
        perror("mmap");
        return EXIT_FAILURE;
    }

    char buf[BUF_SIZE];
    for (int i = 0; i < BUF_SIZE; i++)
        buf[i] = ptr[i]; // Reads from shared memory

    if (munmap(ptr, BUF_SIZE) == -1) {
        perror("munmap");
        return EXIT_FAILURE;
    }

    if (close(fd) == -1) {
        perror("close");
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
```

they just READ the file, we're not doing anything with stdout.
let's test them:

first, the shm_read from /dev/OS...
```bash
zack@zackartix ~/Documents/c/shm $ time ( for i in {1..10000}; do ./shm_read OS; done )

real    0m7.874s
user    0m6.317s
sys     0m2.339s
```

then, the file_read from /tmp, a tmpfs RAM mounted filesystem...
```bash
zack@zackartix ~/Documents/c/shm $ time ( for i in {1..10000}; do ./file_read /tmp/OS; done )

real    0m7.692s
user    0m6.142s
sys     0m2.299s
```

and just for fun, a normal file read from a typical fs directory...
```bash
zack@zackartix ~/Documents/c/shm $ time ( for i in {1..10000}; do ./file_read OS; done )

real    0m7.988s
user    0m6.438s
sys     0m2.347s
```

what?
i must totally suck at benchmarking, since every time i do it 
i'm just more confused than before.

why is reading from the normal fs not THAT much slower?

```bash
zack@zackartix / $ mount -t tmpfs
run on /run type tmpfs (rw,nosuid,nodev,relatime,mode=755,inode64)
cgroup_root on /sys/fs/cgroup type tmpfs (rw,nosuid,nodev,noexec,relatime,size=10240k,mode=755,inode64)
shm on /dev/shm type tmpfs (rw,nosuid,nodev,noexec,relatime,inode64)
tmpfs on /tmp type tmpfs (rw,nosuid,nodev,relatime,inode64)
tmpfs on /run/user/1000 type tmpfs (rw,nosuid,nodev,relatime,size=1599308k,nr_inodes=399827,mode=700,uid=1000,gid=1000,inode64)
zack@zackartix / $
```

yeah, the tmpfs is mounted properly.
what is happening??

### quirks with the shm kernel device

it acts exactly like a normal file, even not giving write errors
like the readonly files in /sys/class.

```bash
zack@zackartix ~/Documents/c/shm $ ./write

...

zack@zackartix / $ echo "hello" >> /dev/shm/OS
zack@zackartix / $ cat /dev/shm/OS
This is POSIX shared memory IPC.
hello

...

zack@zackartix ~/Documents/c/shm $ ./read
This is POSIX shared memory IPC.
```

BUT, the underlying shared memory the device represents is read only.
(read only in user space.)
so, it'll stay the same.

i love how little the kernel cares about me writing to this file.
i think shm might be my favorite type of /dev virtual device.

## systemv shm

"systemv IPC" is just a name. you don't need to be running systemv to have
systemv IPC on your machine.

run the command: 
```bash
ipcs
```
to see all the systemv IPCs on your system.

```bash
------ Message Queues --------
key        msqid      owner      perms      used-bytes   messages

------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     statu
0x00000000 2          zack       600        8294400    2          dest
0x00000000 3          zack       600        8294400    2          dest
0x00000000 8          zack       600        8294400    2          dest
0x00000000 9          zack       600        8294400    2          dest

------ Semaphore Arrays --------
key        semid      owner      perms      nsems
```

who made these mysterious ipcs on my system? UNDER MY NAME??? freaky.

ipcs is a misleading name, it ONLY shows systemv ipcs.
posix kernel ipcs won't show up here.
