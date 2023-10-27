# working with csharp

csharp is definitely a programming language. yes.
there sure are numbers and functions. neato.

## what?

mono is an open source (?) implementation of the .NET 
framework and runtime, so all the using System type libraries
and the csharp JIT (?).

i'm assuming it uses a virtual machine-type design like java. does it?
apparently, gpt says yes.
it has a common runtime bytecode language that's run by the vm JIT.
so i guess mono implements not only the functions and libraries but that
too.

## building csharp on linux

xbuild is deprecated and a dirty trick. to build .sln and .csproj files,
run the 
```bash
msbuild
```
command. if you have all the windows libraries it needs, it should work just
fine.

## compiling

### getting a single file to run

write a class with a main function in it. then, run
```bash
mcs main.cs
```
to get an ELF executable main.exe.

BUT WAIT!

```bash
zack@zackartix ~/Documents/csharp/modules $ ./main.exe
002c:fixme:actctx:parse_depend_manifests Could not find dependent assembly L"Microsoft.Windows.Common-Controls" (6.0.0.0)
wine: could not load kernel32.dll, status c0000135
zack@zackartix ~/Documents/csharp/modules $ mono main.exe
x
```

you can't just run it normally, you have to pass it to mono.

it works pretty similar to a C compiler. just pretend you're compiling
with normal gcc and you'll be fine.

for example, to include and expose other classes into the compilation so that
you can modularize your code, do 

```bash
mcs main.cs otherclass.cs
```

and then you can access the public namespaces and classes in otherclass.cs.

### full example of modular compilation

for some reason, i had a lot of trouble when i tried to do this my first time.
so here's a full example of a csharp program spread across multiple files!

make files main.cs and otherclass.cs;
in main.cs:
```csharp
using System;

class Program {
  static void Main()
  {
    Console.WriteLine("x");
    OtherClass.DoStuff();
  }
}
```

in otherclass.cs:
```csharp
using System;
public class OtherClass {
  public static void DoStuff() {
    Console.WriteLine("doing stuff in other file");
  }
}
```

then compile with the globbing notation to get EVERYTHING at once, and
run the output:

```bash
zack@zackartix ~/Documents/csharp/modules $ mcs *.cs
zack@zackartix ~/Documents/csharp/modules $ mono main.exe
x
doing stuff in other file
```

### dlls and linking

also use mcs to create a dll file.
```bash
mcs -target:library -out:output.dll file1.cs file2.cs
```
then, we can link against the dll file in another compilation using
```bash
mcs -r:output.dll program.cs
```

you can actually see all the standard library dlls that your applications
link with by default with mcs through /usr/lib/mono.

check the version, and you'll see dll files like System.dll and whatever.

the "using" directive just imports the namespace so that it can be 
referenced easier, the actual linking happens at compile time.

you can just disasm the standard libraries directly and check out the definition 
of WriteLine like it's no big deal, which is actually cool.

csharp really isn't anything special, but i appreciate the clear focus on modularization
of code into dlls. it's really not often that a language lets you compile and relink your
code into reusable, fast chunks like c# does, and it's NEVER this easy.

## disasm

```bash
monodis <lib>.dll
```
or an exe or whatever will puts a nice disasm to the terminal.
