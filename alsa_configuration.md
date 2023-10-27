# using alsa alone

>Plugins in ALSA do all the heavy lifting.

## where are the configs??

config files are:

system-wide - /usr/share/alsa/alsa.conf
user - ~/.asoundrc
etc - /etc/asound.conf

confusing!
the config paths are hardcoded into the alsa libraries on your system, 
most likely. if you'd like to change them, do it there? (verification needed)

## slave pcms in alsa

slave pcms allow you to pipe audio from one pcm def to another, by
calling one pcm the "slave" of the other, setting the pcm.<name>.slave
param to some other pcm_slave name.

the slave pipe behavior depends on the "type" param of the pcm.
it's really weird.

## basic guide to the configuration format

be careful with your asoundrc. alsa loads the config at runtime which
makes it easy to test (use aplay or something), but alsa loves to silently
fail and fallback on defaults.

### override

the ! in the alsa dot notation is actually an override of a parent
device.

```bash
pcm.!default {
    type plug
    slave {
        pcm "hw:2,0"
    }
}
```

this is OVERRIDING the "default" named device that's already defined in the
parent.

forgetting to override and redefining the same pcm in an asoundrc will
crash any alsa program, since the config can't load.

### pcm 

define a pcm like

pcm.<name> {
    type <type_name>
    ...
}

### pcm_slave

you could do this:

```bash
pcm.<name_one> {
  type dmix
  slave {
    pcm <name_two>
  }
}
```

you could also use the asoundrc pcm_slave notation and drag it into another
block:

```bash
pcm_slave.<slave_name> {
    pcm <name_two>
}

pcm.<name_one> {
  type dmix
  slave <slave_name>
}
```

if that's ever necessary.

### ctl

### types

## when do these alsa configs even load?

tldr; there doesn't need to be a config reloader, just reload the
individual applications. each proc runs through the alsa setup.


i asked if i could change the config locations by modifying the
kernel code and recompiling, gpt4 says:

>The ALSA configuration files (either /etc/asound.conf or ~/.asoundrc) are read
>by the ALSA library when it is initialized, which typically happens when a
>program that uses ALSA is started. ALSA does not have a long-running daemon
>that loads configuration; instead, configuration is loaded per-process by the
>library.
>
>The ALSA configuration file paths are hard-coded into the ALSA library. The
>user configuration file is located in the user's home directory and named
>.asoundrc, and the system-wide configuration file is /etc/asound.conf. There
>isn't a simple setting to change these locations without modifying the ALSA
>source code itself.

so that's not going to do anything, recompiling the kernel.

alsa is a kernel construct in the sense that it deals intimately with
hardware devices, and therefore must be composed of kernel drivers
and userspace libraries that facilitate easy communication with
the driver virtual devices.

it's just like anything else on unix, devices -> special files -> special
libs to communicate with those files, eg the numerous IOCTL calls
that are so prevalent in simple unix APIs.

from gpt4:

>So in summary, ALSA is both a set of kernel drivers and a set of user-space
>libraries. When people say that ALSA is a "kernel construct," they're usually
>referring to the fact that ALSA's drivers are part of the kernel, but the
>project also includes important user-space components.

## what's the problem with using alsa alone?

it doesn't do mixing natively, depending on the quality/features of the 
sound card. also, only one process can access it at a time.

how can we fix the limitation, and get a pulseaudio-like sink on the 
alsa-activated card/device pair with just an alsa config?

## getting around pulse requirements

most applications will let you use pulse, some might not program
for direct ALSA support.

from the [archwiki page](https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture)

>apulse[AUR] lets you use ALSA for applications that support only PulseAudio for sound. Usage is simply
>
>$ apulse application

## mixers, controls and pcms.

both controls and pcms are alsa constructs that can be spun up in the alsa
config.

```bash
pcm.!default {
    type plug
    slave {
        pcm "hw:<card_index>,<device_index>"
    }
}

ctl.!default {
    type hw
    card <card_index>
}
```

mixers, on the other hand, are sound mixing constructs on the sound card itself.
run

```bash
amixer -c <card_index> scontrols
```

to get all of the named mixers for the card.

a "control" is an interface for userspace to interact with the soundcard,
made in /dev by the kernel.

a "pcm" is a pulse-code-modulation device used to produce sound directly 
from a card.

a "mixer" modifies the audio playback from the soundcard directly.


from GPT4:

>mixers in the context of ALSA are components that allow the control of audio
>device parameters, such as the volume level, balance, etc. They work in tandem
>with controls to manage the sound card's settings.
