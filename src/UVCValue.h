//
//  UVCValue.h
//
//  Structured byte-packed data containers for UVC controls.
//
//  Copyright © 2016
//  Dr. Jeffrey Frey, IT-NSS
//  University of Delaware
//
// $Id$
//

#import "UVCType.h"

/*!
  @class UVCValue
  @abstract Structured byte-packed data container
  
  An instance of UVCValue combines the structural meta-data from a UVCType
  instance with a memory buffer of sufficient size to hold data of that
  type.
  
  Many of the methods provided by UVCType are duplicated in UVCValue, but
  lack the specification of an external buffer (since UVCValue itself contains
  the buffer in question).
*/
@interface UVCValue : NSObject
{
  BOOL                _isSwappedToUSBEndian;
  UVCType             *_valueType;
  void                *_valuePtr;
}

/*!
  @method uvcValueWithType:
  
  Returns an autoreleased instance of UVCValue which wraps a buffer sized
  according to [valueType byteSize] and uses valueType as its structural
  meta-data.
*/
+ (UVCValue*) uvcValueWithType:(UVCType*)valueType;

/*!
  @method valueType
  
  Returns the UVCType that acts as the structural meta-data for the
  receiver.
*/
- (UVCType*) valueType;

/*!
  @method valuePtr
  
  Returns the base address of the receiver's memory buffer (where data
  structured according to the valueType should be stored).
*/
- (void*) valuePtr;

/*!
  @method byteSize
  
  Returns the number of bytes occupied by the receiver's valueType.
*/
- (NSUInteger) byteSize;

/*!
  @method pointerToFieldAtIndex:
  
  Calculates the base pointer of the given field within the receiver's
  memory buffer.
  
  Returns NULL if index is out of range.
*/
- (void*) pointerToFieldAtIndex:(NSUInteger)index;

/*!
  @method pointerToFieldWithName:
  
  Calculates the base pointer of the given field (under a case-insensitive
  string comparison against fieldName) within the receiver's memory buffer.
  
  Returns NULL if index is out of range.
*/
- (void*) pointerToFieldWithName:(NSString*)fieldName;

/*!
  @method isSwappedToUSBEndian
  
  Returns YES if the receiver's memory buffer has been byte-swapped to USB
  (little) endian.
*/
- (BOOL) isSwappedToUSBEndian;

/*!
  @method byteSwapHostToUSBEndian
  
  If the receiver is currently in host endian order, byte swap all necessary
  component fields of the receiver's memory buffer (anything larger than 1
  byte) from the host endian to USB (little) endian.
*/
- (void) byteSwapHostToUSBEndian;

/*!
  @method byteSwapUSBToHostEndian:
  
  If the receiver is currently byte-swapped to USB (little) endian, byte
  swap all necessary component fields of the receiver's memory buffer
  (anything larger than 1 byte) from USB (little) endian to host endian.
*/
- (void) byteSwapUSBToHostEndian;

/*!
  @method scanCString:flags:
  
  Convenience method that calls
  
    [self scanCString:cString flags:flags minimum:NULL maximum:NULL stepSize:NULL defaultValue:NULL]
*/
- (BOOL) scanCString:(const char*)cString flags:(UVCTypeScanFlags)flags;

/*!
  @method scanCString:flags:minimum:maximum:
  
  Convenience method that calls
  
    [self scanCString:cString flags:flags minimum:minimum maximum:maximum stepSize:NULL defaultValue:NULL]
*/
- (BOOL) scanCString:(const char*)cString flags:(UVCTypeScanFlags)flags minimum:(UVCValue*)minimum maximum:(UVCValue*)maximum;

/*!
  @method scanCString:flags:minimum:maximum:stepSize:
  
  Convenience method that calls
  
    [self scanCString:cString flags:flags minimum:minimum maximum:maximum stepSize:stepSize defaultValue:NULL]
*/
- (BOOL) scanCString:(const char*)cString flags:(UVCTypeScanFlags)flags minimum:(UVCValue*)minimum maximum:(UVCValue*)maximum stepSize:(UVCValue*)stepSize;

/*!
  @method scanCString:flags:minimum:maximum:stepSize:defaultValue:
  
  Send the scanCString:intoBuffer:flags:minimum:maximum:stepSize:defaultValue: message
  to the receiver's UVCType, using the receiver's valuePtr as the buffer.
  
  See UVCType's documentation for a description of the acceptable C string
  format.
  
  Returns YES if all component fields of the receiver's memory buffer were
  successfully set.
*/
- (BOOL) scanCString:(const char*)cString flags:(UVCTypeScanFlags)flags minimum:(UVCValue*)minimum maximum:(UVCValue*)maximum stepSize:(UVCValue*)stepSize defaultValue:(UVCValue*)defaultValue;

/*!
  @method stringValue
  
  Returns a human-readable description of the receiver's data, as structured by its
  UVCType.
  
  Example:
  
    "{pan=3600,tilt=-360000}"
    
*/
- (NSString*) stringValue;

/*!
  @method copyValue:
  
  If [otherValue valueType] matches the receiver's UVCType (same layout of atomic
  types) then the requisite number of bytes from [otherValue valuePtr] are copied
  to the receiver's memory buffer.
*/
- (BOOL) copyValue:(UVCValue*)otherValue;

@end
