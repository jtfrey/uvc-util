//
//  UVCController.h
//
//  USB Video Class (UVC) interface to UVC-compatible video devices.
//
//  Copyright © 2016
//  Dr. Jeffrey Frey, IT-NSS
//  University of Delaware
//
// $Id$
//

#import <Foundation/Foundation.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/IOMessage.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>

#import "UVCValue.h"

//
// Forward-declare the UVCControl class:
//
@class UVCControl;

/*!
  @class UVCController
  @abstract USB Video Class (UVC) device control wrapper.

  An instance of this class is used to interact with the software controls on a
  USB video capture device.

  The class performs extensive checking of the USB device when an instance is
  instantiated.  The vendor- and product-id; USB location id; interface index;
  version of the UVC specification implemented; and the control enablement bit
  vectors are all explored and retained when available.
*/
@interface UVCController : NSObject
{
  NSString                      *_deviceName;
  UInt32                        _locationId;
  UInt16                        _vendorId, _productId;
  
  // All necessary functionality comes from USB standard 2.2.0:
  IOUSBInterfaceInterface220    **_controllerInterface;
  
  BOOL                          _isInterfaceOpen;
  BOOL                          _shouldNotCloseInterface;
  uint8_t                       _videoInterfaceIndex;
  NSMutableDictionary           *_controls;
  NSMutableDictionary           *_unitIds;
  UInt16                        _uvcVersion;
  NSData                        *_terminalControlsAvailable;
  NSData                        *_processingUnitControlsAvailable;
}

/*!
  @method uvcControllers

  Scan the USB bus and locate all video devices that appear to be UVC-compliant.
  Returns an NSArray containing all such devices, or nil if no devices were
  present.
*/
+ (NSArray*) uvcControllers;

/*!
  @method uvcControllerWithService:

  Returns an autoreleased instance of the class which wraps the given device from
  the I/O Registry.  The caller retains ownership of the reference ioService and is
  responsible for releasing it.

  If the device referenced by ioService is not UVC-compliant, nil is returned.
*/
+ (id) uvcControllerWithService:(io_service_t)ioService;

/*!
  @method uvcControllerWithLocationId:

  Attempts to locate a USB device with the given locationID property.  If the
  device is found (and appears to be UVC-compliant) an autoreleased instance of
  the class is returned.  Otherwise, nil is returned.

  Note that the locationID should uniquely identify a single device.
*/
+ (id) uvcControllerWithLocationId:(UInt32)locationId;

/*!
  @method uvcControllerWithVendorId:productId:

  Attempts to locate a USB device with the given vendor and product identifier
  properties.  If a device is found (and appears to be UVC-compliant) an autoreleased
  instance of the class is returned.  Otherwise, nil is returned.

  Note that this merely chooses the first USB device found in the I/O Registry with
  the given vendor and product identifier.  If there are multiple devices, the
  uvcControllers method should be used to retrieve an array of all UVC-compliant
  devices.
*/
+ (id) uvcControllerWithVendorId:(UInt16)vendorId productId:(UInt16)productId;

/*!
  @method deviceName

  Returns the name of the USB device.
*/
- (NSString*) deviceName;

/*!
  @method locationId

  Returns the 32-bit USB locationId of the device on this system.
*/
- (UInt32) locationId;

/*!
  @method vendorId

  Returns the 16-bit USB vendor identifier for the device.
*/
- (UInt16) vendorId;

/*!
  @method productId

  Returns the 16-bit USB product identifier for the device.
*/
- (UInt16) productId;

/*!
  @method uvcVersion

  Returns the version of the UVC specification which the device
  implements (as a binary-coded decimal value, e.g. 0x0210 = 2.10).
*/
- (UInt16) uvcVersion;

/*!
  @method isInterfaceOpen

  Returns YES if the device interface is open.  The interface must be
  open in order to send/receive control requests.
*/
- (BOOL) isInterfaceOpen;

/*!
  @method setIsInterfaceOpen:

  Force the device interface into an open- or closed-state.
*/
- (void) setIsInterfaceOpen:(BOOL)isInterfaceOpen;

/*!
  @method controlStrings

  Returns the array of all control names to which this class responds.
*/
+ (NSArray*) controlStrings;

/*!
  @method controlStrings

  Returns the array of all control names to which this class responds.
*/
- (NSArray*) controlStrings;

/*!
  @method controlWithName:

  Attempt to retrieve a UVCControl wrapper for the given controlName.  If
  the receiver has previously instantiated the control, the cached copy is
  returned.  If not, the capability data pulled from the device is
  consulted (if it exists) to determine whether or not the control is
  available.  If it is (or the device returned no such capability
  information) a new UVCControl object is instantiated.  If successfully
  instantiated, the new control is cached and returned to the caller.
*/
- (UVCControl*) controlWithName:(NSString*)controlName;

@end

/*!
  @typedef uvc_capabilities_t

  Flags used internally by UVCControl to indicate what operations/fields the
  control supports.
*/
typedef NSUInteger uvc_capabilities_t;

/*!
  @class UVCControl
  @abstract Wrapper for individual UVC controls.

  Each instance of UVCController manages a collection of UVC controls that the device
  has available.  Each control is represented by an instance of the UVCControl
  class, which abstracts the control meta-data and interaction with the control.
*/
@interface UVCControl : NSObject
{
  UVCController       *_parentController;
  NSUInteger          _controlIndex;
  NSString            *_controlName;
  uvc_capabilities_t  _capabilities;
  UVCValue            *_currentValue;
  UVCValue            *_minimum, *_maximum, *_stepSize;
  UVCValue            *_defaultValue;
}

/*!
  @method supportsGetValue

  Returns YES if the value of this control can be read.
*/
- (BOOL) supportsGetValue;

/*!
  @method supportsSetValue

  Returns YES if the value of this control can be modified.
*/
- (BOOL) supportsSetValue;

/*!
  @method hasRange

  Returns YES if this control provides a range for its values.
*/
- (BOOL) hasRange;

/*!
  @method hasStepSize

  Returns YES if this control provides a step-size (resolution)
  for its values.
*/
- (BOOL) hasStepSize;

/*!
  @method hasDefaultValue

  Returns YES if this control provides a default value.
*/
- (BOOL) hasDefaultValue;

/*!
  @method controlName

  Returns the textual name of the control.  This is the same string used
  to reference the control is the controlWithName: method of UVCController.
*/
- (NSString*) controlName;

/*!
  @method currentValue
  
  Attempts to read the current value of the control from the device.  If
  successful, the returned reference to the receiver's UVCValue object
  contains the current value.
  
  Returns nil if the control could not be read.
  
  The return
*/
- (UVCValue*) currentValue;

/*!
  @method minimum
  
  Returns the minimum value(s) provided by the device for the receiver control
  or nil if the device provided no minimum.
*/
- (UVCValue*) minimum;

/*!
  @method maximum
  
  Returns the maximum value(s) provided by the device for the receiver control
  or nil if the device provided no maximum.
*/
- (UVCValue*) maximum;

/*!
  @method stepSize
  
  Returns the step size (resolution) value(s) provided by the device for the
  receiver control or nil if the device provided no step size.
*/
- (UVCValue*) stepSize;

/*!
  @method defaultValue
  
  Returns the default value(s) provided by the device for the receiver control
  or nil if the device provided no defaults.
*/
- (UVCValue*) defaultValue;

/*!
  @method resetToDefaultValue
  
  If the receiver control has a default value (provided by the device) attempt
  to set the control to the defaults.
  
  Returns YES if a default value was present and was successfully written to
  the device.
*/
- (BOOL) resetToDefaultValue;

/*!
  @method setCurrentValueFromCString:flags:
  
  Attempts to parse cString using the receiver's native UVCType, filling-in
  the currentValue UVCValue object with the parsed values.  See the UVCType
  documentation for a description of the acceptable formats, etc.
  
  Returns YES if currentValue was successfully set.
*/
- (BOOL) setCurrentValueFromCString:(const char*)cString flags:(UVCTypeScanFlags)flags;

/*!
  @method readIntoCurrentValue
  
  Attempts to read the receiver control's value from the device, storing the
  value in the receiver's UVCValue object.  The UVCValue object can be accessed
  using the currentValue method.
  
  Returns YES if successful.
*/
- (BOOL) readIntoCurrentValue;

/*!
  @method writeFromCurrentValue
  
  Attempts to write the value stored in the receiver's UVCValue object to the receiver
  control on the device.  The UVCValue object can be accessed using the currentValue
  method; its data buffer can be modified by external software agents prior to calling
  this method.
  
  Returns YES if successful.
*/
- (BOOL) writeFromCurrentValue;

/*!
  @method summaryString
  
  Returns an autorelease string that summarizes the structure and attributes of
  the receiver control; should be adequately human-readable.
*/
- (NSString*) summaryString;

@end

//
// Control names, Terminal
//
FOUNDATION_EXPORT NSString *UVCTerminalControlScanningMode;
FOUNDATION_EXPORT NSString *UVCTerminalControlAutoExposureMode;
FOUNDATION_EXPORT NSString *UVCTerminalControlAutoExposurePriority;
FOUNDATION_EXPORT NSString *UVCTerminalControlExposureTimeAbsolute;
FOUNDATION_EXPORT NSString *UVCTerminalControlExposureTimeRelative;
FOUNDATION_EXPORT NSString *UVCTerminalControlFocusAbsolute;
FOUNDATION_EXPORT NSString *UVCTerminalControlFocusRelative;
FOUNDATION_EXPORT NSString *UVCTerminalControlAutoFocus;
FOUNDATION_EXPORT NSString *UVCTerminalControlIrisAbsolute;
FOUNDATION_EXPORT NSString *UVCTerminalControlIrisRelative;
FOUNDATION_EXPORT NSString *UVCTerminalControlZoomAbsolute;
FOUNDATION_EXPORT NSString *UVCTerminalControlZoomRelative;
FOUNDATION_EXPORT NSString *UVCTerminalControlPanTiltAbsolute;
FOUNDATION_EXPORT NSString *UVCTerminalControlPanTiltRelative;
FOUNDATION_EXPORT NSString *UVCTerminalControlRollAbsolute;
FOUNDATION_EXPORT NSString *UVCTerminalControlRollRelative;
FOUNDATION_EXPORT NSString *UVCTerminalControlFocusAuto;
FOUNDATION_EXPORT NSString *UVCTerminalControlPrivacy;
FOUNDATION_EXPORT NSString *UVCTerminalControlFocusSimple;
FOUNDATION_EXPORT NSString *UVCTerminalControlWindow;
FOUNDATION_EXPORT NSString *UVCTerminalControlRegionOfInterest;

//
// Control names, Processing Unit
//
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlBacklightCompensation;
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlBrightness;
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlContrast;
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlGain;
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlPowerLineFrequency;
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlHue;
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlSaturation;
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlSharpness;
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlGamma;
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlWhiteBalanceTemperature;
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlAutoWhiteBalanceTemperature;
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlWhiteBalanceComponent;
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlAutoWhiteBalanceComponent;
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlDigitalMultiplier;
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlDigitalMultiplierLimit;
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlAutoHue;
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlAnalogVideoStandard;
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlAnalogLockStatus;
FOUNDATION_EXPORT NSString *UVCProcessingUnitControlAutoContrast;
