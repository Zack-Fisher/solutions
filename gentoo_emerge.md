# general gentoo package management notes

### installing

```bash
emerge -a <package_name>
```

rc services will be installed directly into the /etc/init.d directory
for activation and starting by the user.

### listing all files modified by a package:

```bash
qlist -e <package_name>
```

i think that goes for the final compilation only, not the build files.

with emerge, the build files go in /var/tmp/portage/...
