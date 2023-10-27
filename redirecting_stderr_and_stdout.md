# basic stream redirection

## outputting to different files.

this is much simpler than piping to different commands.

```bash
command 2> error.log > output.log
```

this can happen in either order.

## piping the streams to different commands.

this is BASH SPECFIC command substitution.
this pipes the command's error to the first one, and 
the output to the second.

```bash
command 2> >(command_on_error) | command_on_output
```

with this, for example, you can notify-send only the error of a program,
without any of the dummy output.

to actually get the notify-send ("send" is a wrapper i wrote around 
notify-send) to restart for every line of stderr that's processed, we can
loop through each line constantly in the bash command.

here's part of a ruby script i wrote that does just that:

```ruby
def log(cmd)
  system("send 'run-os script' '#{cmd}'")
  # puts the stderr directly to the notify send.
  # immediate feedback.
  # read the stderr lines in a loop.
  system("#{cmd} 2> >(while read line; do send error \"run-os script stderr:\" \"$line\"; done)")
end
```
