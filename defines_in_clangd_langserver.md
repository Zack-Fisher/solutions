# defining things with clangd, giving the lsp context

put a compile_flags.txt at the root of the project.
clangd will find it and give suggestions with that context.

the flags are specified one per line (or maybe more?)

```
-DTOOLS_ENABLED=1
```

and then clangd will have this flag enabled in the whole project,
so there won't be any more grayed out text.

some build tools like cmake are supposed to generate these compiler
flag files?
