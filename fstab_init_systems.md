# how is fstab run through?

it's handled by the init system.
on openrc, it's handled through localmount.

```bash
depend() {
  need localmount # only activate if the fstab has been run through.
  after bootmisc alsasound
}
```
