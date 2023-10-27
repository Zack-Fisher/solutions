# calculating the proper DPI, setting the DPI

### formula
DPI = sqrt((width_in_pixels**2) + (height_in_pixels**2)) / diagonal_size_in_inches

and use xrandr to get the size of the monitor, this laptop is approx 129, for example.

### setting on the machine

use ~/.Xresources:
Xft.dpi: <dpi_number>
