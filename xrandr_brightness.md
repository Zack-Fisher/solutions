# setting screen brightness

just do

```bash
xrandr --output eDP-1 --brightness .5
```

i'm not entirely sure why it isn't an xrandr "property" to set the brightness,
like in --prop or --output <device> --set, but whatever.
