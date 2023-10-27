# hdd formatting

## to remember
filesystem applies to partition,
formatting applies to filesystem.

## overview

formatting is different from the filesystem on the drive.
formatting is the partition type, which is determined by a formatting
tool like fdisk on linux.

for example, a drive can have GPT and exFAT filesystem.

## applying partition type

fdisk for normal stuff on linux, this is not too bad

GPT is funny, use
```bash
    sudo gdisk <device>
```

***
    Create a GPT partition table: Now, start gdisk on your
    drive (replace /dev/sdX with your drive's name):

    bash

    sudo gdisk /dev/sdX

    Now, type o and then press Enter to create a new empty GUID
    partition table (GPT).

    Press y and then Enter to confirm.

    Create a new partition: Then, type n to add a new
    partition. Press Enter to accept the default partition
    number 1. Again, press Enter to accept the default First
    sector. Also press Enter again to accept the default Last
    sector (this will create a partition that spans the entire
    disk).

    Now, you need to specify the partition type. Type 0700 and
    press Enter to set the partition type to Microsoft basic
    data, which is compatible with exFAT.

    Finally, type w, and then press Enter to write the changes
    to disk and exit. Press y to confirm.
***

## applying filesystem

usually the mkfs.<filesystem> tool is used.
this works in general.
