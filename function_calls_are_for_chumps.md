# function call overhead in C (gcc)

all function calls are cpu overhead. there are function call and jump instructions, and
a bunch of cpu boilerplate every single time you call one.

recently, i've fallen into the habit of avoiding function calls in C for that exact reason.
does the compiler compile out the overhead, anyway? let's find out:

check out this non-trivial example.

i want to be able to get the filelength as a size_t from the FILE* or the filepath pointer, and
i want the behavior to be shared among the two functionalities.

we'll compare two approaches, using the FILE* subcall as a macro and a function. 

here's the code:

```c
#include <stdio.h>
#include <stdlib.h>

// function calls are for chumps.
// FILE_length is now defined in the greater program scope.
#define get_FILE_length(file)                                                \
    fseek(file, 0, SEEK_END);                                               \
    size_t FILE_length = ftell(file);                                            \
    fseek(file, 0, SEEK_SET);                                                  \

// compare w the macro version. does the overhead get compiled out?
size_t get_FILE_length_function(FILE* file)                                                  \
  {                                                                            \
    fseek(file, 0, SEEK_END);                                                  \
    size_t length = ftell(file);                                               \
    fseek(file, 0, SEEK_SET);                                                  \
    return length;                                                             \
  }

// Function to get the length of the file
size_t get_file_length(const char *file_path) {
  FILE *file = fopen(file_path, "rb");
  if (!file) {
    perror("Error opening file");
    return 0;
  }

  return get_FILE_length_function(file);
}

// Function to get the length of the file
size_t get_file_length_with_macro(const char *file_path) {
  FILE *file = fopen(file_path, "rb");
  if (!file) {
    perror("Error opening file");
    return 0;
  }

    get_FILE_length(file)
    return FILE_length;
}
```

now, what does gcc do?

## no optimizations (-O0)

generally, when gcc says NO OPTIMIZATION, it means __NO__ OPTIMIZATION. it'll be
as basic as possible, the only things it'll compile out are really basic expressions.

(for example, 2 * 2 will statically compile to 4, even on -O0.)

and the results here match up with that idea:

```
get_FILE_length_function:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 32
        mov     QWORD PTR [rbp-24], rdi
        mov     rax, QWORD PTR [rbp-24]
        mov     edx, 2
        mov     esi, 0
        mov     rdi, rax
        call    fseek
        mov     rax, QWORD PTR [rbp-24]
        mov     rdi, rax
        call    ftell
        mov     QWORD PTR [rbp-8], rax
        mov     rax, QWORD PTR [rbp-24]
        mov     edx, 0
        mov     esi, 0
        mov     rdi, rax
        call    fseek
        mov     rax, QWORD PTR [rbp-8]
        leave
        ret
.LC0:
        .string "rb"
.LC1:
        .string "Error opening file"

get_file_length:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 32
        mov     QWORD PTR [rbp-24], rdi
        mov     rax, QWORD PTR [rbp-24]
        mov     esi, OFFSET FLAT:.LC0
        mov     rdi, rax
        call    fopen
        mov     QWORD PTR [rbp-8], rax
        cmp     QWORD PTR [rbp-8], 0
        jne     .L4
        mov     edi, OFFSET FLAT:.LC1
        call    perror
        mov     eax, 0
        jmp     .L5
.L4:
        mov     rax, QWORD PTR [rbp-8]
        mov     rdi, rax
        call    get_FILE_length_function
.L5:
        leave
        ret

get_file_length_with_macro:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 32
        mov     QWORD PTR [rbp-24], rdi
        mov     rax, QWORD PTR [rbp-24]
        mov     esi, OFFSET FLAT:.LC0
        mov     rdi, rax
        call    fopen
        mov     QWORD PTR [rbp-8], rax
        cmp     QWORD PTR [rbp-8], 0
        jne     .L7
        mov     edi, OFFSET FLAT:.LC1
        call    perror
        mov     eax, 0
        jmp     .L8
.L7:
        mov     rax, QWORD PTR [rbp-8]
        mov     edx, 2
        mov     esi, 0
        mov     rdi, rax
        call    fseek
        mov     rax, QWORD PTR [rbp-8]
        mov     rdi, rax
        call    ftell
        mov     QWORD PTR [rbp-16], rax
        mov     rax, QWORD PTR [rbp-8]
        mov     edx, 0
        mov     esi, 0
        mov     rdi, rax
        call    fseek
        mov     rax, QWORD PTR [rbp-16]
.L8:
        leave
        ret
```

nice. the macro is way better here, in terms of cpu time. it doesn't have any of the call or function setup/return overhead
that the function call gives.

## -O2 optimization pass

```
get_FILE_length_function:
        push    rbp
        mov     edx, 2
        xor     esi, esi
        push    rbx
        mov     rbx, rdi
        sub     rsp, 8
        call    fseek
        mov     rdi, rbx
        call    ftell
        mov     rdi, rbx
        xor     edx, edx
        xor     esi, esi
        mov     rbp, rax
        call    fseek
        add     rsp, 8
        mov     rax, rbp
        pop     rbx
        pop     rbp
        ret
.LC0:
        .string "rb"
.LC1:
        .string "Error opening file"

get_file_length:
        push    rbp
        mov     esi, OFFSET FLAT:.LC0
        push    rbx
        sub     rsp, 8
        call    fopen
        test    rax, rax
        je      .L8
        mov     rbx, rax
        mov     edx, 2
        xor     esi, esi
        mov     rdi, rax
        call    fseek
        mov     rdi, rbx
        call    ftell
        mov     rdi, rbx
        xor     edx, edx
        xor     esi, esi
        mov     rbp, rax
        call    fseek
        add     rsp, 8
        mov     rax, rbp
        pop     rbx
        pop     rbp
        ret
.L8:
        mov     edi, OFFSET FLAT:.LC1
        xor     ebp, ebp
        call    perror
        add     rsp, 8
        mov     rax, rbp
        pop     rbx
        pop     rbp
        ret

get_file_length_with_macro:
        push    rbp
        mov     esi, OFFSET FLAT:.LC0
        push    rbx
        sub     rsp, 8
        call    fopen
        test    rax, rax
        je      .L13
        mov     rbx, rax
        mov     edx, 2
        xor     esi, esi
        mov     rdi, rax
        call    fseek
        mov     rdi, rbx
        call    ftell
        mov     rdi, rbx
        xor     edx, edx
        xor     esi, esi
        mov     rbp, rax
        call    fseek
        add     rsp, 8
        mov     rax, rbp
        pop     rbx
        pop     rbp
        ret
.L13:
        mov     edi, OFFSET FLAT:.LC1
        xor     ebp, ebp
        call    perror
        add     rsp, 8
        mov     rax, rbp
        pop     rbx
        pop     rbp
        ret
```

-O2 will unwrap the function call, even in a non-trivial case like this! wow!
so that's convenient. i don't have to wrap everything in macros anymore...

## bonus: -Os (optimize for size)

what if we WANT the function call, since it's smaller than inlining the function?

```
get_FILE_length_function:
        push    rbp
        mov     edx, 2
        xor     esi, esi
        push    rbx
        mov     rbx, rdi
        push    rax
        call    fseek
        mov     rdi, rbx
        call    ftell
        xor     edx, edx
        mov     rdi, rbx
        xor     esi, esi
        mov     rbp, rax
        call    fseek
        mov     rax, rbp
        pop     rdx
        pop     rbx
        pop     rbp
        ret
.LC0:
        .string "rb"
.LC1:
        .string "Error opening file"

get_file_length:
        push    rsi
        mov     esi, OFFSET FLAT:.LC0
        call    fopen
        test    rax, rax
        je      .L7
        mov     rdi, rax
        pop     rcx
        jmp     get_FILE_length_function
.L7:
        mov     edi, OFFSET FLAT:.LC1
        call    perror
        xor     eax, eax
        pop     rdx
        ret
```

huh. it jmps instead of calling? why?

use the __attribute__((always_inline)) to make sure that it does. even -O0 won't ignore
this request, but it's gcc-specific.
