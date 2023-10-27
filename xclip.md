# xclip usage

## selection

xclip -o: just print the current selection
the problem with printing the selection is that it's incompatible with
programs like vim, that select text in visual mode.

## clipboard

to puts the actual clipboard content, do xclip -sel clip -o.
to append to the clipboard, do 

```bash
xclip -sel clip < [file.txt]
```

and feed it any stdin.

you can also feed the selection stdin with xclip < [file.txt],
but that's not really useful.
