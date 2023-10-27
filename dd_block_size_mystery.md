# dd bs=X param

take a look at what happens to the write speeds when i change the 
bs=X param:

```bash
zack@zackartix ~/Downloads $ sudo dd if=9front-9931.amd64.iso of=/dev/sda status=progress bs=64M
doas (zack@zackartix) password:
8+1 records in
8+1 records out
562720768 bytes (563 MB, 537 MiB) copied, 34.1552 s, 16.5 MB/s

zack@zackartix ~/Downloads $ sudo dd if=9front-9931.amd64.iso of=/dev/sda status=progress bs=1G
doas (zack@zackartix) password:
0+1 records in
0+1 records out
562720768 bytes (563 MB, 537 MiB) copied, 33.5063 s, 16.8 MB/s

zack@zackartix ~/Downloads $ sudo blockdev --getbsz /dev/sda
doas (zack@zackartix) password:
4096

zack@zackartix ~/Downloads $ sudo dd if=9front-9931.amd64.iso of=/dev/sda status=progress bs=4K
doas (zack@zackartix) password:
137383+0 records in
137383+0 records out
562720768 bytes (563 MB, 537 MiB) copied, 42.8858 s, 13.1 MB/s

zack@zackartix ~/Downloads $ sudo dd if=9front-9931.amd64.iso of=/dev/sda status=progress bs=100
doas (zack@zackartix) password:
547203400 bytes (547 MB, 522 MiB) copied, 49 s, 11.2 MB/s
5627207+1 records in
5627207+1 records out
562720768 bytes (563 MB, 537 MiB) copied, 78.2285 s, 7.2 MB/s
```

from the comments of [this post](https://www.reddit.com/r/linuxquestions/comments/2hp3mq/what_is_the_purpose_of_the_bs4m_sync_when_using/):

>bs -> Block size. Why does this matter? This tells data dupe how to bulk up
>the operations. If you set the bs to 1K, it would mean, read up to 1 kb of
>data from 'if' and then write 1 kb of data to 'of'. In this case, we are
>saying 4 megabytes. This is useful if you know the block size of the
>filesystem or device.
>
>A NAND flash memory may be organized in 4 kb blocks. This means that even if
>you only write 1 byte of data, you have to erase and write the entire 4 kb
>block. This is inefficient when you have a lot of little 1 byte transactions.
>You can actually bulk them up until you hit 4 kb and then write to the block.
>This saves time since erasing a block in flash is time consuming. We can use
>/dev/random as an example of how it works both ways. /dev/random can block
>because it takes time to generate new random values. So when you only captured
>2kb of data, bs=4k would wait until it can read another 2kb and then write to
>the device. As for your iso which is a known finite amount of information, you
>would get a end of file (EOF) signal when you hit the end. So if that doesn't
>fill the block size, then that is why it adds nuls to pad it so it can fill the
>block size and then write to the file. 

so i figured that the write speeds would peak near any multiple of my drive's 
block size? (this is just a normal usb drive)

doesn't look like that's the case.

as was in the previous output, the command:
```bash
zack@zackartix ~/Downloads $ sudo blockdev --getbsz /dev/sda
doas (zack@zackartix) password:
4096
```
returns 4096 in bytes (?) which should be 4K (?) in the dd blocksize param (?).
