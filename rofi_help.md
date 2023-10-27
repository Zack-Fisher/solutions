# rofi misc

### rofi fuzzyfinding
rofi -show dmenu -matching fuzzy

we can also turn on fuzzy by default in the config file ~/.config/rofi/config.rasi

### example rofi config

configuration {
    font: "ProggyCleanTT 20";
    combi-modi: "window,drun,ssh";
}
@theme "/usr/share/rofi/themes/Monokai.rasi"

### theme selection

use the rofi-theme-selector to select a rofi theme from the predownloaded ones with the pacman package.
user installed themes can be used, just place in the /usr/share/rofi/themes/ dir
or the pwd of the config.rasi file.

themes are just config extensions.

