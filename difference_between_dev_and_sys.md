# /dev and /sys directories

tldr;
/dev is device communication nodes, and /sys is device parameters/attrs.

## access speed

>The important thing is that '/dev' is a real filesystem (disk based) whereas '/sys' is a virtual filesystem (RAM based). 
[source](https://www.reddit.com/r/linuxquestions/comments/2rnjwm/difference_between_sysclass_and_dev_directories/)

### why?

couldn't /dev also be a RAM vfs? it's still doing
the same kind of thing?

gpt4 says:

>While /dev could theoretically be implemented as a virtual filesystem, there
>are reasons why it's not. Firstly, the files in /dev are often created
>statically at boot time, or dynamically when devices are added, regardless of
>whether they're currently in use or not. This means that there needs to be a
>persistent record of the device files, which is better suited to a disk-based
>filesystem. Also, the way that /dev is used -- primarily for reading and
>writing data to devices -- is better suited to a disk-based filesystem, which
>can handle these types of operations more efficiently.
>
>Moreover, /dev and /sys were designed with different goals in mind, and serve
>different purposes. /dev is primarily an interface for reading and writing data
>to devices, while /sys is an interface for querying and sometimes changing the
>state of devices and their drivers. While there is some overlap in
>functionality, they each handle different aspects of device management.

so the devices in /dev are inherently more flexible, since they truly
do just act like a normal filesystem on the device, down to the actual implementation.
it's __not__ a vfs.

## classes

/sys/class contains all the predefined classes of devices from the kernel.

```bash
zack@zackartix /sys $ cd class
accel           firmware       nvme-generic    spi_master
ata_device      graphics       nvme-subsystem  spi_slave
ata_link        hidraw         pci_bus         thermal
ata_port        hwmon          phy             tpm
backlight       i2c-adapter    powercap        tpmrm
bdi             ieee80211      power_supply    tty
block           input          pps             typec
bluetooth       intel_pmt      ptp             typec_mux
bsg             intel_scu_ipc  pwm             usb_power_delivery
cpuid           iommu          rc              usb_role
devcoredump     leds           regulator       vc
devfreq         lirc           remoteproc      video4linux
devfreq-event   mei            retimer         vtconsole
devlink         mem            rfkill          wakeup
dma             misc           rtc             watchdog
dma_heap        msr            scsi_device     wmi_bus
dmi             mtd            scsi_disk       wwan
drm             nd             scsi_generic
drm_dp_aux_dev  net            scsi_host
extcon          nvme           sound
```

the device folders and their corresponding attributes are in their proper
class folders.

### implementation

since leds are so common, they have a nice API to write drivers that 
manipulate them.

if you just make an led class device, then you get a full directory
and callback for adjusting the brightness, easy.

this is also likely why most class devices share "common" /sys/class/XYZ files.
they're using the same class and registry function/callbacks to be 
controlled in the same way.

```c
#include <linux/module.h>
#include <linux/leds.h>

static void my_driver_set_brightness(struct led_classdev *led_cdev,
                                     enum led_brightness value)
{
    /* Your code to set the LED brightness goes here. */
}

static struct led_classdev my_driver_led = {
    .name           = "my_driver_led",
    .brightness_set = my_driver_set_brightness,
};

static int __init my_driver_init(void)
{
    return led_classdev_register(NULL, &my_driver_led);
}

static void __exit my_driver_exit(void)
{
    led_classdev_unregister(&my_driver_led);
}

module_init(my_driver_init);
module_exit(my_driver_exit);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("My driver");
MODULE_AUTHOR("Your Name");
```

altogether, /dev registry and /class registry are pretty similar, 
at the driver level. they simply serve different purposes from eachother.

__they are not alternatives, they're two sides of different concepts.__

## example

leds have parameters in /sys/class/leds.

we'll inspect the leds class folder...

```bash
zack@zackartix /sys/class $ cd leds
asus::kbd_backlight  input3::numlock     phy0-led
input3::capslock     input3::scrolllock
```

and see there's a bunch of led device folders.
what's in the keyboard backlight device?

```bash
zack@zackartix /sys/class/leds $ cd asus\:\:kbd_backlight
brightness             kbd_rgb_state        power      uevent
brightness_hw_changed  kbd_rgb_state_index  subsystem
device                 max_brightness       trigger
```

all the parameters that the system can use for interaction with the device!
for example, what's the "max_brightness" of the device?

```bash
zack@zackartix /sys/class/leds/asus::kbd_backlight $ cat max_brightness
3
```

### small warning

be careful with changing stuff in /sys/class. sometimes, you'll get weird
IO errors for no reason. this is because these are special files, overviewed
by a device driver, and they reserve the right to block writes or reads from
a node file manually.

## gpt says

from gpt4:

>The device nodes in /dev and the entries under /sys/class are related, but they
>serve different purposes and they don't behave the same way.
>
>/dev: The /dev directory contains device nodes. These are special files that
>provide a way for user-space applications to interact with devices. User-space
>applications can open these files and read from or write to them to interact
>with the device. This is a very direct way of interacting with a device - when
>an application reads or writes a device node, it is reading or writing directly
>to or from the device's I/O buffers.
>
>/sys/class: The /sys/class directory is part of the sysfs filesystem. Sysfs is
>a virtual filesystem provided by the Linux kernel that provides a way to export
>kernel data structures, their attributes, and the relationships between them to
>user space. In the case of devices, each directory under /sys/class represents
>a class of devices, and each subdirectory of those represents a specific
>device. These directories contain attribute files that can be used to query or
>change the state of the device. For example, for an LED device in the 'leds'
>class, there might be an attribute for the current brightness of the LED that
>can be read or written.
>
>So while they are both interfaces to interact with the device, they are used
>for different purposes. The /dev nodes are generally used for data I/O
>operations, while the /sys/class entries are used for querying and controlling
>the state of the device and its driver.
>
>For example, let's take a look at a serial port (tty) device. An application
>might open /dev/ttyS0 to send and receive data over the serial port. But if you
>wanted to find out the current baud rate, you'd look at an attribute file in
>/sys/class/tty/ttyS0.
>
>In terms of APIs, reading and writing to /dev nodes is done with the standard
>file I/O functions like read() and write(). Interacting with /sys/class is also
>done with file I/O functions, but the semantics can be different because you're
>reading or writing device attributes, not device I/O buffers. The specifics of
>what each attribute does and how to use it are usually documented in the kernel
>source code or other kernel documentation.
