# notes on compiling gcc (and some other gnutils) for embedded-like systems.

this page was mostly referenced from [this](https://www.moria.us/blog/2020/10/n64-part1-land-of-pain) article.

## chaining an instance of gcc and libc together

use the --with-sysroot=/root/of/target/fs flag in gcc to specify the root of the filesystem it's being installed
to that has all the instances of the C system libraries.
when doing a fresh build onto another system, build binutils -> libc -> gcc, since
we need a build of libc on the sysroot before we can properly build gcc.

glibc's "make install" will install the system headers, which the gcc build will also use for its own compilation.

## overview

you can, for the most part, treat sufficiently old systems as if they
were embedded systems.

the dreamcast (which runs an "sh-4" processor) was about the last system without some sort of 
OS-hypervisor running over every game process, with a proper idea of a syscall.

this means that you can basically just compile nostdlib C code to the right
processor and architecture, and have it more or less work with no trouble.

how?

### compiler terminology

+ build - which machine is building the compiler?
+ host - which machine is running the compiler to build the utils?
+ target - which machine is going to run the utilities that are compiled by the host?

in most situations, the build and host machines are generally the same.

## general gnutil compilation notes

it uses gnu autotools, so the usual rules there apply. 
it's usually better to setup a pristine build dir, just like a cmake build,
then run the ../configure script from that subdir.

### environment

the following variables must be TOTALLY CONSISTENT throughout the build of 
all the gnutils for the target.

+ $TARGET: the gnu target triple for the specified target arch.
+ $PREFIX: where the utils will be installed. this is the same for all gnutil builds.

example for the n64: 

```bash
export TARGET=mips64-elf
export PREFIX=/opt/n64
```

## compiling binutils

an example that works for the above target for the n64, 
from the site linked at the top:

```bash
../configure \
  --target=$TARGET --prefix=$PREFIX \
  --program-prefix=mips64- --with-cpu=vr4300 \
  --with-sysroot --disable-nls --disable-werror
```

now, before installing, ensure that you actually set the $PREFIX. it's really
easy to brick your operating system messing with the prefix, as you can simply overwrite the other
gnutils on your machine.

run the classic:

```bash
make 
make install
```

it should install directly into the prefix.

## compiling gcc

once we have a reasonable toolkit for simple operations on the processor,
it's time to build the C compiler.

### getting around no libc in the build process

gcc does this weird thing where the compilation process itself is 
dependent on a specific install of a standard library, and it'll error
if the right architecture doesn't have a compatible libc definition.

it'll look for the target triple's specific gnutil toolkit at 
/usr/local/$TARGET, usually.

throw the arg --without-headers to the ./configure script to get around this.

### compiling

again, from the site linked above, this is an example for the mips64-elf
basic processor architecture:

```bash
../configure \
  --target=$TARGET --prefix=$PREFIX \
  --program-prefix=mips64- --with-arch=vr4300 \
  -with-languages=c,c++ --disable-threads \
  --disable-nls --without-headers
```

note that we're using the same exact PREFIX definition, we don't need to do anything
fancy. just make sure that it is the same, or it's going to be really inconvenient
to manage the tools for the one embedded target machine.

### installing

then to install from the build directory that you've made:

```bash
make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc
```

## non-embedded gcc

use PREFIX=/usr if it's going to be the main compiler/util set on the machine.
this is what the PREFIX=/opt/n64 installation looked like, for instance:
```bash
zack@zackartix(win_32) /opt/n64 $ ls
bin  include  lib  libexec  mips64-elf  share
```
