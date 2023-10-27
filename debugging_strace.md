# syscalls contain very helpful information.
# use strace to figure out what's really happening in a program.

## perf?
perf is a profiling tool, not as useful for debugging, at least not
in an easy way like strace. 

perf lays out the "blame" for each symbol/function in a program,
so compile the program with debug symbols.


## very very helpful strace flags

### -f
follow forked child procs. strace is basically useless on large 
programs without this.

### -e
filter syscalls, eg -e signal=SIGUSR2 to find all the stuff
related to SIGUSR2.

### -t
USE THIS EVERY TIME. it prints the time of day before each line.


## general strace notes:
### unfinished/blocking calls
<unfinished ...> means that the syscall blocks the process it's in

### signal reception
*** SIGUSR2 <random stuff> *** means that the proc recieved the signal.
this is relevant if the proc is ever blocked by a sig wait.


## types of syscalls.

there are different types of syscalls, some less relevant than others.
when reading strace, block syscalls into classes, and focus on special
ones based on your problem.

### BLOCKING SYSCALLS:
```
There are multiple syscalls in Linux that can potentially block the main thread, causing it to wait for some event or condition to occur. Here is a non-exhaustive list of common syscalls that can block the main thread:

    read: Blocks until data is available for reading from a file descriptor.
    write: Blocks until the data can be written to a file descriptor (e.g., when the write buffer is full).
    recv: Blocks until data is received on a socket.
    send: Blocks until data can be sent on a socket (e.g., when the send buffer is full).
    accept: Blocks until a connection is established on a listening socket.
    connect: Blocks until a connection is established on a non-blocking socket.
    poll or select: Blocks until one or more file descriptors are ready for I/O operations.
    wait or waitpid: Blocks until a child process exits or a specific child process is terminated.
    pthread_join: Blocks until a specified thread terminates.
    futex (with FUTEX_WAIT or FUTEX_WAIT_BITSET): Blocks until a specific condition is met on a futex variable.
    pause: Blocks indefinitely until a signal is received.
    sem_wait: Blocks until a semaphore is available for decrementing.
    msgrcv: Blocks until a message is received on a message queue.
    sigsuspend: Blocks until a signal is received and handled.
```

### the only syscall that matters
futex waits until a condition is met on a cross-thread variable.
naturally, this makes it suspect for threading shenanigans.

recvmsg can also wait until a socket recieves a message
(or a general IPC mechanism recieves a message)

