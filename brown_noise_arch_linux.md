# playing brown noise in background through the terminal

install the sox package with 

```bash
sudo pacman -S sox
```

(or whatever package manager/distribution you use.)

then, run
```bash
nohup /usr/bin/play -n synth brownnoise > /dev/null 2>&1 &
```

and the volume can be controlled through whatever
mixer you're using, like pulse/pavucontrol for easy
access.

we're using nohup, since running it in the background normally doesn't 
play any audio? not exactly sure why. but this command works for me.
