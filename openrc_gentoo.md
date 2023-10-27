# openrc notes

rc is different from systemd in that it ONLY runs systems at startup.
routine operations are handled by cron, which has an rc installable with
`emerge -a cronie`.

## adding daemons

cron daemon services will be installed from emerge directly into 
/etc/init.d for easy install. they'll be referenced by their names in this
directory by the rc-update command.

```bash
rc-update add <service_name> <run_level>
```

## making daemons

anything that uses the openrc-run shebang is a valid daemon?

```bash
#!/sbin/openrc-run
```

i wonder if you can use bash or /bin/sh instead? 
maybe if you add the service to a higher runlevel?

anyway, the important thing is that runlevels are managed by the table and 
commandline, not the service files themselves. this makes things just a little 
simpler than systemd.

## runlevels

each service must be applied to some runlevel.
they're more like system states than runlevels.

when X happens, run Y service.

it's as simple as possible.

from GPT3:
***
-Single-User Mode (also known as single or s) This state is typically used
for system maintenance and recovery purposes. It is run after the hardware
initialization and before launching the services. In this mode, only a
minimal set of essential services is started.

-Non-Networked Mode (also known as nonetwork or n) This state is often used
when network connectivity is not required during boot. It is run after
Single-User Mode and initializes basic services without network-related
components.

-Default Mode (also known as default or d) This state is the default
runlevel/state for normal system operation. It typically includes all
essential services needed for regular usage. Most distributions start in
this state by default.

-Shutdown Mode (also known as shutdown or 0) This state is entered when the
system is shutting down or rebooting. It stops all running services and
performs necessary cleanup operations.
***
