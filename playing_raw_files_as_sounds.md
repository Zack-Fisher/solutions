# raw files as sound on the commandline

sox is good for this:

```bash
sox -r 44100 -b 16 -e signed-integer -c 1 -t raw waveform.raw -d
```
