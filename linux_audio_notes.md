# general notes on audio (pulse/alsa)

ORDER MATTERS!!!
START PA FIRST!!!

## starting pa properly

pulse takes over all the alsa sinks. that means that
whenever a program requests alsa audio, it will be routed to the default
pa sink instead.

```bash
pulseaudio --start
```
before you do ANYTHING that requests audio, or else you might end up in the
situation where the pulseaudio daemon can't really do anything, 
since something's already bound to the main alsa output.

the problem with alsa is that it can't mix or handle multiple connections
to the same soundcard.

pulse does this easily and automatically, just by redirecting everything to itself.

## configuring alsa to the proper device

pulse uses the default alsa sink for audio, so we better make sure that
it's configured to the right card!

run
```bash
aplay -l
```
and you'll see a list of cards and "devices" on those cards.

once you find the proper one, write in the ~/.asoundrc file:

```
pcm.!default {
    type plug
    card X
    device Y
}
```

to automatically use device Y on card X.

this probably isn't necessary, for most setups autoconfig will work
perfectly fine.
