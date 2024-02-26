//
//  UVCType.m
//
//  Abstract data types for UVC controls.
//
//  Copyright © 2016
//  Dr. Jeffrey Frey, IT-NSS
//  University of Delaware
//
// $Id$
//

#import "UVCType.h"

#import <objc/runtime.h>
#include <stdarg.h>

//

NSUInteger
UVCTypeComponentByteSize(UVCTypeComponentType componentType)
{
  static NSUInteger byteSizes[] = {
                        0,
                        1,
                        1,
                        1,
                        1,
                        2,
                        2,
                        2,
                        4,
                        4,
                        4,
                        8,
                        8,
                        8
                      };
  if ( componentType < kUVCTypeComponentTypeMax ) return byteSizes[componentType];
  return 0;
}

//

const char*
__UVCTypeComponentTypeString(UVCTypeComponentType componentType)
{
  static const char* typeStrings[] = {
                        "<invalid>",
                        "B",
                        "S1",
                        "U1",
                        "M1",
                        "S2",
                        "U2",
                        "M2",
                        "S4",
                        "U4",
                        "M4",
                        "S8",
                        "U8",
                        "M8"
                      };
  if ( componentType < kUVCTypeComponentTypeMax ) return typeStrings[componentType];
  return 0;
}

//

const char*
__UVCTypeComponentVerboseTypeString(UVCTypeComponentType componentType)
{
  static const char* verboseTypeStrings[] = {
                        "<invalid>",
                        "boolean",
                        "signed 8-bit integer",
                        "unsigned 8-bit integer",
                        "unsigned 8-bit bitmap",
                        "signed 16-bit integer",
                        "unsigned 16-bit integer",
                        "unsigned 16-bit bitmap",
                        "signed 32-bit integer",
                        "unsigned 32-bit integer",
                        "unsigned 32-bit bitmap",
                        "signed 64-bit integer",
                        "unsigned 64-bit integer",
                        "unsigned 64-bit bitmap"
                      };
  if ( componentType < kUVCTypeComponentTypeMax ) return verboseTypeStrings[componentType];
  return 0;
}

//

UVCTypeComponentType
__UVCTypeComponentTypeFromString(
  const char            *typeDefString,
  NSUInteger            *nChar
)
{
  UVCTypeComponentType outType = kUVCTypeComponentTypeInvalid;
  NSUInteger            charConsumed = 0;
  
  while ( *typeDefString && ! isalpha(*typeDefString) ) {
    charConsumed++;
    typeDefString++;
  }
  
  switch ( *typeDefString ) {
    
    case 'B':
    case 'b': {
      outType = kUVCTypeComponentTypeBoolean;
      charConsumed++;
      break;
    }
    
    case 'M':
    case 'm': {
      charConsumed++;
      switch ( *(typeDefString + 1) ) {
        case '1':
          outType = kUVCTypeComponentTypeBitmap8;
          charConsumed++;
          break;
        case '2':
          outType = kUVCTypeComponentTypeBitmap16;
          charConsumed++;
          break;
        case '4':
          outType = kUVCTypeComponentTypeBitmap32;
          charConsumed++;
          break;
        case '8':
          outType = kUVCTypeComponentTypeBitmap64;
          charConsumed++;
          break;
      }
      break;
    }
    
    case 'S':
    case 's': {
      charConsumed++;
      switch ( *(typeDefString + 1) ) {
        case '1':
          outType = kUVCTypeComponentTypeSInt8;
          charConsumed++;
          break;
        case '2':
          outType = kUVCTypeComponentTypeSInt16;
          charConsumed++;
          break;
        case '4':
          outType = kUVCTypeComponentTypeSInt32;
          charConsumed++;
          break;
        case '8':
          outType = kUVCTypeComponentTypeSInt64;
          charConsumed++;
          break;
      }
      break;
    }
  
    case 'U':
    case 'u': {
      charConsumed++;
      switch ( *(typeDefString + 1) ) {
        case '1':
          outType = kUVCTypeComponentTypeUInt8;
          charConsumed++;
          break;
        case '2':
          outType = kUVCTypeComponentTypeUInt16;
          charConsumed++;
          break;
        case '4':
          outType = kUVCTypeComponentTypeUInt32;
          charConsumed++;
          break;
        case '8':
          outType = kUVCTypeComponentTypeUInt64;
          charConsumed++;
          break;
      }
      break;
    }
  
  }
  if ( outType != kUVCTypeComponentTypeInvalid ) *nChar = charConsumed;
  return outType;
}

//

BOOL
__UVCTypeComponentTypeScanf(
  const char              *cString,
  UVCTypeComponentType   theType,
  void                    *theValue,
  UVCTypeScanFlags        flags,
  void                    *theMinimum,
  void                    *theMaximum,
  void                    *theStepSize,
  void                    *theDefaultValue,
  NSUInteger              *nChar
)
{
  BOOL                    rc = NO;
  BOOL                    isFractional = NO;
  const char              *p;
  
  //
  // Requesting default value?
  //
  if ( strncasecmp(cString, "default", 7) == 0 ) {
    if ( (flags & kUVCTypeScanFlagShowInfo) ) fprintf(stderr, "INFO: Default value requested\n");
    if ( ! theDefaultValue ) {
      if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Default value requested, none provided by control\n");
      return NO;
    }
    switch ( theType ) {
      case kUVCTypeComponentTypeSInt8: {
        SInt8             *def = (SInt8*)theDefaultValue;
        
        *((SInt8*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeBoolean:
      case kUVCTypeComponentTypeBitmap8:
      case kUVCTypeComponentTypeUInt8: {
        UInt8             *def = (UInt8*)theDefaultValue;
        
        *((UInt8*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeSInt16: {
        SInt16            *def = (SInt16*)theDefaultValue;
        
        *((SInt16*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeBitmap16:
      case kUVCTypeComponentTypeUInt16: {
        UInt16            *def = (UInt16*)theDefaultValue;
        
        *((UInt16*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeSInt32: {
        SInt32            *def = (SInt32*)theDefaultValue;
        
        *((SInt32*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeBitmap32:
      case kUVCTypeComponentTypeUInt32:  {
        UInt32            *def = (UInt32*)theDefaultValue;
        
        *((UInt32*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeSInt64: {
        SInt64            *def = (SInt64*)theDefaultValue;
        
        *((SInt64*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeBitmap64:
      case kUVCTypeComponentTypeUInt64:  {
        UInt64            *def = (UInt64*)theDefaultValue;
        
        *((UInt64*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeMax:
      case kUVCTypeComponentTypeInvalid:
        // Should never get here!
        break;
    }
    *nChar = strlen("default");
    return YES;
  }
  else if ( strncasecmp(cString, "minimum", 7) == 0 ) {
    if ( (flags & kUVCTypeScanFlagShowInfo) ) fprintf(stderr, "INFO: Minimum value requested\n");
    if ( ! theMinimum ) {
      if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Minimum value requested, none provided by control\n");
      return NO;
    }
    switch ( theType ) {
      case kUVCTypeComponentTypeSInt8: {
        SInt8             *def = (SInt8*)theMinimum;
        
        *((SInt8*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeBoolean:
      case kUVCTypeComponentTypeBitmap8:
      case kUVCTypeComponentTypeUInt8: {
        UInt8             *def = (UInt8*)theMinimum;
        
        *((UInt8*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeSInt16: {
        SInt16            *def = (SInt16*)theMinimum;
        
        *((SInt16*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeBitmap16:
      case kUVCTypeComponentTypeUInt16: {
        UInt16            *def = (UInt16*)theMinimum;
        
        *((UInt16*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeSInt32: {
        SInt32            *def = (SInt32*)theMinimum;
        
        *((SInt32*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeBitmap32:
      case kUVCTypeComponentTypeUInt32:  {
        UInt32            *def = (UInt32*)theMinimum;
        
        *((UInt32*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeSInt64: {
        SInt64            *def = (SInt64*)theMinimum;
        
        *((SInt64*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeBitmap64:
      case kUVCTypeComponentTypeUInt64:  {
        UInt64            *def = (UInt64*)theMinimum;
        
        *((UInt64*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeMax:
      case kUVCTypeComponentTypeInvalid:
        // Should never get here!
        break;
    }
    *nChar = strlen("minimum");
    return YES;
  }
  else if ( strncasecmp(cString, "maximum", 7) == 0 ) {
    if ( (flags & kUVCTypeScanFlagShowInfo) ) fprintf(stderr, "INFO: Maximum value requested\n");
    if ( ! theMaximum ) {
      if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Maximum value requested, none provided by control\n");
      return NO;
    }
    switch ( theType ) {
      case kUVCTypeComponentTypeSInt8: {
        SInt8             *def = (SInt8*)theMaximum;
        
        *((SInt8*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeBoolean:
      case kUVCTypeComponentTypeBitmap8:
      case kUVCTypeComponentTypeUInt8: {
        UInt8             *def = (UInt8*)theMaximum;
        
        *((UInt8*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeSInt16: {
        SInt16            *def = (SInt16*)theMaximum;
        
        *((SInt16*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeBitmap16:
      case kUVCTypeComponentTypeUInt16: {
        UInt16            *def = (UInt16*)theMaximum;
        
        *((UInt16*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeSInt32: {
        SInt32            *def = (SInt32*)theMaximum;
        
        *((SInt32*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeBitmap32:
      case kUVCTypeComponentTypeUInt32:  {
        UInt32            *def = (UInt32*)theMaximum;
        
        *((UInt32*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeSInt64: {
        SInt64            *def = (SInt64*)theMaximum;
        
        *((SInt64*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeBitmap64:
      case kUVCTypeComponentTypeUInt64:  {
        UInt64            *def = (UInt64*)theMaximum;
        
        *((UInt64*)theValue) = *def;
        break;
      }
      
      case kUVCTypeComponentTypeMax:
      case kUVCTypeComponentTypeInvalid:
        // Should never get here!
        break;
    }
    *nChar = strlen("maximum");
    return YES;
  }
  
  //
  // If boolean, then check for special string values:
  //
  if ( theType == kUVCTypeComponentTypeBoolean ) {
    const char*     trues[] = { "y", "yes", "true", "t", "1", NULL };
    const char*     falses[] = { "n", "no", "false", "f", "0", NULL };
    const char*     *test;
    
    test = trues;
    while ( *test ) {
      if ( strncasecmp(cString, *test, strlen(*test)) == 0 ) {
        *((UInt8*)theValue) = 1;
        *nChar = strlen(*test);
        return YES;
      }
      test++;
    }
    test = falses;
    while ( *test ) {
      if ( strncasecmp(cString, *test, strlen(*test)) == 0 ) {
        *((UInt8*)theValue) = 0;
        *nChar = strlen(*test);
        return YES;
      }
      test++;
    }
    if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Invalid boolean value at '%s'\n", cString);
  }
  
  //
  // Is it a floating-point value?
  //
  p = cString;
  while ( isspace(*p) ) p++;

  BOOL                    foundPlusMinus = NO;
  BOOL                    foundDot = NO;
  BOOL                    foundExponent = NO;
  NSUInteger              digitsBeforeDecimal = 0;
  NSUInteger              digitsAfterDecimal = 0;
  BOOL                    fpScanDone = NO;
  
  while ( ! fpScanDone && *p ) {
    switch ( *p ) {
      case '+':
      case '-': {
        if ( foundPlusMinus ) return NO;
        foundPlusMinus = YES;
        p++;
        break;
      }
      case '.': {
        if ( foundDot ) return NO;
        foundDot = YES;
        p++;
        break;
      }
      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9': {
        if ( foundDot ) {
          digitsAfterDecimal++;
        } else {
          digitsBeforeDecimal++;
        }
        p++;
        break;
      }
      
      case 'e':
      case 'E': {
        foundExponent = YES;
        fpScanDone = YES;
        p++;
        break;
      }
      
      default:
        fpScanDone = YES;
        break;
    }
  }
  
  // Was it floating point?
  if ( foundDot ) {
    if ( digitsAfterDecimal > 0 ) {
      isFractional = YES;
    }
  }
  if ( foundExponent ) {
    isFractional = YES;
  }
  
  // If fractional, then we need a range:
  if ( isFractional ) {
    if ( (flags & kUVCTypeScanFlagShowInfo) ) fprintf(stderr, "INFO: Floating-point value detected at '%s'\n", cString);
    if ( theMinimum && theMaximum ) {
      float     fractionalValue;
      int       n;
      
      if ( sscanf(cString, "%g%n", &fractionalValue, &n) == 1 ) {
        // Clamp the value:
        if ( fractionalValue < 0.0f ) fractionalValue = 0.0f;
        else if ( fractionalValue > 1.0f ) fractionalValue = 1.0f;
        
        // Map to range:
        switch ( theType ) {
        
          case kUVCTypeComponentTypeSInt8: {
            SInt8       *min = (SInt8*)theMinimum;
            SInt8       *max = (SInt8*)theMaximum;
            SInt8       *res = (SInt8*)theStepSize;
            SInt8       val = round(*min + fractionalValue * (*max - *min));
            
            // Fix to the appropriate resolution if applicable:
            if ( min && max && res && (*res > 1) ) {
              SInt8     residual = ((val - *min) % *res);

              if ( residual != 0 ) {
                if ( residual >= (*res / 2) ) {
                  val = val + (*res - residual);
                } else {
                  val = val - residual;
                }
              }
            }
            *((SInt8*)theValue) = val;
            break;
          }
          
          case kUVCTypeComponentTypeBoolean:
          case kUVCTypeComponentTypeUInt8: {
            UInt8       *min = (UInt8*)theMinimum;
            UInt8       *max = (UInt8*)theMaximum;
            UInt8       *res = (UInt8*)theStepSize;
            UInt8       val = round(*min + fractionalValue * (*max - *min));
            
            // Fix to the appropriate resolution if applicable:
            if ( min && max && res && (*res > 1) ) {
              UInt8     residual = ((val - *min) % *res);

              if ( residual != 0 ) {
                if ( residual >= (*res / 2) ) {
                  val = val + (*res - residual);
                } else {
                  val = val - residual;
                }
              }
            }
            *((UInt8*)theValue) = val;
            break;
          }
          
          case kUVCTypeComponentTypeBitmap8: {
            UInt8       *min = (UInt8*)theMinimum;
            UInt8       *max = (UInt8*)theMaximum;
            UInt8       *res = (UInt8*)theStepSize;
            UInt8       val = round(*min + fractionalValue * (*max - *min));
            
            // Mask to only the available bits:
            if ( res ) val &= *res;
            
            *((UInt8*)theValue) = val;
            break;
          }
          
          case kUVCTypeComponentTypeSInt16: {
            SInt16      *min = (SInt16*)theMinimum;
            SInt16      *max = (SInt16*)theMaximum;
            SInt16      *res = (SInt16*)theStepSize;
            SInt16      val = round(*min + fractionalValue * (*max - *min));
            
            // Fix to the appropriate resolution if applicable:
            if ( min && max && res && (*res > 1) ) {
              SInt16    residual = ((val - *min) % *res);

              if ( residual != 0 ) {
                if ( residual >= (*res / 2) ) {
                  val = val + (*res - residual);
                } else {
                  val = val - residual;
                }
              }
            }
            *((SInt16*)theValue) = val;
            break;
          }
          
          case kUVCTypeComponentTypeUInt16: {
            UInt16      *min = (UInt16*)theMinimum;
            UInt16      *max = (UInt16*)theMaximum;
            UInt16      *res = (UInt16*)theStepSize;
            UInt16      val = round(*min + fractionalValue * (*max - *min));
            
            // Fix to the appropriate resolution if applicable:
            if ( min && max && res && (*res > 1) ) {
              UInt16    residual = ((val - *min) % *res);

              if ( residual != 0 ) {
                if ( residual >= (*res / 2) ) {
                  val = val + (*res - residual);
                } else {
                  val = val - residual;
                }
              }
            }
            *((UInt16*)theValue) = val;
            break;
          }
          
          case kUVCTypeComponentTypeBitmap16: {
            UInt16      *min = (UInt16*)theMinimum;
            UInt16      *max = (UInt16*)theMaximum;
            UInt16      *res = (UInt16*)theStepSize;
            UInt16      val = round(*min + fractionalValue * (*max - *min));
            
            // Mask to only the available bits:
            if ( res ) val &= *res;
            
            *((UInt16*)theValue) = val;
            break;
          }
          
          case kUVCTypeComponentTypeSInt32: {
            SInt32      *min = (SInt32*)theMinimum;
            SInt32      *max = (SInt32*)theMaximum;
            SInt32      *res = (SInt32*)theStepSize;
            SInt32      val = round(*min + fractionalValue * (*max - *min));
            
            // Fix to the appropriate resolution if applicable:
            if ( min && max && res && (*res > 1) ) {
              SInt32    residual = ((val - *min) % *res);

              if ( residual != 0 ) {
                if ( residual >= (*res / 2) ) {
                  val = val + (*res - residual);
                } else {
                  val = val - residual;
                }
              }
            }
            *((SInt32*)theValue) = val;
            break;
          }
          
          case kUVCTypeComponentTypeUInt32: {
            UInt32      *min = (UInt32*)theMinimum;
            UInt32      *max = (UInt32*)theMaximum;
            UInt32      *res = (UInt32*)theStepSize;
            UInt32      val = round(*min + fractionalValue * (*max - *min));
            
            // Fix to the appropriate resolution if applicable:
            if ( min && max && res && (*res > 1) ) {
              UInt32    residual = ((val - *min) % *res);

              if ( residual != 0 ) {
                if ( residual >= (*res / 2) ) {
                  val = val + (*res - residual);
                } else {
                  val = val - residual;
                }
              }
            }
            *((UInt32*)theValue) = val;
            break;
          }
          
          case kUVCTypeComponentTypeBitmap32: {
            UInt32      *min = (UInt32*)theMinimum;
            UInt32      *max = (UInt32*)theMaximum;
            UInt32      *res = (UInt32*)theStepSize;
            UInt32      val = round(*min + fractionalValue * (*max - *min));
            
            // Mask to only the available bits:
            if ( res ) val &= *res;
            
            *((UInt32*)theValue) = val;
            break;
          }
          
          case kUVCTypeComponentTypeSInt64: {
            SInt64      *min = (SInt64*)theMinimum;
            SInt64      *max = (SInt64*)theMaximum;
            SInt64      *res = (SInt64*)theStepSize;
            SInt64      val = round(*min + fractionalValue * (*max - *min));
            
            // Fix to the appropriate resolution if applicable:
            if ( min && max && res && (*res > 1) ) {
              SInt64    residual = ((val - *min) % *res);

              if ( residual != 0 ) {
                if ( residual >= (*res / 2) ) {
                  val = val + (*res - residual);
                } else {
                  val = val - residual;
                }
              }
            }
            *((SInt64*)theValue) = val;
            break;
          }
          
          case kUVCTypeComponentTypeUInt64: {
            UInt64      *min = (UInt64*)theMinimum;
            UInt64      *max = (UInt64*)theMaximum;
            UInt64      *res = (UInt64*)theStepSize;
            UInt64      val = round(*min + fractionalValue * (*max - *min));
            
            // Fix to the appropriate resolution if applicable:
            if ( min && max && res && (*res > 1) ) {
              UInt64    residual = ((val - *min) % *res);

              if ( residual != 0 ) {
                if ( residual >= (*res / 2) ) {
                  val = val + (*res - residual);
                } else {
                  val = val - residual;
                }
              }
            }
            *((UInt64*)theValue) = val;
            break;
          }
          
          case kUVCTypeComponentTypeBitmap64: {
            UInt64      *min = (UInt64*)theMinimum;
            UInt64      *max = (UInt64*)theMaximum;
            UInt64      *res = (UInt64*)theStepSize;
            UInt64      val = round(*min + fractionalValue * (*max - *min));
            
            // Mask to only the available bits:
            if ( res ) val &= *res;
            
            *((UInt64*)theValue) = val;
            break;
          }
          
          case kUVCTypeComponentTypeMax:
          case kUVCTypeComponentTypeInvalid:
            // Should never get here!
            break;
          
        }
        *nChar = n;
        rc = YES;
      } else {
        if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Unable to scan floating-point value at '%s'\n", cString);
      }
    } else {
      if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: No value range provided by control, floating-point input not available\n");
    }
  } else {
    //
    // Integer values:
    //
    int           n = 0;
    
    if ( (flags & kUVCTypeScanFlagShowInfo) ) fprintf(stderr, "INFO: Defaulting to integer value at '%s'\n", cString);
    switch ( theType ) {
    
      case kUVCTypeComponentTypeSInt8: {
        SInt8       *min = (SInt8*)theMinimum;
        SInt8       *max = (SInt8*)theMaximum;
        SInt8       *res = (SInt8*)theStepSize;
        SInt16      val;
        
        if ( sscanf(cString, "%hi%n", &val, &n) == 1 ) {
          // Check against ranges:
          if ( min && (val < *min) ) val = *min;
          else if ( max && (val > *max) ) val = *max;
          
          // Fix to the appropriate resolution if applicable:
          if ( min && max && res && (*res > 1) ) {
            SInt16   residual = ((val - *min) % *res);

            if ( residual != 0 ) {
              if ( residual >= (*res / 2) ) {
                val = val + (*res - residual);
              } else {
                val = val - residual;
              }
            }
          }
          if ( val < CHAR_MIN ) val = CHAR_MIN;
          else if ( val > CHAR_MAX ) val = CHAR_MAX;
          *((SInt8*)theValue) = val;
          rc = true;
        } else {
          if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Unable to scan integer value at '%s'\n", cString);
        }
        break;
      }
      
      case kUVCTypeComponentTypeBoolean: {
        UInt8       val;
        
        if ( sscanf(cString, "%hhi%n", &val, &n) == 1 ) {
          *((UInt8*)theValue) = val ? 1 : 0;
          rc = true;
        } else {
          if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Unable to scan integer value at '%s'\n", cString);
        }
        break;
      }
      
      case kUVCTypeComponentTypeUInt8: {
        UInt8       *min = (UInt8*)theMinimum;
        UInt8       *max = (UInt8*)theMaximum;
        UInt8       *res = (UInt8*)theStepSize;
        UInt8       val;
        
        if ( sscanf(cString, "%hhu%n", &val, &n) == 1 ) {
          // Check against ranges:
          if ( min && (val < *min) ) val = *min;
          else if ( max && (val > *max) ) val = *max;
          
          // Fix to the appropriate resolution if applicable:
          if ( min && max && res && (*res > 1) ) {
            UInt8    residual = ((val - *min) % *res);

            if ( residual != 0 ) {
              if ( residual >= (*res / 2) ) {
                val = val + (*res - residual);
              } else {
                val = val - residual;
              }
            }
          }
          *((UInt8*)theValue) = val;
          rc = true;
        } else {
          if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Unable to scan integer value at '%s'\n", cString);
        }
        break;
      }
      
      case kUVCTypeComponentTypeBitmap8: {
        UInt8       *min = (UInt8*)theMinimum;
        UInt8       *max = (UInt8*)theMaximum;
        UInt8       *res = (UInt8*)theStepSize;
        UInt8       val;
        
        if ( sscanf(cString, "%hhu%n", &val, &n) == 1 ) {
          // Check against ranges:
          if ( min && (val < *min) ) val = *min;
          else if ( max && (val > *max) ) val = *max;
          
          // Mask to available bits only:
          if ( res ) val &= *res;
          
          *((UInt8*)theValue) = val;
          rc = true;
        } else {
          if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Unable to scan bitmap value at '%s'\n", cString);
        }
        break;
      }
      
      case kUVCTypeComponentTypeSInt16: {
        SInt16      *min = (SInt16*)theMinimum;
        SInt16      *max = (SInt16*)theMaximum;
        SInt16      *res = (SInt16*)theStepSize;
        SInt32      val;
        
        if ( sscanf(cString, "%i%n", &val, &n) == 1 ) {
          // Check against ranges:
          if ( min && (val < *min) ) val = *min;
          else if ( max && (val > *max) ) val = *max;
          
          // Fix to the appropriate resolution if applicable:
          if ( min && max && res && (*res > 1) ) {
            SInt32   residual = ((val - *min) % *res);

            if ( residual != 0 ) {
              if ( residual >= (*res / 2) ) {
                val = val + (*res - residual);
              } else {
                val = val - residual;
              }
            }
          }
          if ( val < SHRT_MIN ) val = SHRT_MIN;
          else if ( val > SHRT_MAX ) val = SHRT_MAX;
          *((SInt16*)theValue) = (SInt16)val;
          rc = true;
        } else {
          if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Unable to scan integer value at '%s'\n", cString);
        }
        break;
      }
      
      case kUVCTypeComponentTypeUInt16: {
        UInt16      *min = (UInt16*)theMinimum;
        UInt16      *max = (UInt16*)theMaximum;
        UInt16      *res = (UInt16*)theStepSize;
        UInt16      val;
        
        if ( sscanf(cString, "%hu%n", &val, &n) == 1 ) {
          // Check against ranges:
          if ( min && (val < *min) ) val = *min;
          else if ( max && (val > *max) ) val = *max;
          
          // Fix to the appropriate resolution if applicable:
          if ( min && max && res && (*res > 1) ) {
            UInt16   residual = ((val - *min) % *res);

            if ( residual != 0 ) {
              if ( residual >= (*res / 2) ) {
                val = val + (*res - residual);
              } else {
                val = val - residual;
              }
            }
          }
          *((UInt16*)theValue) = val;
          rc = true;
        } else {
          if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Unable to scan integer value at '%s'\n", cString);
        }
        break;
      }
      
      case kUVCTypeComponentTypeBitmap16: {
        UInt16      *min = (UInt16*)theMinimum;
        UInt16      *max = (UInt16*)theMaximum;
        UInt16      *res = (UInt16*)theStepSize;
        UInt16      val;
        
        if ( sscanf(cString, "%hu%n", &val, &n) == 1 ) {
          // Check against ranges:
          if ( min && (val < *min) ) val = *min;
          else if ( max && (val > *max) ) val = *max;
          
          // Mask to available bits only:
          if ( res ) val &= *res;
          
          *((UInt16*)theValue) = val;
          rc = true;
        } else {
          if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Unable to scan bitmap value at '%s'\n", cString);
        }
        break;
      }
      
      case kUVCTypeComponentTypeSInt32: {
        SInt32      *min = (SInt32*)theMinimum;
        SInt32      *max = (SInt32*)theMaximum;
        SInt32      *res = (SInt32*)theStepSize;
        SInt64      val;
        
        if ( sscanf(cString, "%lli%n", &val, &n) == 1 ) {
          // Check against ranges:
          if ( min && (val < *min) ) val = *min;
          else if ( max && (val > *max) ) val = *max;
          
          // Fix to the appropriate resolution if applicable:
          if ( min && max && res && (*res > 1) ) {
            SInt64   residual = ((val - *min) % *res);

            if ( residual != 0 ) {
              if ( residual >= (*res / 2) ) {
                val = val + (*res - residual);
              } else {
                val = val - residual;
              }
            }
          }
          if ( val < INT_MIN ) val = INT_MIN;
          else if ( val > INT_MAX ) val = INT_MAX;
          *((SInt32*)theValue) = (SInt32)val;
          rc = true;
        } else {
          if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Unable to scan integer value at '%s'\n", cString);
        }
        break;
      }
      
      case kUVCTypeComponentTypeUInt32: {
        UInt32      *min = (UInt32*)theMinimum;
        UInt32      *max = (UInt32*)theMaximum;
        UInt32      *res = (UInt32*)theStepSize;
        UInt32      val;
        
        if ( sscanf(cString, "%u%n", &val, &n) == 1 ) {
          // Check against ranges:
          if ( min && (val < *min) ) val = *min;
          else if ( max && (val > *max) ) val = *max;
          
          // Fix to the appropriate resolution if applicable:
          if ( min && max && res && (*res > 1) ) {
            UInt32   residual = ((val - *min) % *res);

            if ( residual != 0 ) {
              if ( residual >= (*res / 2) ) {
                val = val + (*res - residual);
              } else {
                val = val - residual;
              }
            }
          }
          *((UInt32*)theValue) = val;
          rc = true;
        } else {
          if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Unable to scan integer value at '%s'\n", cString);
        }
        break;
      }
      
      case kUVCTypeComponentTypeBitmap32: {
        UInt32      *min = (UInt32*)theMinimum;
        UInt32      *max = (UInt32*)theMaximum;
        UInt32      *res = (UInt32*)theStepSize;
        UInt32      val;
        
        if ( sscanf(cString, "%u%n", &val, &n) == 1 ) {
          // Check against ranges:
          if ( min && (val < *min) ) val = *min;
          else if ( max && (val > *max) ) val = *max;
          
          // Mask to available bits only:
          if ( res ) val &= *res;
          
          *((UInt32*)theValue) = val;
          rc = true;
        } else {
          if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Unable to scan bitmap value at '%s'\n", cString);
        }
        break;
      }
      
      case kUVCTypeComponentTypeSInt64: {
        SInt64      *min = (SInt64*)theMinimum;
        SInt64      *max = (SInt64*)theMaximum;
        SInt64      *res = (SInt64*)theStepSize;
        SInt64      val;
        
        if ( sscanf(cString, "%lli%n", &val, &n) == 1 ) {
          // Check against ranges:
          if ( min && (val < *min) ) val = *min;
          else if ( max && (val > *max) ) val = *max;
          
          // Fix to the appropriate resolution if applicable:
          if ( min && max && res && (*res > 1) ) {
            SInt64   residual = ((val - *min) % *res);

            if ( residual != 0 ) {
              if ( residual >= (*res / 2) ) {
                val = val + (*res - residual);
              } else {
                val = val - residual;
              }
            }
          }
          *((SInt64*)theValue) = val;
          rc = true;
        } else {
          if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Unable to scan integer value at '%s'\n", cString);
        }
        break;
      }
      
      case kUVCTypeComponentTypeUInt64: {
        UInt64      *min = (UInt64*)theMinimum;
        UInt64      *max = (UInt64*)theMaximum;
        UInt64      *res = (UInt64*)theStepSize;
        UInt64      val;
        
        if ( sscanf(cString, "%llu%n", &val, &n) == 1 ) {
          // Check against ranges:
          if ( min && (val < *min) ) val = *min;
          else if ( max && (val > *max) ) val = *max;
          
          // Fix to the appropriate resolution if applicable:
          if ( min && max && res && (*res > 1) ) {
            UInt64   residual = ((val - *min) % *res);

            if ( residual != 0 ) {
              if ( residual >= (*res / 2) ) {
                val = val + (*res - residual);
              } else {
                val = val - residual;
              }
            }
          }
          *((UInt64*)theValue) = val;
          rc = true;
        } else {
          if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Unable to scan integer value at '%s'\n", cString);
        }
        break;
      }
      
      case kUVCTypeComponentTypeBitmap64: {
        UInt64      *min = (UInt64*)theMinimum;
        UInt64      *max = (UInt64*)theMaximum;
        UInt64      *res = (UInt64*)theStepSize;
        UInt64      val;
        
        if ( sscanf(cString, "%llu%n", &val, &n) == 1 ) {
          // Check against ranges:
          if ( min && (val < *min) ) val = *min;
          else if ( max && (val > *max) ) val = *max;
          
          // Mask to available bits only:
          if ( res ) val &= *res;
          
          *((UInt64*)theValue) = val;
          rc = true;
        } else {
          if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Unable to scan bitmap value at '%s'\n", cString);
        }
        break;
      }
      
      case kUVCTypeComponentTypeMax:
      case kUVCTypeComponentTypeInvalid:
        // Should never get here!
        break;
      
    }
    if ( rc ) *nChar = n;
  }
  return rc;
}

//
#if 0
#pragma mark -
#endif
//

typedef struct {
  NSString                *fieldName;
  UVCTypeComponentType   fieldType;
} UVCTypeField;

//

@implementation UVCType

  + (UVCType*) uvcTypeWithCString:(const char*)typeDescription
  {
    const char          *originalStr = typeDescription;
    
    //
    // Format for type descriptions:
    //
    //    { [type1] [name1]; [type] [name2]; ... }
    
    // Drop any leading whitespace:
    while ( *typeDescription && isspace(*typeDescription) ) typeDescription++;
    
    // Starts with a brace?
    if ( *typeDescription != '{' ) {
      fprintf(stderr, "WARNING: No opening brace found: %s", originalStr);
      return nil;
    }
    typeDescription++;
    
    // Remember this as our starting point:
    const char          *startPtr = typeDescription;
    NSUInteger          fieldCount = 0;
    
    // Determine how many fields are defined:
    while ( *typeDescription ) {
      NSUInteger              nChar = 0;
      UVCTypeComponentType   nextType = __UVCTypeComponentTypeFromString(typeDescription, &nChar);
      
      if ( nextType == kUVCTypeComponentTypeInvalid ) {
        fprintf(stderr, "WARNING: Invalid type string at %ld in: %s", (typeDescription - originalStr), originalStr);
        return nil;
      }
      typeDescription += nChar;
      
      // Discard whitespace:
      while ( isspace(*typeDescription) ) typeDescription++;
      if ( ! *typeDescription ) {
        fprintf(stderr, "WARNING: Early end to type string at %ld in: %s", (typeDescription - originalStr), originalStr);
        return nil;
      }
      
      // Check for a valid name:
      while ( isalnum(*typeDescription) || (*typeDescription == '-') ) typeDescription++;
      if ( ! *typeDescription ) {
        fprintf(stderr, "WARNING: Early end to type string at %ld in: %s", (typeDescription - originalStr), originalStr);
        return nil;
      }
      
      // That's a valid field:
      fieldCount++;
      
      // Discard whitespace and semi-colon:
      while ( isspace(*typeDescription) || (*typeDescription == ';') ) typeDescription++;
      
      // If we've found a closing brace, we're done:
      if ( *typeDescription == '}' ) break;
    }
    
    if ( fieldCount ) {
      // Locally-allocate the name and type arrays:
      NSString              *fieldNames[fieldCount];
      UVCTypeComponentType fieldTypes[fieldCount];
      NSUInteger            fieldIdx = 0;
      
      // Return to the start of the string:
      typeDescription = startPtr;
      
      // Parse the field definitions into the arrays:
      while ( *typeDescription && (fieldIdx < fieldCount) ) {
        NSUInteger              nChar = 0;
        UVCTypeComponentType   nextType = __UVCTypeComponentTypeFromString(typeDescription, &nChar);
        
        typeDescription += nChar;
        fieldTypes[fieldIdx] = nextType;
        
        // Discard whitespace:
        while ( isspace(*typeDescription) ) typeDescription++;
        if ( ! *typeDescription ) return nil;
        
        // Isolate the name:
        startPtr = typeDescription;
        while ( isalnum(*typeDescription) || (*typeDescription == '-') ) typeDescription++;
        if ( typeDescription >= startPtr ) {
          long int      i = 0, iMax = typeDescription - startPtr;
          char          nameString[iMax + 1];
          
          while ( i < iMax ) {
            nameString[i] = tolower(startPtr[i]);
            i++;
          }
          nameString[iMax] = '\0';
          fieldNames[fieldIdx] = [NSString stringWithCString:nameString encoding:NSASCIIStringEncoding];
          
          // Ensure that no other fields have used this name:
          NSUInteger      altFieldIdx = 0;
          
          while ( altFieldIdx < fieldIdx ) {
            if ( [fieldNames[altFieldIdx++] compare:fieldNames[fieldIdx]] == NSOrderedSame ) {
              fprintf(stderr, "WARNING: Repeated use of type name at index %ld in '%s'\n", (typeDescription - originalStr), originalStr);
              return nil;
            }
          }
        }
        
        // That's a valid field:
        fieldIdx++;
        
        // Discard whitespace and semi-colon:
        while ( isspace(*typeDescription) || (*typeDescription == ';') ) typeDescription++;
        
        // If we've found a closing brace, we're done:
        if ( *typeDescription == '}' ) break;
      }
      return [self uvcTypeWithFieldCount:fieldCount names:fieldNames types:fieldTypes];
    }
    return nil;
  }

//

  + (UVCType*) uvcTypeWithFieldNamesAndTypes:(NSString*)name,...
  {
    NSUInteger      fieldCount = 0;
    va_list         vargs;
    
    if ( name ) {
      NSString                *nextName = name;
      UVCTypeComponentType   nextType = kUVCTypeComponentTypeInvalid;
      
      va_start(vargs, name);
      while ( (nextType = va_arg(vargs, UVCTypeComponentType)) ) {
        if ( nextType >= kUVCTypeComponentTypeMax ) break;
        fieldCount++;
        
        if ( (nextName = va_arg(vargs, NSString*)) == nil ) break;
      }
      va_end(vargs);
      
      if ( fieldCount ) {
        UVCType*      newType = class_createInstance(self, fieldCount * sizeof(UVCTypeField));
        
        if ( newType && (newType = [newType init]) ) {
          newType->_fieldCount = fieldCount;
          if ( (newType->_fields = object_getIndexedIvars(newType)) > 0 ) {
            UVCTypeField    *FIELD_PTR = (UVCTypeField*)newType->_fields;
            NSUInteger      i = 0;
            BOOL            needsNoByteSwap = YES;
            
            nextName = name;
            va_start(vargs, name);
            while ( i < fieldCount ) {
              FIELD_PTR->fieldName = [name copy];
              FIELD_PTR->fieldType = va_arg(vargs, UVCTypeComponentType);
              if ( UVCTypeComponentByteSize(FIELD_PTR->fieldType) != 1 ) needsNoByteSwap = NO;
              i++; FIELD_PTR++;
              
              name = va_arg(vargs, NSString*);
            }
            va_end(vargs);
            newType->_needsNoByteSwap = needsNoByteSwap || (NSHostByteOrder() == NS_LittleEndian);
            
            [newType autorelease];
          }
        }
        return newType;
      }
    }
    return nil;
  }

//

  + (UVCType*) uvcTypeWithFieldCount:(NSUInteger)count
    names:(NSString**)names
    types:(UVCTypeComponentType*)types
  {
    NSUInteger      i = 0;
    
    while ( i < count ) {
      if ( ! names[i] || (types[i] >= kUVCTypeComponentTypeMax) ) break;
      i++;
    }
    if ( i == count ) {
      UVCType*      newType = class_createInstance(self, count * sizeof(UVCTypeField));
      
      if ( newType && (newType = [newType init]) ) {
        newType->_fieldCount = count;
        if ( (newType->_fields = object_getIndexedIvars(newType)) > 0 ) {
          UVCTypeField    *FIELD_PTR = (UVCTypeField*)newType->_fields;
          BOOL            needsNoByteSwap = YES;
          
          i = 0;
          while ( i < count ) {
            FIELD_PTR->fieldName = [names[i] copy];
            FIELD_PTR->fieldType = types[i];
            if ( UVCTypeComponentByteSize(types[i]) != 1 ) needsNoByteSwap = NO;
            i++; FIELD_PTR++;
          }
          newType->_needsNoByteSwap = needsNoByteSwap || (NSHostByteOrder() == NS_LittleEndian);
            
          [newType autorelease];
        }
      }
      return newType; 
    }
    return nil;
  }
  
//

  - (void) dealloc
  {
    // Drop our field names:
    UVCTypeField    *FIELD_PTR = (UVCTypeField*)_fields;
    UVCTypeField    *FIELD_MAX = FIELD_PTR + _fieldCount;
    
    while ( FIELD_PTR < FIELD_MAX ) {
      [FIELD_PTR->fieldName release];
      FIELD_PTR++;
    }
    [super dealloc];
  }

//

  - (NSString*) description
  {
    NSMutableString   *asString = [[NSMutableString alloc] initWithFormat:@"UVCType@%p { field-count: %lu; byte-size: %lu; needs-byte-swap: %s; fields: {", self, (unsigned long)_fieldCount, [self byteSize], _needsNoByteSwap ? "no" : "yes" ];
    
    UVCTypeField      *FIELD_PTR = (UVCTypeField*)_fields;
    UVCTypeField      *FIELD_MAX = FIELD_PTR + _fieldCount;
    
    while ( FIELD_PTR < FIELD_MAX ) {
      [asString appendFormat:@" %s %@;", __UVCTypeComponentTypeString(FIELD_PTR->fieldType), FIELD_PTR->fieldName];
      FIELD_PTR++;
    }
    [asString appendString:@" } }"];
    
    NSString          *outString = [[asString copy] autorelease];
    [asString release];
    
    return outString;
  }

//

  - (BOOL) isEqual:(id)otherObject
  {
    if ( otherObject == self ) return YES;
    
    if ( [otherObject isKindOfClass:[self class]] ) {
      UVCType     *otherType = (UVCType*)otherObject;
      
      if ( ([self fieldCount] == [otherType fieldCount]) && ([self byteSize] == [otherType byteSize]) ) {
        UVCTypeField      *MY_FIELD_PTR = (UVCTypeField*)_fields;
        UVCTypeField      *THEIR_FIELD_PTR = (UVCTypeField*)otherType->_fields;
        UVCTypeField      *MY_FIELD_MAX = MY_FIELD_PTR + _fieldCount;
        
        while ( MY_FIELD_PTR < MY_FIELD_MAX ) {
          if ( MY_FIELD_PTR->fieldType != THEIR_FIELD_PTR->fieldType ) return NO;
          MY_FIELD_PTR++; THEIR_FIELD_PTR++;
        }
        return YES;
      }
    }
    return NO;
  }

//

  - (NSUInteger) fieldCount
  {
    return _fieldCount;
  }

//

  - (NSString*) fieldNameAtIndex:(NSUInteger)index
  {
    if ( index > _fieldCount ) return NULL;
    
    return ((UVCTypeField*)_fields)[index].fieldName;
  }

//

  - (UVCTypeComponentType) fieldTypeAtIndex:(NSUInteger)index
  {
    if ( index > _fieldCount ) return kUVCTypeComponentTypeInvalid;
    
    return ((UVCTypeField*)_fields)[index].fieldType;
  }

//

  - (NSUInteger) indexOfFieldWithName:(NSString*)fieldName
  {
    UVCTypeField    *FIELD_PTR = (UVCTypeField*)_fields;
    UVCTypeField    *FIELD_MAX = FIELD_PTR + _fieldCount;
    NSUInteger      fieldIdx = 0;
    
    while ( FIELD_PTR < FIELD_MAX ) {
      if ( [FIELD_PTR->fieldName caseInsensitiveCompare:fieldName] == NSOrderedSame ) return fieldIdx;
      FIELD_PTR++;
      fieldIdx++;
    }
    return UVCTypeInvalidIndex;
  }

//

  - (UVCTypeComponentType) typeWithName:(NSString*)fieldName
  {
    UVCTypeField    *FIELD_PTR = (UVCTypeField*)_fields;
    UVCTypeField    *FIELD_MAX = FIELD_PTR + _fieldCount;
    
    while ( FIELD_PTR < FIELD_MAX ) {
      if ( [FIELD_PTR->fieldName caseInsensitiveCompare:fieldName] == NSOrderedSame ) return FIELD_PTR->fieldType;
      FIELD_PTR++;
    }
    return kUVCTypeComponentTypeInvalid;
  }

//

  - (NSUInteger) byteSize
  {
    UVCTypeField    *FIELD_PTR = (UVCTypeField*)_fields;
    UVCTypeField    *FIELD_MAX = FIELD_PTR + _fieldCount;
    NSUInteger      byteSize = 0;
    
    while ( FIELD_PTR < FIELD_MAX ) {
      byteSize += UVCTypeComponentByteSize(FIELD_PTR->fieldType);
      FIELD_PTR++;
    }
    return byteSize;
  }
  
//

  - (NSUInteger) offsetToFieldAtIndex:(NSUInteger)index
  {
    NSUInteger      byteOffset = 0;
    
    if ( index > _fieldCount ) {
      byteOffset = UVCTypeInvalidIndex;
    } else {
      UVCTypeField    *FIELD_PTR = (UVCTypeField*)_fields;
      
      while ( index-- ) {
        byteOffset += UVCTypeComponentByteSize(FIELD_PTR->fieldType);
        FIELD_PTR++;
      }
    }
    return byteOffset;
  }
  
//

  - (NSUInteger) offsetToFieldWithName:(NSString*)fieldName
  {
    NSUInteger      byteOffset = 0;
    UVCTypeField    *FIELD_PTR = (UVCTypeField*)_fields;
    UVCTypeField    *FIELD_MAX = FIELD_PTR + _fieldCount;
    
    while ( FIELD_PTR < FIELD_MAX ) {
      if ( [FIELD_PTR->fieldName caseInsensitiveCompare:fieldName] == NSOrderedSame ) break;
      byteOffset += UVCTypeComponentByteSize(FIELD_PTR->fieldType);
      FIELD_PTR++;
    }
    if ( FIELD_PTR == FIELD_MAX ) byteOffset = UVCTypeInvalidIndex;
    return byteOffset;
  }

//

  - (void) byteSwapHostToUSBEndian:(void*)buffer
  {
    if ( _needsNoByteSwap ) return;
  
    UVCTypeField    *FIELD_PTR = (UVCTypeField*)_fields;
    UVCTypeField    *FIELD_MAX = FIELD_PTR + _fieldCount;
    
    while ( FIELD_PTR < FIELD_MAX ) {
      switch ( FIELD_PTR->fieldType ) {
        case kUVCTypeComponentTypeBoolean:
        case kUVCTypeComponentTypeBitmap8:
        case kUVCTypeComponentTypeSInt8:
        case kUVCTypeComponentTypeUInt8:
          buffer++;
          break;
        case kUVCTypeComponentTypeSInt16:
        case kUVCTypeComponentTypeUInt16:
        case kUVCTypeComponentTypeBitmap16: {
          UInt16   *asInt16Ptr = (UInt16*)buffer;
          
          *asInt16Ptr = NSSwapHostShortToLittle(*asInt16Ptr);
          buffer += 2;
          break;
        }
        case kUVCTypeComponentTypeSInt32:
        case kUVCTypeComponentTypeUInt32:
        case kUVCTypeComponentTypeBitmap32: {
          UInt32   *asInt32Ptr = (UInt32*)buffer;
          
          *asInt32Ptr = NSSwapHostIntToLittle(*asInt32Ptr);
          buffer += 4;
          break;
        }
        case kUVCTypeComponentTypeSInt64:
        case kUVCTypeComponentTypeUInt64:
        case kUVCTypeComponentTypeBitmap64: {
          UInt64   *asInt64Ptr = (UInt64*)buffer;
          
          *asInt64Ptr = NSSwapHostLongLongToLittle(*asInt64Ptr);
          buffer += 8;
          break;
        }
        case kUVCTypeComponentTypeMax:
        case kUVCTypeComponentTypeInvalid:
          // Should never get here!
          break;
      }
      FIELD_PTR++;
    }
  }

//

  - (void) byteSwapUSBToHostEndian:(void*)buffer
  {
    if ( _needsNoByteSwap ) return;
    
    UVCTypeField    *FIELD_PTR = (UVCTypeField*)_fields;
    UVCTypeField    *FIELD_MAX = FIELD_PTR + _fieldCount;
    
    while ( FIELD_PTR < FIELD_MAX ) {
      switch ( FIELD_PTR->fieldType ) {
        case kUVCTypeComponentTypeBoolean:
        case kUVCTypeComponentTypeBitmap8:
        case kUVCTypeComponentTypeSInt8:
        case kUVCTypeComponentTypeUInt8:
          buffer++;
          break;
        case kUVCTypeComponentTypeSInt16:
        case kUVCTypeComponentTypeUInt16:
        case kUVCTypeComponentTypeBitmap16: {
          UInt16   *asInt16Ptr = (UInt16*)buffer;
          
          *asInt16Ptr = NSSwapLittleShortToHost(*asInt16Ptr);
          buffer += 2;
          break;
        }
        case kUVCTypeComponentTypeSInt32:
        case kUVCTypeComponentTypeUInt32:
        case kUVCTypeComponentTypeBitmap32: {
          UInt32   *asInt32Ptr = (UInt32*)buffer;
          
          *asInt32Ptr = NSSwapLittleIntToHost(*asInt32Ptr);
          buffer += 4;
          break;
        }
        case kUVCTypeComponentTypeSInt64:
        case kUVCTypeComponentTypeUInt64:
        case kUVCTypeComponentTypeBitmap64: {
          UInt64   *asInt64Ptr = (UInt64*)buffer;
          
          *asInt64Ptr = NSSwapLittleLongLongToHost(*asInt64Ptr);
          buffer += 8;
          break;
        }
        case kUVCTypeComponentTypeMax:
        case kUVCTypeComponentTypeInvalid:
          // Should never get here!
          break;
      }
      FIELD_PTR++;
    }
  }
  
//

  - (BOOL) scanCString:(const char*)cString
    intoBuffer:(void*)buffer
    flags:(UVCTypeScanFlags)flags
  {
    return [self scanCString:cString intoBuffer:buffer flags:flags minimum:nil maximum:nil stepSize:nil defaultValue:nil];
  }

//

  - (BOOL) scanCString:(const char*)cString
    intoBuffer:(void*)buffer
    flags:(UVCTypeScanFlags)flags
    minimum:(void*)minimum
    maximum:(void*)maximum
  {
    return [self scanCString:cString intoBuffer:buffer flags:flags minimum:minimum maximum:maximum stepSize:nil defaultValue:nil];
  }

//

  - (BOOL) scanCString:(const char*)cString
    intoBuffer:(void*)buffer
    flags:(UVCTypeScanFlags)flags
    minimum:(void*)minimum
    maximum:(void*)maximum
    stepSize:(void*)stepSize
  {
    return [self scanCString:cString intoBuffer:buffer flags:flags minimum:minimum maximum:maximum stepSize:nil defaultValue:nil];
  }

//

  - (BOOL) scanCString:(const char*)cString
    intoBuffer:(void*)buffer
    flags:(UVCTypeScanFlags)flags
    minimum:(void*)minimum
    maximum:(void*)maximum
    stepSize:(void*)stepSize
    defaultValue:(void*)defaultValue
  {
    UVCTypeField    *FIELD_PTR = (UVCTypeField*)_fields;
    BOOL            rc = NO;
    NSUInteger      nChar;
    
    //
    // We at least need to drop leading whitespace:
    //
    while ( isspace(*cString) ) cString++;
    
    //
    // If the string doesn't lead with a brace...
    //
    if ( *cString != '{' ) {
      //
      // If it's "default" then set the WHOLE THING to the default:
      //
      if ( strncasecmp(cString, "default", 7) == 0 ) {
        if ( defaultValue ) {
          if ( (flags & kUVCTypeScanFlagShowInfo) ) fprintf(stderr, "INFO: Copying default value provided by this control\n");
          memcpy(buffer, defaultValue, [self byteSize]);
          rc = YES;
        } else {
          if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: No default value provided by this control\n");
        }
      }
      //
      // If it's "minimum" then set the WHOLE THING to the minimum:
      //
      if ( strncasecmp(cString, "minimum", 7) == 0 ) {
        if ( minimum ) {
          if ( (flags & kUVCTypeScanFlagShowInfo) ) fprintf(stderr, "INFO: Copying minimum value provided by this control\n");
          memcpy(buffer, minimum, [self byteSize]);
          rc = YES;
        } else {
          if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: No minimum value provided by this control\n");
        }
      }
      //
      // If it's "maximum" then set the WHOLE THING to the maximum:
      //
      if ( strncasecmp(cString, "maximum", 7) == 0 ) {
        if ( maximum ) {
          if ( (flags & kUVCTypeScanFlagShowInfo) ) fprintf(stderr, "INFO: Copying maximum value provided by this control\n");
          memcpy(buffer, maximum, [self byteSize]);
          rc = YES;
        } else {
          if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: No maximum value provided by this control\n");
        }
      }
      if ( _fieldCount == 1 ) {
        //
        // ...we have a single field, so try just scanning its value:
        //
        rc = __UVCTypeComponentTypeScanf(
                    cString,
                    FIELD_PTR->fieldType,
                    buffer,
                    flags,
                    minimum,
                    maximum,
                    stepSize,
                    defaultValue,
                    &nChar
                  );
      }
    } else {
      BOOL                  usesNamedValues = strchr(cString, '=') ? YES : NO;
      NSUInteger            fieldIdx = 0;
      CFMutableBitVectorRef fieldsUsed = usesNamedValues ? CFBitVectorCreateMutable(kCFAllocatorDefault, _fieldCount) : NULL;
      
      if ( (flags & kUVCTypeScanFlagShowInfo) ) fprintf(stderr, "INFO: Using %s field assignments\n", (usesNamedValues ? "named-value" : "in-order"));
      
      // Skip-over the brace:
      cString++;
      while ( *cString && (fieldIdx < _fieldCount) ) {
        NSString    *fieldName = nil;
        NSUInteger  fieldOffset;
        
        if ( (flags & kUVCTypeScanFlagShowInfo) ) fprintf(stderr, "INFO: Processing substring '%s'\n", cString);
        
        //
        // When doing named values, read the field name first:
        //
        if ( usesNamedValues ) {
          // Drop leading whitespace:
          while ( isspace(*cString) ) cString++;
          
          // Isolate the name:
          const char      *namePtr = cString;
          while ( *cString && (*cString != '=') ) cString++;
          if ( 1 ) {
            NSUInteger    i = 0, iMax = cString - namePtr;
            char          nameStr[iMax + 1];
            
            while ( i < iMax ) {
              nameStr[i] = tolower(namePtr[i]);
              i++;
            }
            nameStr[i] = '\0';
            fieldName = [[NSString alloc] initWithCString:nameStr encoding:NSASCIIStringEncoding];
            
            if ( *cString == '=' ) cString++;
            fieldIdx = [self indexOfFieldWithName:fieldName];
            [fieldName release];
            if ( fieldIdx == UVCTypeInvalidIndex ) {
              CFRelease(fieldsUsed);
              if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: Field name '%s' not defined for this type\n", nameStr);
              return NO;
            }
          }
        }
          
        fieldOffset = [self offsetToFieldAtIndex:fieldIdx];
        
        void        *valuePtr = buffer + fieldOffset;
        void        *minimumPtr = minimum ? minimum + fieldOffset : NULL;
        void        *maximumPtr = maximum ? maximum + fieldOffset : NULL;
        void        *stepSizePtr = stepSize ? stepSize + fieldOffset : NULL;
        void        *defaultValuePtr = defaultValue ? defaultValue + fieldOffset : NULL;
        
        // Scan a value:
        BOOL        scanned = __UVCTypeComponentTypeScanf(
                                    cString,
                                    FIELD_PTR[fieldIdx].fieldType,
                                    valuePtr,
                                    flags,
                                    minimumPtr,
                                    maximumPtr,
                                    stepSizePtr,
                                    defaultValuePtr,
                                    &nChar
                                  );
        if ( ! scanned ) break;
        
        // Skip trailing whitespace/commas:
        cString += nChar;
        while ( isspace(*cString) || (*cString == ',') ) cString++;
        
        // If not doing named values, increase the field index; for named-values,
        // make note of the fact that we set the value at this index:
        if ( ! usesNamedValues ) {
          fieldIdx++;
        } else {
          CFBitVectorSetBits(fieldsUsed, CFRangeMake(fieldIdx, 1), 1);
        }
        
        // If the closing brace, then exit:
        if ( *cString == '}' ) break;
      }
      if ( fieldsUsed ) {
        if ( CFBitVectorContainsBit(fieldsUsed, CFRangeMake(0, _fieldCount), 0) ) {
          CFIndex     zeroCount = CFBitVectorGetCountOfBit(fieldsUsed, CFRangeMake(0, _fieldCount), 0);
          
          if ( (flags & kUVCTypeScanFlagShowWarnings) ) fprintf(stderr, "WARNING: %ld named field%s %s not provided\n", zeroCount, ((zeroCount == 1) ? "" : "s"), ((zeroCount == 1) ? "was" : "were"));
        } else {
          rc = YES;
        }
        CFRelease(fieldsUsed);
      } else if ( fieldIdx >= _fieldCount ) {
        rc = YES;
      }
    }
    if ( (flags & kUVCTypeScanFlagShowInfo) && rc ) fprintf(stderr, "INFO: Successfully scanned all fields for this type\n");
    return rc;
  }

//

  - (NSString*) stringFromBuffer:(void*)buffer
  {
    UVCTypeField    *FIELD_PTR = (UVCTypeField*)_fields;
    UVCTypeField    *FIELD_MAX = FIELD_PTR + _fieldCount;
    
    if ( _fieldCount == 1 ) {
      switch ( FIELD_PTR->fieldType ) {
        case kUVCTypeComponentTypeBoolean: {
          return *((UInt8*)buffer) ? @"true" : @"false";
        }
        case kUVCTypeComponentTypeSInt8: {
          return [NSString stringWithFormat:@"%hhd", *((SInt8*)buffer)];
        }
        case kUVCTypeComponentTypeUInt8:
        case kUVCTypeComponentTypeBitmap8: {
          return [NSString stringWithFormat:@"%hhu", *((UInt8*)buffer)];
        }
        case kUVCTypeComponentTypeSInt16: {
          return [NSString stringWithFormat:@"%hd", *((SInt16*)buffer)];
        }
        case kUVCTypeComponentTypeUInt16:
        case kUVCTypeComponentTypeBitmap16: {
          return [NSString stringWithFormat:@"%hu", *((UInt16*)buffer)];
        }
        case kUVCTypeComponentTypeSInt32: {
          return [NSString stringWithFormat:@"%d", *((SInt32*)buffer)];
        }
        case kUVCTypeComponentTypeUInt32:
        case kUVCTypeComponentTypeBitmap32: {
          return [NSString stringWithFormat:@"%u", *((UInt32*)buffer)];
        }
        case kUVCTypeComponentTypeSInt64: {
          return [NSString stringWithFormat:@"%lld", *((SInt64*)buffer)];
        }
        case kUVCTypeComponentTypeUInt64:
        case kUVCTypeComponentTypeBitmap64: {
          return [NSString stringWithFormat:@"%llu", *((UInt64*)buffer)];
        }
        case kUVCTypeComponentTypeMax:
        case kUVCTypeComponentTypeInvalid:
          // Should never get here!
          return nil;
      }
    }
    
    NSMutableString *asString = [[NSMutableString alloc] initWithString:@"{"];
    BOOL            shouldIncludeComma = NO;
    
    while ( FIELD_PTR < FIELD_MAX ) {
      switch ( FIELD_PTR->fieldType ) {
        case kUVCTypeComponentTypeBoolean: {
          [asString appendFormat:@"%s%@=%s", shouldIncludeComma ? "," : "", FIELD_PTR->fieldName, *((UInt8*)buffer) ? "true" : "false"];
          shouldIncludeComma = YES;
          buffer++;
          break;
        }     
        case kUVCTypeComponentTypeSInt8: {
          [asString appendFormat:@"%s%@=%hhd", shouldIncludeComma ? "," : "", FIELD_PTR->fieldName, *((SInt8*)buffer)];
          shouldIncludeComma = YES;
          buffer++;
          break;
        }
        case kUVCTypeComponentTypeUInt8:
        case kUVCTypeComponentTypeBitmap8: {
          [asString appendFormat:@"%s%@=%hhu", shouldIncludeComma ? "," : "", FIELD_PTR->fieldName, *((UInt8*)buffer)];
          shouldIncludeComma = YES;
          buffer++;
          break;
        }
        case kUVCTypeComponentTypeSInt16: {
          [asString appendFormat:@"%s%@=%hd", shouldIncludeComma ? "," : "", FIELD_PTR->fieldName, *((SInt16*)buffer)];
          shouldIncludeComma = YES;
          buffer += 2;
          break;
        }
        case kUVCTypeComponentTypeUInt16:
        case kUVCTypeComponentTypeBitmap16: {
          [asString appendFormat:@"%s%@=%hu", shouldIncludeComma ? "," : "", FIELD_PTR->fieldName, *((UInt16*)buffer)];
          shouldIncludeComma = YES;
          buffer += 2;
          break;
        }
        case kUVCTypeComponentTypeSInt32: {
          [asString appendFormat:@"%s%@=%d", shouldIncludeComma ? "," : "", FIELD_PTR->fieldName, *((SInt32*)buffer)];
          shouldIncludeComma = YES;
          buffer += 4;
          break;
        }
        case kUVCTypeComponentTypeUInt32:
        case kUVCTypeComponentTypeBitmap32: {
          [asString appendFormat:@"%s%@=%u", shouldIncludeComma ? "," : "", FIELD_PTR->fieldName, *((UInt32*)buffer)];
          shouldIncludeComma = YES;
          buffer += 4;
          break;
        }
        case kUVCTypeComponentTypeSInt64: {
          [asString appendFormat:@"%s%@=%lld", shouldIncludeComma ? "," : "", FIELD_PTR->fieldName, *((SInt64*)buffer)];
          shouldIncludeComma = YES;
          buffer += 8;
          break;
        }
        case kUVCTypeComponentTypeUInt64:
        case kUVCTypeComponentTypeBitmap64: {
          [asString appendFormat:@"%s%@=%llu", shouldIncludeComma ? "," : "", FIELD_PTR->fieldName, *((UInt64*)buffer)];
          shouldIncludeComma = YES;
          buffer += 8;
          break;
        }
        case kUVCTypeComponentTypeMax:
        case kUVCTypeComponentTypeInvalid:
          // Should never get here!
          break;
      }
      FIELD_PTR++;
    }
    [asString appendString:@"}"];
    
    NSString      *outString = [[asString copy] autorelease];
    [asString release];
    
    return outString;
  }

//

  - (NSString*) typeSummaryString
  {
    NSString        *outString = nil;
    UVCTypeField    *FIELD_PTR = (UVCTypeField*)_fields;
    UVCTypeField    *FIELD_MAX = FIELD_PTR + _fieldCount;
    
    if ( _fieldCount == 1 ) {
      outString = [NSString stringWithFormat:@"    single value, %s\n", __UVCTypeComponentVerboseTypeString(FIELD_PTR->fieldType)];
    } else {
      NSMutableString *asString = [[NSMutableString alloc] init];
      
      while ( FIELD_PTR < FIELD_MAX ) {
        [asString appendFormat:@"    %-32s %@;\n", __UVCTypeComponentVerboseTypeString(FIELD_PTR->fieldType), FIELD_PTR->fieldName];
        FIELD_PTR++;
      }
      outString = [[asString copy] autorelease];
      [asString release];
    }
    return outString;
  }

@end
