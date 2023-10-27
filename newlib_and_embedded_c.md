# custom modifications to newlib for embedded systems

originally, i assumed that newlib modifications were baked into the build itself.
however, looking at the libdragon n64 implementation, which uses STOCK mips64-elf
newlib for its romfs implementation among other things, that's not true.

it appears to override things at link-time.

## "wait, doesn't defining the same symbol twice just cause a linker error?"

it turns out, not always??

check this example out:

```c
void exit(int x) { printf("nope, not happening\n"); }

int main(int argc, char *argv[]) {
  printf("hello\n");
  exit(0);
}
```

compiling normally with 
```gcc -o m main.c```:

```bash
zack@zackartix ~/Documents/c/over $ ./m
hello
nope, not happening
Segmentation fault
```

woah!
what?

but, if i...

```c
void exit(int x) { printf("nope, not happening\n"); }

int main(int argc, char *argv[]) { printf("scream\n"); }

int main(int argc, char *argv[]) {
  printf("hello\n");
  exit(0);
}
```

```bash
main.c: At top level:
main.c:5:5: error: redefinition of ‘main’
    5 | int main(int argc, char *argv[]) {
      |     ^~~~
```

yes, that's still true. what the hell is happening here?

gpt says:
> Weak symbols are a feature of the ELF binary format used by many Unix-like
> operating systems, including Linux. A symbol (such as a function or global
> variable) in an ELF binary can be marked as either weak or strong. If a symbol
> is defined more than once, the linker will prefer strong symbols over weak
> ones.
> 
> The standard library functions in libc (and by extension, Newlib) are marked as
> weak symbols specifically so that they can be overridden in this way. This is
> what allows you to redefine the exit() function in your example without getting
> a linker error.

## how do we declare weak symbols in our own code, then?

use the gcc compilation attr:

```c
void __attribute__((weak)) my_function() {
    // Implementation of my_function
}
```

and it should work* kind of*

(note: i think this is gcc specific, and the weak attribute is added to the ELF data somehow.)

one catch is, we can't define a function twice in the same file, even if one definition
is weak.

the following code works:

define in othermain.c:

```c
int __attribute__((weak)) main(int argc, char *argv[]) { printf("scream\n"); }
```

in main.c:

```c
void exit(int x) { printf("nope, not happening\n"); }

int main(int argc, char *argv[]) {
  printf("hello\n");
  exit(0);
}
```

then compile with:

```bash
gcc -o m othermain.c main.c
```

then, the strong definition overrides the weak definition, and there are
NO compiler/link-time errors.

```bash
zack@zackartix ~/Documents/c/over $ ./m
hello
nope, not happening
Segmentation fault
```

just to make sure, since order DOES matter, we should check what happens if a weak symbol
is defined AFTER the strong symbol:

```bash
gcc -o m main.c othermain.c
```

and exactly as expected, it...

```bash
zack@zackartix ~/Documents/c/over $ ./m
hello
nope, not happening
scream
Segmentation fault
```

WHAT?
WHAT THE FUCK?

even gpt doesn't know what's going on:
> Generally, it shouldn't be possible for both versions of main() to be called
> because a C program is supposed to have exactly one entry point, which is the
> main() function. The linker should resolve all calls to main() to a single
> function, regardless of whether the symbols are weak or strong.
> 
> One possibility could be that the strong main() is calling some function (like
> exit()), which is then calling the weak main(). But from the code snippets you
> provided, it doesn't seem like this is what's happening.
> 
> It could also be possible that there's some undefined behavior happening, which
> is causing the program to do something unexpected. Without the full context of
> your code and your build environment, it's hard to say for sure what's causing
> this behavior.

in gdb, it's just returning from the exit call to the wrong main() address, the ((weak))
__attribute__'d one.

huh.

```
0000000000001156 <main>:
    1156:       55                      push   rbp
    1157:       48 89 e5                mov    rbp,rsp
    115a:       48 83 ec 10             sub    rsp,0x10
    115e:       89 7d fc                mov    DWORD PTR [rbp-0x4],edi
    1161:       48 89 75 f0             mov    QWORD PTR [rbp-0x10],rsi
    1165:       48 8d 05 ac 0e 00 00    lea    rax,[rip+0xeac]        # 2018 <_IO_stdin_used+0x18>
    116c:       48 89 c7                mov    rdi,rax
    116f:       e8 bc fe ff ff          call   1030 <puts@plt>
    1174:       bf 00 00 00 00          mov    edi,0x0
    1179:       e8 bb ff ff ff          call   1139 <exit>
    117e:       55                      push   rbp
    117f:       48 89 e5                mov    rbp,rsp
    1182:       48 83 ec 10             sub    rsp,0x10
    1186:       89 7d fc                mov    DWORD PTR [rbp-0x4],edi
    1189:       48 89 75 f0             mov    QWORD PTR [rbp-0x10],rsi
    118d:       48 8d 05 8a 0e 00 00    lea    rax,[rip+0xe8a]        # 201e <_IO_stdin_used+0x1e>
    1194:       48 89 c7                mov    rdi,rax
    1197:       e8 94 fe ff ff          call   1030 <puts@plt>
    119c:       b8 00 00 00 00          mov    eax,0x0
    11a1:       c9                      leave
    11a2:       c3                      ret
```

it just kinda... sticks the ((weak)) one on the end of the strong definition.

huh.
