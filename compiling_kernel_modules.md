# compiling and adding kernel modules to the system

## modules

.ko files are just shared library-type objects for the kernel to load
at runtime, after initramfs during whatever service/script that runs through
the modprobe configs.
(how can we compile a custom module INTO the actual kernel image itself?)

## building and adding

run the makefile, then copy all the .ko (kernel object files) to 
/lib/modules/$(uname -r), there's a bunch of fancy submodules but the root
should work just fine.

after copying/moving the .ko files, 

```bash
sudo depmod
```

to run the dependency generation, which modprobe uses.
the difference between modprobe and insmod is that modprobe actually
runs through the dependency generation before adding it, and insmod just
slaps it in there.

you only need to generate the dependencies if you're using insmod.

## ensuring persistence

on arch with either openrc or systemd, adding to some .conf file in 
/etc/modules-load.d/ just the name of the kernel module you put into
/lib/modules (without the .ko!) should work without any trouble.

for example, to load the modules gvusb2-video.ko and gvusb2-audio.ko
(device drivers for a capture card), i added

```bash
gvusb2-video
gvusb2-sound
```

to /etc/modules-load.d/general.conf.

## but dammit, don't just believe me!

i have proof.

i'm using openrc, so it's not too hard to check init.d and see there's a 
service named "modules".

```bash
find_modfiles()
{
	local dirs="/usr/lib/modules-load.d /run/modules-load.d /etc/modules-load.d"
	local basenames files fn x y
	for x in $dirs; do
		[ ! -d $x ] && continue
		for y in $x/*.conf; do
			[ -f $y ] && basenames="${basenames}\n${y##*/}"
		done
	done
	basenames=$(printf "$basenames" | sort -u)
	for x in $basenames; do
		for y in $dirs; do
			[ -r $y/$x ] &&
				fn=$y/$x
		done
		files="$files $fn"
	done
	echo $files
}
```

i don't appear to have a /run/modules-load.d on my machine, so i don't really
know what that's about.

## automatic detection, eg "when do we have to load the modules ourselves?"

gpt4 says:

>Yes, you're correct. The udev subsystem in Linux is responsible for detecting
>new devices and triggering automatic loading of their drivers, which is done
>using modprobe.

fun fact: udev is also booted directly by the init system.
check out your services directory and read the scripts, it starts a udev
daemon executable at startup.

### but, is that true?

we already know that my system's already running the udev daemon at startup,
so is it really doing this?

i have a usb capture card with associated kernel modules, and before 
inserting the device:

```bash
zack@zackartix ~/.config $ lsmod | grep -iF gvusb
```

after:

```bash
zack@zackartix ~/.config $ lsmod | grep -iF gvusb
2:gvusb2_video           40960  0
3:gvusb2_sound           20480  0
19:videobuf2_vmalloc      20480  2 gvusb2_video,uvcvideo
24:videobuf2_v4l2         40960  2 gvusb2_video,uvcvideo
28:videodev              372736  3 gvusb2_video,videobuf2_v4l2,uvcvideo
30:videobuf2_common       90112  5 gvusb2_video,videobuf2_vmalloc,videobuf2_v4l2,uvcvideo,videobuf2_memops
92:snd_pcm               200704  14 snd_hda_codec_hdmi,snd_hda_intel,snd_usb_audio,snd_hda_codec,soundwire_intel,snd_sof,snd_sof_intel_hda_common,snd_compress,snd_soc_core,snd_sof_utils,gvusb2_sound,snd_hda_core,snd_pcm_dmaengine
123:snd                   151552  15 snd_seq_device,snd_hda_codec_hdmi,snd_hwdep,snd_hda_intel,snd_usb_audio,snd_usbmidi_lib,snd_hda_codec,snd_sof,snd_timer,snd_compress,snd_soc_core,snd_pcm,gvusb2_sound,snd_rawmidi
```

wow! so scratch everything about loading the modules yourself at startup.
this is way better, just plug it in.

(where did the gvusb2 rule come from in the rules.d directory set, though?)

## WHERE DID THE RULE COME FROM????

### where is it?

the gvusb2-video/sound rule that auto-added the right rules
on the device enumeration with udev is applied during our prior
```bash
sudo depmod
```
command.

it turns out, that DIDN'T just modify modules.dep. 
it also modified a file called modules.alias.

### no but seriously who wrote that

what's modules.alias?

gpt4 says:

>The file modules.alias is generated by the depmod utility, which is typically
>run whenever the kernel is updated or new kernel modules are installed.
>...
>Aliases are, in this case, alternative names that can be used to refer to a
>module. Many modules have aliases that identify the type of hardware they
>support, often in the form of a pattern that matches the device's vendor ID,
>product ID, class, subclass, and protocol. These aliases are defined in the
>modules themselves.

so when the modules are installed onto the system, something in them tells
udev and depmod that "hey! i correspond to this vendor id!"

but we don't have to be so vague about it.
```c
MODULE_ALIAS("usb:v04B8p0005d*dc*dsc*dp*ic*isc*ip*in*");
```
here it is!

just a macro somewhere in the object file, that reads it in.

### is any of this actually true?

and check it out: right at the bottom of modules.alias...

```bash
alias usb:v04BBp0532d*dc*dsc*dp*ic*isc*ip*in* gvusb2_sound
alias usb:v04BBp0532d*dc*dsc*dp*ic*isc*ip*in* gvusb2_video
```

there it is.

and even better, here's where it was in the source:

```bash
zack@zackartix ~/Documents/c/GV-USB2-Driver $ grep -iF "MODULE_ALIAS" *
gvusb2-sound.mod.c:31:MODULE_ALIAS("usb:v04BBp0532d*dc*dsc*dp*ic*isc*ip*in*");
gvusb2-video.mod.c:31:MODULE_ALIAS("usb:v04BBp0532d*dc*dsc*dp*ic*isc*ip*in*");
```

so it's true!

the only thing left to verify is that the usb device id actually matches 
this rule, and...
```bash
Bus 003 Device 009: ID 04bb:0532 I-O Data Device, Inc. I-O DATA GV-USB2
```

is part of the output of lsusb. so MOST LIKELY, this is real and not a 
total magic lie.