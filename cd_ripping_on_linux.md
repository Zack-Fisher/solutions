# ripping a CD on arch

## setup

using cdrdao, it's not too bad.
this script downloads a video file from whatever service that
yt-dlp supports extraction of audio from.

```bash
pacman -S cdrdao yt-dlp
```

should work fine in setting up the dependencies.


## script

please excuse my BASH suckery.

we also don't need to pass the cdrom device on the system, although we can
with --device to the cdrdao command.

it'll autodetect the right device.

```bash
#/bin/sh
## simple yt-dlp wrapper around burn_dir_to_cd to download either the whole or a subset of a youtube playlist
## pass this script the name of the folder/disc and then youtube dl playlist args as the rest
## example: burn_playlist dragon_warrior_2 https://www.youtube.com/playlist?list=PLCDD6B374E7A9CAD0

MUSIC_DIR="/home/$USER/Music"

if [ -z "$1" ]; then
    echo "No folder name supplied"
    exit 1
fi

if [ -z "$2" ]; then
    echo "No youtube-dl playlist args supplied"
    exit 1
fi

cd "$MUSIC_DIR"

if [ ! -d "$1" ]; then
    mkdir "$1"
fi

cd "$1"

# we're not using the first arg anymore
shift

# args passed raw to the yt-dlp command
yt-dlp -f worstaudio -x --audio-format wav $@

toc_path=$(pwd)/burn.toc

for i in *.wav; do
    # don't convert the converted files
    if [[ ! "$i" == converted_* ]]; then
        # force the overwrite
        ffmpeg -i "$i" -acodec pcm_s16le -ac 2 -ar 44100 -y "converted_$i"
    fi
done

## write the TOC in the right path, to be passed to the cdrdao command
echo "CD_DA" > "$toc_path"

ls converted_*.wav | sort | while read -r i; do
    echo "TRACK AUDIO" >> "$toc_path"
    echo "FILE \"$i\" 0" >> "$toc_path"
done
## end TOC

cdrdao write --force --driver generic-mmc:0x20000 "$toc_path"
```
