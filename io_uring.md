# io_uring

a way to make async IO operations in the linux kernel.
read async from an fd

## name derivation

The term "uring" in io_uring is derived from the words "universal" and "ring
buffer." The name represents the underlying data structure used by the io_uring
framework to manage I/O operations efficiently.

## overview

"io_uring is a high-performance asynchronous I/O framework in the Linux kernel.
It was introduced in the 5.1 version of the Linux kernel and is designed to
provide efficient and scalable I/O operations for applications.

Traditionally, applications perform I/O operations by using system calls such
as read() and write(). However, these system calls can be relatively slow and
inefficient, especially when dealing with large numbers of I/O operations or
when performing I/O on multiple threads.

io_uring addresses these limitations by providing a more efficient interface
for asynchronous I/O. It allows applications to submit I/O operations to the
kernel and continue their execution without waiting for the operations to
complete. This asynchronous nature enables applications to achieve higher I/O
throughput and better scalability.

The key features of io_uring include:

Asynchronous I/O: Applications can submit multiple I/O operations in a single
system call, reducing context switches and improving efficiency.

Kernel-bypass: io_uring allows applications to bypass the standard file
descriptor-based I/O and directly submit I/O requests to the kernel, reducing
overhead and improving performance.

Event-driven model: Applications are notified of completed I/O operations using
event completion notifications, such as completion queues or eventfd. This
approach enables efficient handling of large numbers of I/O operations without
excessive polling.

Multiple submission and completion queues: io_uring supports multiple
submission and completion queues, allowing applications to parallelize and
distribute I/O operations across threads or cores.

Buffer management: io_uring provides efficient mechanisms for managing I/O
buffers, including zero-copy operations and memory-mapped I/O.

io_uring has gained popularity in various performance-sensitive applications,
such as databases, web servers, and network services, where high I/O throughput
and low latency are crucial. It provides a powerful interface for developers to
leverage the capabilities of modern storage devices and network interfaces
while maintaining a simple and consistent programming model."


## example

```c 
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <liburing.h>

#define QUEUE_DEPTH 32

int main() {
    struct io_uring ring;
    struct io_uring_sqe *sqe;
    struct io_uring_cqe *cqe;
    int fd, ret;
    char buffer[4096];

    // Initialize the io_uring instance
    if (io_uring_queue_init(QUEUE_DEPTH, &ring, 0) < 0) {
        perror("io_uring_queue_init");
        exit(1);
    }

    // Open the file
    fd = open("example.txt", O_RDONLY);
    if (fd < 0) {
        perror("open");
        exit(1);
    }

    // Prepare the read operation
    sqe = io_uring_get_sqe(&ring);
    if (!sqe) {
        perror("io_uring_get_sqe");
        exit(1);
    }
    io_uring_prep_read(sqe, fd, buffer, sizeof(buffer), 0);

    // Submit the operation
    io_uring_submit(&ring);

    // Wait for completion
    ret = io_uring_wait_cqe(&ring, &cqe);
    if (ret < 0) {
        perror("io_uring_wait_cqe");
        exit(1);
    }

    // Process the completed operation
    if (cqe->res < 0) {
        perror("read");
        exit(1);
    }

    // Print the data
    write(STDOUT_FILENO, buffer, cqe->res);

    // Clean up
    io_uring_cq_advance(&ring, 1);
    io_uring_queue_exit(&ring);

    close(fd);

    return 0;
}
```
