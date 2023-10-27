# formatting with DD

## simple usage

i keep forgetting this every time. here it is:

```bash
dd if=/path/to/os_image.iso of=/dev/target_disk bs=4M status=progress ; sync
```

this flashes the image to disk.
i don't think the sync stuff is really necessary, it has something to do with
the kernel's block IO caching? maybe?

## funny business

### reading from stdin

it can! piping stdin will automatically make dd use the stdin pipe as the 
"if" input.

```bash
zack@zackartix ~/Documents $ echo "hello" | dd of=/dev/stdout
hello
0+1 records in
0+1 records out
6 bytes copied, 4.4224e-05 s, 136 kB/s
```

### count and bs

catting the /dev/random file will yield random data.

```bash
zack@zackartix ~/Documents $ dd if=/dev/random of=/dev/stdout count=1 bs=100 status=progress
�ciA�V�0����Yvt���2
                  C#p�'��~�     1�P�NO���։��çy�j~cIYKE�n��l#TN.��SW��1. � 1+0 records in
1+0 records out
100 bytes copied, 0.000105209 s, 950 kB/s
```

the count will copy ONE BLOCK in this instance. we're specifying the amount
of blocks to copy, not the raw amount of bytes.
