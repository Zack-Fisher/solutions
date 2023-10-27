# fixing clipboard as root (xclip)

tldr;
run the following:
```bash
xhost +si:localuser:root
```

## explanation

[source](https://stackoverflow.com/questions/48833451/no-protocol-specified-when-running-a-sudo-su-app-on-ubuntu-linux)

i kept having an error where xclip would totally freak out if i tried
to paste anything in from the global clipboard as root.

running the above command worked immediately for me.
as per the link, apparently it's a "wayland thing", since wayland
puts more importance on restricting access to graphical applications
to root.

### what is xhost?

directly from `man xhost`:

>The  xhost  program is used to add and delete host names or user names to the
>list allowed to make connections to the X server.  In the case of hosts, this
>provides a rudimentary form of privacy control and security.  It is only suf‐
>ficient for a workstation (single user) environment, although it  does  limit
>the  worst  abuses.   Environments  which require more sophisticated measures
>should implement the user-based mechanism or use the hooks  in  the  protocol
>for passing other authentication data to the server.

so it literally just controls perms w/ xorg. that's why it works.

`xhost +si:localuser:root`: add the local machine's root user to the authorized
users for the X process.
we're using "+" to __add__ to the permissions. we can use "-" to reverse this
permissions change.
