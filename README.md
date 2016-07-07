# uvc-util
USB Video Class (UVC) control management utility for Mac OS X

This code arose from a need for a command-line utility on Mac OS X that could query and modify UVC camera controls (like contrast and brightness).  It presently implements all Terminal and Processing Unit controls available under the [1.1 standard](http://www.cajunbot.com/wiki/images/8/85/USB_Video_Class_1.1.pdf "UVC 1.1 PDF").

Control values are implemented using a class (UVCType) that represents byte-packed data structures containing core atomic types (8-, 16-, 32-, and 64-bit integers).  Multi-component types allow fields to be named.  Another class (UVCValue) uses UVCType and a memory buffer to manage data structured according to that UVCType.  Thus, the code knows how each implemented UVC control's data is structured, which allows for per-component byte-swapping when necessary, etc.

