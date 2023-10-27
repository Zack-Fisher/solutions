# the lowest virtual address without a segfault

when assembling a raw binary file with nasm from x64 source,
you can specify the starting virtual address offset of the file.

typically, it's something like ORG 0x400000.

setting this to 0x0, naturally, segfaults.

as it turns out, ORG 0x10000 is the lowest userspace address that's
actually usable. anything lower will immediately segfault before the 
program even begins execution.

here's a raw elf header thing to include in your nasm programs, to test
this logic out at home.

try changing the org address around to be different, and run the program
through gdb or something to literally see the difference in offset address.

```nasm
BITS 64
;;;; THIS FILE IS MEANT TO BE INCLUDED, TO CREATE SIMPLE NASM ELF64 BINARIES.
;;;; THIS IS A VERY DUMB EXECUTABLE WRAPPER

;;;; to use, define the "filesize" at the bottom of the included file like so:
;;;; filesize equ $ - $$, right at the bottom of the line.
;;;; the ELF format requires we know the filesize, and we can't really do that 
;;;; unless the user of the include tells us (?).
;;;; %include "simple_elf.asm" at the top of the file, this dumps the RAW ASM FILE DATA
;;;; into the current file. it's really nothing fancy that nasm does for us.

;; meant to be compiled with -f raw in nasm.
;; this is a DIRECT nasm elf64 binary, without relying on the 
;; linker or anything. it just constructs the data for the 
;; elf header and the one segment program header we need.

;; set this as the virt address for loading, doesn't really matter.
;; we can use anything in the 64-bit range for virtual addresses.
org 0x10000

ehdr: ; Elf64_Ehdr
    db 0x7F, "ELF", 2, 1, 1, 0 ; e_ident
    times 8 db 0
    dw 2 ; e_type
    dw 0x3E ; e_machine
    dd 1 ; e_version
    dq _start ; e_entry
    dq phdr - $$ ; e_phoff
    dq 0 ; e_shoff
    dd 0 ; e_flags
    dw ehdrsize ; e_ehsize
    dw phdrsize ; e_phentsize
    ;; one program header
    dw 1 ; e_phnum
    dw 0 ; e_shentsize
    ;; no section headers.
    dw 0 ; e_shnum
    dw 0 ; e_shstrndx

ehdrsize equ $ - ehdr

phdr: ; Elf64_Phdr
    dd 1 ; p_type
    dd 5 ; p_flags
    dq 0 ; p_offset
    dq $$ ; p_vaddr
    dq $$ ; p_paddr
    dq filesize ; p_filesz
    dq filesize ; p_memsz
    dq 0x1000 ; p_align

phdrsize equ $ - phdr
```

## checking out the mem mappings in /proc

it's really at 10000, too. check it out:

```bash
zack@zackartix /proc/27860/map_files $ cd /proc/$(pgrep loop)
arch_status  clear_refs          cpuset   fdinfo             latency    mem         ns             pagemap      schedstat     stack    task            wchan
attr         cmdline             cwd      gid_map            limits     mountinfo   numa_maps      personality  sessionid     stat     timens_offsets
autogroup    comm                environ  io                 loginuid   mounts      oom_adj        projid_map   setgroups     statm    timers
auxv         coredump_filter     exe      ksm_merging_pages  map_files  mountstats  oom_score      root         smaps         status   timerslack_ns
cgroup       cpu_resctrl_groups  fd       ksm_stat           maps       net         oom_score_adj  sched        smaps_rollup  syscall  uid_map
zack@zackartix /proc/28054 $ cat maps
00010000-00011000 r-xp 00000000 fe:01 3408456                            /home/zack/Documents/asm/x64/true_false/loop
7ffe28319000-7ffe2833b000 rw-p 00000000 00:00 0                          [stack]
7ffe28366000-7ffe2836a000 r--p 00000000 00:00 0                          [vvar]
7ffe2836a000-7ffe2836c000 r-xp 00000000 00:00 0                          [vdso]
ffffffffff600000-ffffffffff601000 --xp 00000000 00:00 0                  [vsyscall]
```

also, really nice how simple everything is here. most of the complication
in the memory map really does come from all the wrapper stuff that C provides.

for example, the stdlib sets up a heap for us, and a nice fancy definition
of mallocing data from it.

(yes, if we try to org our program to the vsyscall page (org 0xffffffffff600000) it segfaults.)

## what's the max?

from some experimentation, with a small executable this is around
the highest address i could find without a segfault on startup.

```nasm
org 0x7fffffffe000
```

i'm assuming it's not a coincidence that only the last page appears blocked off, even though
"0x7fffffffffff" is SUPPOSED to be the actual virt memory limit.

also notice that the vsyscall segment was mapped above this. that's because the 
vsyscall segment isn't part of userspace, so it's not bound by hard kernel limitations
on virtual addressing, like "don't go below 0x10000" and whatever.

it also appears that even loading memory into a bad page will cause a segfault, so there's
no possibility of wandering into bad memory during the course of a program.
you can't just map "half" of the program code into a good block, and then have it trail
into a taken page.
