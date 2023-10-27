# futex syscall on [unix](unix)

## name derivation

"In computing, a futex (short for "fast userspace mutex")"

## Usage

# from an strace:

```c
futex(
    0x7f5e2ee0e990,  // the address of the data.
    FUTEX_WAIT_BITSET_PRIVATE|FUTEX_CLOCK_REALTIME,  // specify the futex options, how it should watch and what it should 
    // watch the futex for
    0, 
    {tv_sec=1686816485, tv_nsec=942782976},  // specify the timeout limits
    FUTEX_BITSET_MATCH_ANY) = -1 ETIMEDOUT (Connection timed out)
```

## simple flag usage
    FUTEX_WAIT_BITSET_PRIVATE: This flag indicates that the waiting thread will be put to sleep until a certain condition is met, using a private notification bitset.
    FUTEX_CLOCK_REALTIME: This flag specifies that the timeout values provided in the struct timespec argument are based on the real-time clock.
    
    
## theory
it's just an integer, the pointer address is a pointer to that atomic integer.
by "atomic integer", it's a SINGLE integer, and single integer.
the futex call is the kernel-level implementation of blocking and semaphores.
" A futex consists of a kernel-space wait queue that is attached to an atomic integer in userspace. "

## actual C example in practice.
we'll setup the value of the mutex.
we'll use the FIRST syscall to wait until the mutex is zero, then set it to the WAKE state
this needs to be a kernel thing, since the OS itself has to step in and prevent the memory access here.
in the "critical section" in multithreading, only the one thread can access the mutex, or semaphore, or whatever.

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <linux/futex.h>

int main() {
    int futex_val = 1;  // 1 indicates the mutex is unlocked
    int* futex_addr = &futex_val;

    // Acquire the mutex
    // the third param of the syscall is the value to compare the futex to.
    if (syscall(SYS_futex, futex_addr, FUTEX_WAIT, 0, NULL, NULL, 0) == -1) { // -1 is an error, usually a timeout on the thread.
        perror("FUTEX_WAIT failed");
        exit(EXIT_FAILURE);
    }

    // Critical section: Only one thread can execute this at a time
    printf("Mutex acquired\n");
    sleep(2);  // Simulate some work being done

    // Release the mutex
    *futex_addr = 0;
    if (syscall(SYS_futex, futex_addr, FUTEX_WAKE, 1, NULL, NULL, 0) == -1) {
        perror("FUTEX_WAKE failed");
        exit(EXIT_FAILURE);
    }

    printf("Mutex released\n");

    return 0;
}
```
