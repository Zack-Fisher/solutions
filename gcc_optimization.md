# gcc optim -O flag overview

from gpt3:

***
The GNU Compiler Collection (GCC) provides several levels of optimization
flags, starting from "-O0" and going up to "-O3" and "-Ofast". Here are the
different levels of optimization:

"-O0": This is the lowest optimization level. It disables most optimizations,
generating unoptimized code. It is useful for debugging purposes, as it
preserves the original source code structure and simplifies debugging.

"-O1": This level enables a set of optimizations that aim to improve code
execution speed without significantly increasing the compilation time. It
includes basic optimizations such as common subexpression elimination and
simple control flow optimizations.

"-O2": This level, also known as Optimization Level 2, provides a higher level
of optimization compared to "-O1". It includes all the optimizations from "-O1"
and additionally applies more aggressive optimizations, such as loop unrolling,
function inlining, and more advanced control flow optimizations.

"-O3": This level is one step higher than "-O2" and includes even more
aggressive optimizations. It performs additional loop transformations,
vectorization, and advanced optimizations like instruction scheduling and
automatic parallelization.

"-Os": This optimization level is focused on code size reduction rather than
speed. It performs size optimizations such as function inlining, constant
folding, and dead code elimination to generate smaller executable files.

"-Ofast": This level combines "-O3" optimizations with additional aggressive
optimizations that may not strictly follow the language standards. It
sacrifices some standard compliance for maximum performance. It is typically
used when the programmer is confident that the code will not be affected by
non-standard behaviors.
***
