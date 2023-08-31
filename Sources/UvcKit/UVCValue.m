//
//  UVCValue.m
//
//  Structured byte-packed data containers for UVC controls.
//
//  Copyright © 2016
//  Dr. Jeffrey Frey, IT-NSS
//  University of Delaware
//
// $Id$
//

#import "UVCValue.h"

#import <objc/runtime.h>

@implementation UVCValue

  + (UVCValue*) uvcValueWithType:(UVCType*)valueType
  {
    UVCValue        *newValue = nil;
    if ( valueType ) {
      NSUInteger    extraBytes = [valueType byteSize];
      
      newValue = class_createInstance(self, extraBytes);
      if ( newValue && (newValue = [newValue init]) ) {
        newValue->_valueType = [valueType retain];
        newValue->_valuePtr = object_getIndexedIvars(newValue);
        memset(newValue->_valuePtr, 0, extraBytes);
        
        [newValue autorelease];
      }
    }
    return newValue;
  }
  
//

  - (void) dealloc
  {
    [_valueType release];
    [super dealloc];
  }

//

  - (NSString*) description
  {
    NSMutableString     *asString = [[NSMutableString alloc] initWithFormat:@"UVCValue@%p { type: %@; bytes: [", self, _valueType];
    NSUInteger          i = 0, iMax = [_valueType byteSize];
    UInt8               *p = _valuePtr;
    
    while ( i < iMax ) {
      [asString appendFormat:@"%s%02hhx", i ? ":" : "", *p++];
      i++;
    }
    [asString appendString:@"] }"];
    
    NSString            *outString = [[asString copy] autorelease];
    [asString release];
    
    return outString;
  }

//

  - (BOOL) isEqual:(id)otherObject
  {
    if ( otherObject == self ) return YES;
    
    if ( [otherObject isKindOfClass:[UVCValue class]] ) {
      if ( [_valueType isEqual:[otherObject valueType]] ) {
        return (memcmp(_valuePtr, [otherObject valuePtr], [_valueType byteSize]) == 0) ? YES : NO;
      }
    }
    return NO;
  }

//

  - (UVCType*) valueType
  {
    return _valueType;
  }

//

  - (NSUInteger) byteSize
  {
    return [_valueType byteSize];
  }

//

  - (void*) valuePtr
  {
    return _valuePtr;
  }
  
//

  - (void*) pointerToFieldAtIndex:(NSUInteger)index
  {
    NSUInteger      offset = [_valueType offsetToFieldAtIndex:index];
    
    if ( offset != kUVCTypeComponentTypeInvalid ) return (_valuePtr + offset);
    return NULL;
  }
  
//

  - (void*) pointerToFieldWithName:(NSString*)fieldName
  {
    NSUInteger      offset = [_valueType offsetToFieldWithName:fieldName];
    
    if ( offset != kUVCTypeComponentTypeInvalid ) return (_valuePtr + offset);
    return NULL;
  }
  
//

  - (BOOL) isSwappedToUSBEndian
  {
    return _isSwappedToUSBEndian;
  }

//

  - (void) byteSwapHostToUSBEndian
  {
    if ( ! _isSwappedToUSBEndian ) {
      [_valueType byteSwapHostToUSBEndian:_valuePtr];
      _isSwappedToUSBEndian = YES;
    }
  }

//

  - (void) byteSwapUSBToHostEndian
  {
    if ( _isSwappedToUSBEndian ) {
      [_valueType byteSwapUSBToHostEndian:_valuePtr];
      _isSwappedToUSBEndian = NO;
    }
  }

//

  - (BOOL) scanCString:(const char*)cString
    flags:(UVCTypeScanFlags)flags
  {
    return [_valueType scanCString:cString
                        intoBuffer:_valuePtr
                        flags:flags
                      ];
  }
  
//

  - (BOOL) scanCString:(const char*)cString
    flags:(UVCTypeScanFlags)flags
    minimum:(UVCValue*)minimum
    maximum:(UVCValue*)maximum
  {
    return [_valueType scanCString:cString
                        intoBuffer:_valuePtr
                        flags:flags
                        minimum:(minimum ? [minimum valuePtr] : NULL)
                        maximum:(maximum ? [maximum valuePtr] : NULL)
                      ];
  }

//

  - (BOOL) scanCString:(const char*)cString
    flags:(UVCTypeScanFlags)flags
    minimum:(UVCValue*)minimum
    maximum:(UVCValue*)maximum
    stepSize:(UVCValue*)stepSize
  {
    return [_valueType scanCString:cString
                        intoBuffer:_valuePtr
                        flags:flags
                        minimum:(minimum ? [minimum valuePtr] : NULL)
                        maximum:(maximum ? [maximum valuePtr] : NULL)
                        stepSize:(stepSize ? [stepSize valuePtr] : NULL)
                      ];
  }

//

  - (BOOL) scanCString:(const char*)cString
    flags:(UVCTypeScanFlags)flags
    minimum:(UVCValue*)minimum
    maximum:(UVCValue*)maximum
    stepSize:(UVCValue*)stepSize
    defaultValue:(UVCValue*)defaultValue
  {
    return [_valueType scanCString:cString
                        intoBuffer:_valuePtr
                        flags:flags
                        minimum:(minimum ? [minimum valuePtr] : NULL)
                        maximum:(maximum ? [maximum valuePtr] : NULL)
                        stepSize:(stepSize ? [stepSize valuePtr] : NULL)
                        defaultValue:(defaultValue ? [defaultValue valuePtr] : NULL)
                      ];
  }

//

  - (NSString*) stringValue
  {
    return [_valueType stringFromBuffer:_valuePtr];
  }
  
//

  - (BOOL) copyValue:(UVCValue*)otherValue
  {
    if ( [_valueType isEqual:[otherValue valueType]] ) {
      memcpy(_valuePtr, [otherValue valuePtr], [_valueType byteSize]);
    }
    return NO;
  }

@end
