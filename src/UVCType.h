//
//  UVCType.h
//
//  Abstract data types for UVC controls.
//
//  Copyright © 2016
//  Dr. Jeffrey Frey, IT-NSS
//  University of Delaware
//
// $Id$
//

#import <Foundation/Foundation.h>

/*!
  @typedef UVCTypeComponentType
  
  Enumerates the atomic data types that the UVCType class implements.
  These are underlying types used by the UVC standard in control
  interfaces.
*/
typedef enum {
  kUVCTypeComponentTypeInvalid   = 0,
  kUVCTypeComponentTypeBoolean,
  kUVCTypeComponentTypeSInt8,
  kUVCTypeComponentTypeUInt8,
  kUVCTypeComponentTypeBitmap8,
  kUVCTypeComponentTypeSInt16,
  kUVCTypeComponentTypeUInt16,
  kUVCTypeComponentTypeBitmap16,
  kUVCTypeComponentTypeSInt32,
  kUVCTypeComponentTypeUInt32,
  kUVCTypeComponentTypeBitmap32,
  kUVCTypeComponentTypeSInt64,
  kUVCTypeComponentTypeUInt64,
  kUVCTypeComponentTypeBitmap64,
  kUVCTypeComponentTypeMax
} UVCTypeComponentType;

/*!
  @function UVCTypeComponentByteSize
  
  Returns the number of bytes occupied by the given componentType or
  zero (0) if componentType was invalid.
*/
NSUInteger UVCTypeComponentByteSize(UVCTypeComponentType componentType);

/*!
  @defined UVCTypeInvalidIndex
  
  Constant returned by UVCType to indicate that a field index was out
  of range.
*/
#define UVCTypeInvalidIndex NSUIntegerMax

/*!
  @typedef UVCTypeScanFlags
  
  Enumerates bitmask components that alter the behavior of the scanCString:*
  methods of UVCType.
  
  The kUVCTypeScanFlagShowWarnings flag allows warning messages to be
  written to stderr as the routines parse a cString.  Additionallly, the
  kUVCTypeScanFlagShowInfo flag produces more extensive output to stderr
  as the cString is processed (more like debugging information). 
*/
typedef enum {
  kUVCTypeScanFlagShowWarnings    = 1 << 0,
  kUVCTypeScanFlagShowInfo        = 1 << 1
} UVCTypeScanFlags;

/*!
  @class UVCType
  @abstract Abstract data type comprised of UVCTypeComponentType atomic types
  
  Instances of the UVCType class represent the structured data brokered by
  UVC controls.  A UVCType comprises one or more named data structure fields in
  a specific order, with each having an atomic type from the
  UVCTypeComponentType enumeration.
  
  The set of fields correlate to a packed C struct without word boundary padding;
  this also correlates directly to the format of UVC control data.
  
  In case this code were to be compiled on a big-endian host, byte-swapping
  routines are included which can reorder an external buffer (containing the
  UVC control data structured by the UVCType) to and from USB (little) endian.
  
  Methods are included to calculate relative byte offsets of the component fields,
  either by index of the name of the field.  Also, the number of bytes occupied
  by the UVCType is available via the byteSize method.
  
  Methods are also provided to initialize an external buffer structured by a
  UVCType using textual input (from a C string).
*/
@interface UVCType : NSObject
{
  NSUInteger    _fieldCount;
  BOOL          _needsNoByteSwap;
  void          *_fields;
}

/*!
  @method uvcTypeWithCString:
  
  Returns an autoreleased instance of UVCType initialized with the component field(s)
  described by a C string.  The C string must begin and end with curly braces and
  include one or more named types.  Each named type follows the syntax:
  
    [type] [name];
    
  where [name] is the component name (alphanumeric characters and '-') and the [type]
  is one of:
  
    [type]    description
    B         UInt8, accepting only 0 and 1
    S1        SInt8 / char
    U1        UInt8 / unsigned char
    M1        UInt8 / unsigned char as a bitmap
    S2        SInt16 / short
    U2        UInt16 / unsigned short
    M2        UInt16 / unsigned short as a bitmap
    S4        SInt32 / int
    U4        UInt32 / unsigned int
    M4        UInt32 / unsigned int as a bitmap
    S8        SInt64 / long long int
    U8        UInt64 / unsigned long long int
    M8        UInt64 / unsigned long long int as a bitmap
  
  For types with a single field, the [name] can be omitted:
  
    {S2}
    
  Other examples:
  
    { S2 pan; S2 tilt; }
    
*/
+ (UVCType*) uvcTypeWithCString:(const char*)typeDescription;

/*!
  @method uvcTypeWithFieldNamesAndTypes:
  
  Returns an autoreleased instance of UVCType initialized with an arbitrary length sequence
  of component field names and types, followed by nil or NULL.  For example:
  
    [uvcTypeWithFieldNamesAndTypes:@"pan", kUVCTypeComponentTypeSInt16, @"tilt", kUVCTypeComponentTypeSInt16, nil];

*/
+ (UVCType*) uvcTypeWithFieldNamesAndTypes:(NSString*)name,...;

/*!
  @method uvcTypeWithFieldCount:names:types:
  
  Returns an autoreleased instance of UVCType initialized using two C arrays of component
  field names (as NSString instances) and types.  The arrays must have at least count elements
  present.
*/
+ (UVCType*) uvcTypeWithFieldCount:(NSUInteger)count names:(NSString**)names types:(UVCTypeComponentType*)types;

/*!
  @method fieldCount
  
  Returns the number of component fields in the structure represented by the receiver.
*/
- (NSUInteger) fieldCount;

/*!
  @method fieldNameAtIndex:
  
  Returns the name associated with the component field at the given index.
  
  Returns nil if index is out of range.
*/
- (NSString*) fieldNameAtIndex:(NSUInteger)index;

/*!
  @method fieldTypeAtIndex:
  
  Returns the type associated with the component field at the given index.
  
  Returns kUVCTypeComponentTypeInvalid if index is out of range.
*/
- (UVCTypeComponentType) fieldTypeAtIndex:(NSUInteger)index;

/*!
  @method indexOfFieldWithName:
  
  If one of the receiver's component fields is named the same as fieldName (under a case-insensitive
  string comparison) returns the index of that field.  Otherwise, UVCTypeInvalidIndex is returned.
*/
- (NSUInteger) indexOfFieldWithName:(NSString*)fieldName;

/*!
  @method byteSize
  
  Returns the number of bytes that data structured according to the receiver's component field
  types would occupy.
*/
- (NSUInteger) byteSize;

/*!
  @method offsetToFieldAtIndex:
  
  Returns the relative offset (in bytes) at which the given component field would be found in a
  buffer structured according to the receiver's component field types.
  
  Returns UVCTypeInvalidIndex if index is out of range.
*/
- (NSUInteger) offsetToFieldAtIndex:(NSUInteger)index;

/*!
  @method offsetToFieldWithName:
  
  Returns the relative offset (in bytes) at which the given component field (identified by
  case-insensitive string comparison against fieldName) would be found in a buffer structured
  according to the receiver's component field types.
  
  Returns UVCTypeInvalidIndex if index is out of range.
*/
- (NSUInteger) offsetToFieldWithName:(NSString*)fieldName;

/*!
  @method byteSwapHostToUSBEndian:
  
  Given an external buffer structured according to the receiver's component field types,
  byte swap all necessary component fields (anything larger than 1 byte) from the host endian
  to USB (little) endian.
*/
- (void) byteSwapHostToUSBEndian:(void*)buffer;

/*!
  @method byteSwapUSBToHostEndian:
  
  Given an external buffer structured according to the receiver's component field types,
  byte swap all necessary component fields (anything larger than 1 byte) from USB (little)
  endian to host endian.
*/
- (void) byteSwapUSBToHostEndian:(void*)buffer;

/*!
  @method scanCString:intoBuffer:flags:
  
  Convenience method that calls
  
    [self scanCString:cString intoBuffer:buffer flags:flags minimum:NULL maximum:NULL stepSize:NULL defaultValue:NULL]
*/
- (BOOL) scanCString:(const char*)cString intoBuffer:(void*)buffer flags:(UVCTypeScanFlags)flags;

/*!
  @method scanCString:intoBuffer:flags:minimum:maximum:
  
  Convenience method that calls
  
    [self scanCString:cString intoBuffer:buffer flags:flags minimum:minimum maximum:maximum stepSize:NULL defaultValue:NULL]
*/
- (BOOL) scanCString:(const char*)cString intoBuffer:(void*)buffer flags:(UVCTypeScanFlags)flags minimum:(void*)minimum maximum:(void*)maximum;

/*!
  @method scanCString:intoBuffer:flags:minimum:maximum:stepSize:
  
  Convenience method that calls
  
    [self scanCString:cString intoBuffer:buffer flags:flags minimum:minimum maximum:maximum stepSize:stepSize defaultValue:NULL]
*/
- (BOOL) scanCString:(const char*)cString intoBuffer:(void*)buffer flags:(UVCTypeScanFlags)flags minimum:(void*)minimum maximum:(void*)maximum stepSize:(void*)stepSize;

/*!
  @method scanCString:intoBuffer:flags:minimum:maximum:stepSize:defaultValue:
  
  The arguments buffer, minimum, maximum, stepSize, and defaultValue are all assumed to be at least as
  large as the receiver's [self byteSize] method would return.  If any of minimum, maximum, stepSize, or
  defaultValue are non-NULL, they are assumed to contain the corresponding limit data read from the UVC
  device.
  
  Parses cString and attempts to fill-in the provided buffer according to the receiver's component fields.
  The component values must be contained within curly braces, and values should be delimited using a
  comma.  Whitespace is permissible around words and commas.
  
  Use of a floating-point (fractional) value for a component requires that minimum and maximum are non-NULL.
  The fractional value maps to the correponding value in that range, with 0.0f being the minimum.
  
  The words "default," "minimum," and "maximum" are permissible on components so long as minimum,
  maximum, or defaultValue are non-NULL.
  
  Receivers with a single component may omit the curly braces.
  
  If the words "default," "minimum," or "maximum" are the entirety of cString, then the corresponding
  value is set for all component fields, provided the corresponding pointer argument is non-NULL.
  
  The flags bitmask controls this function's behavior.  At this time, the only flags present enable
  informative output to stderr as the parsing progresses.
  
  Returns YES if all component fields of the receiver were successfully set in the provided buffer.
  
  Examples:
    
    Type            Value
    {S2}            "25"
    {S2}            "{=25}" (same as previous)
    {S2 x; S2 y;}   "{0,1}"
    {S2 x; S2 y;}   "{y=1,x=0}" (same as previous)
    {S2 w; S2 h;}   "{h=minimum,w=default}" (provided minimum and defaultValue are non-NULL)
    {S2 w; S2 h;}   "{default,minimum}" (same as previous)

*/
- (BOOL) scanCString:(const char*)cString intoBuffer:(void*)buffer flags:(UVCTypeScanFlags)flags minimum:(void*)minimum maximum:(void*)maximum stepSize:(void*)stepSize defaultValue:(void*)defaultValue;

/*!
  @method stringFromBuffer:
  
  Create a formatted textual description of the data in the external buffer structured according to
  the receiver's component field types.  E.g.
  
    "{pan=3600,tilt=-360000}"
    
*/
- (NSString*) stringFromBuffer:(void*)buffer;

/*!
  @method typeSummaryString
  
  Returns a human-readable description of the receiver's component field types.
*/
- (NSString*) typeSummaryString;

@end
