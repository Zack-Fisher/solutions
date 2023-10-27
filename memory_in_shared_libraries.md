# C shared library memory alloc

i had this mem_pool implementation:

```c
#include "mem_pool.h"
#include <stddef.h>
#include <string.h>

// The memory pool.
static char mem_pool[MEM_POOL_SIZE];

// The current end of the used memory.
static size_t mem_pool_end = 0;

void mem_pool_init() { mem_pool_end = 0; }

void *mem_pool_alloc(size_t size) {
  // Ensure alignment to sizeof(void *).
  size = (size + sizeof(void *) - 1) & ~(sizeof(void *) - 1);

  if (mem_pool_end + size > MEM_POOL_SIZE) {
    // Out of memory.
    return NULL;
  }

  void *ptr = &mem_pool[mem_pool_end];
  mem_pool_end += size;

  return ptr;
}

void mem_pool_free(void *ptr) {
  // In this simple static allocation model, we don't support freeing.
  // In a more complex model, you would mark this memory as free and
  // add it to a free list for future allocations.
}
```

and i compiled it into a shared library. running it with a client, it 
actually worked, and didn't throw any weird errors about allocating memory
in a shared library.

gpt says:

>When a shared library is used by multiple programs, each instance of the
>program gets its own separate data section, including the static/global
>variables. That means even if two programs are using the same shared library at
>the same time, the mem_pool array in each program is separate from each other.
>They do not interfere with each other. This separation protects against race
>conditions and collisions within the context of different instances of a
>program.

so apparently it's totally fine to store whatever state, either stack/dyn/static alloc
in a shared library, and i don't ever need to worry about that, which is handy.
