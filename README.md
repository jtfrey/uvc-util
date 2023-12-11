# uvc-util
USB Video Class (UVC) control management utility for Mac OS X

This code arose from a need for a command-line utility on Mac OS X that could query and modify UVC camera controls (like contrast and brightness).  It presently implements all Terminal and Processing Unit controls available under the [1.1 standard](http://www.cajunbot.com/wiki/images/8/85/USB_Video_Class_1.1.pdf "UVC 1.1 PDF").  Additional [1.5 standard](https://www.usb.org/sites/default/files/USB_Video_Class_1_5.zip) Terminal and Processing Unit controls were added for the 1.2 release of this software.

Control values are implemented using a class (UVCType) that represents byte-packed data structures containing core atomic types (8-, 16-, 32-, and 64-bit integers).  Multi-component types allow fields to be named.  Another class (UVCValue) uses UVCType and a memory buffer to manage data structured according to that UVCType.  Thus, the code knows how each implemented UVC control's data is structured, which allows for per-component byte-swapping when necessary, etc.

Unlike other (GUI-based) utilities, this code only makes use of the IOKit to walk the USB bus, searching for UVC-compliant devices.

## Features

THe program has built-in help, available via the `-h` or `--help` flag:

~~~~
usage:

    ./uvc-util {options/actions/target selection}

  Options:

    -h/--help                              Show this information
    -v/--version                           Show the version of the program
    -k/--keep-running                      Continue processing additional actions despite
                                           encountering errors

  Actions:

    -d/--list-devices                      Display a list of all UVC-capable devices
    -c/--list-controls                     Display a list of UVC controls implemented

    Available after a target device is selected:

    -c/--list-controls                     Display a list of UVC controls available for
                                           the target device

    -S <control-name>                      Display available information for the given
    --show-control=<control-name>          UVC control:  component fields for multi-value
                                           types, minimum, maximum, resolution, and default
                                           value when provided:

        pan-tilt-abs {
          type-description: {
            signed 32-bit integer            pan;
            signed 32-bit integer            tilt;
          },
          minimum: {pan=-648000,tilt=-648000}
          maximum: {pan=648000,tilt=648000}
          step-size: {pan=3600,tilt=3600}
          default-value: {pan=0,tilt=0}
        }

    -g <control-name>                      Get the value of a control.
    --get=<control-name>

    -o <control-name>                      Same as -g/--get, but ONLY the value of the control
    --get-value=<control-name>             is displayed (no label)

    -s <control-name>=<value>              Set the value of a control; see below for a
    --set=<control-name>=<value>           description of <value>

    Specifying <value> for -s/--set:

      * The string "default" indicates the control should be reset to its default value(s)
        (if available)
      * The string "minimum" indicates the control should be reset to its minimum value(s)
        (if available)
      * The string "maximum" indicates the control should be reset to its maximum value(s)
        (if available)

      * Multi-component controls must provide a list of per-component values.  The values may
        be specified either in the same sequence as shown by the -S/--show-control, or by naming
        each value.  For example, the "pan-tilt-abs" control has two components, "pan" and
        "tilt" (in that order), so the following are equivalent:

            -s pan-tilt-abs="{-3600, 36000}"
            -s pan-tilt-abs="{tilt=0.52778, pan=-3600}"

      * Single-value controls should not use the brace notation, just the component value of the
        control, for example:

            -s brightness=0.5

      * Component values may be provided as fractional values (in the range [0,1]) if the control
        provides a value range (can be checked using -S/--show-control).  The value "0.0"
        corresponds to the minimum, "1.0" to the maximum.

      * Component values may use the strings "default," "minimum," or "maximum" to indicate that
        the component's default, minimum, or maximum value should be used (if the control provides one,
        can be checked using -S/--show-control)

            -s pan-tilt-abs="{default,minimum}"
            -s pan-tilt-abs="{tilt=-648000,pan=default}"

  Methods for selecting the target device:

    -0
    --select-none

         Drop the selected target device

    -I <device-index>
    --select-by-index=<device-index>

         Index of the device in the list of all devices (zero-based)

    -V <vendor-id>:<product-id>
    --select-by-vendor-and-product-id=<vendor-id>:<product-id>

         Provide the hexadecimal- or integer-valued vendor and product identifier
         (Prefix hexadecimal values with "0x")

    -L <location-id>
    --select-by-location-id=<location-id>

         Provide the hexadecimal- or integer-valued USB locationID attribute
         (Prefix hexadecimal values with "0x")

    -N <device-name>
    --select-by-name=<device-name>

         Provide the USB product name (e.g. "AV.io HDMI Video")

~~~~

## Build & Run

The source package includes an XCode project file in the top-level directory.  As time goes by — and more releases of XCode are made by Apple — any guarantee of compatibility decreases toward zero.

As an alternative, the code can be built from the command line after XCode has been installed using the `gcc` command it installs on the system.  From the `src` subdirectory of this project:

~~~~
gcc -o uvc-util -framework IOKit -framework Foundation uvc-util.m UVCController.m UVCType.m UVCValue.m
~~~~

The executable will be produced in the working directory and can be tested using

~~~~
./uvc-util --list-devices
~~~~
