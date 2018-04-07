/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDefines.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/10/17 1:04 PM
 *  VISIBILITY: Private
 * DESCRIPTION:
 *
 * Copyright © 2017 Galen Rhodes All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#ifndef __Rubicon_PGDefines_H_
#define __Rubicon_PGDefines_H_

#import <Rubicon/GNUstep.h>

typedef long long NSLong;
typedef uint8_t   NSByte;
typedef NSByte    *NSBytePtr;
typedef void      *NSVoidPtr;

#if defined(CGFLOAT_IS_DOUBLE) && CGFLOAT_IS_DOUBLE
typedef CGFloat NSFloat;  // For the Sheldon Cooper in me.
#else
typedef double NSFloat;
#endif

static const NSUInteger NSUNotFound = NSUIntegerMax;

#if defined(__APPLE__)
    #define PGMaxSemaphoreNameLength 30
#else
    #define PGMaxSemaphoreNameLength 251
#endif

FOUNDATION_EXPORT NSString *const PGErrorDomain;

FOUNDATION_EXPORT NSExceptionName const PGTimedWorkerException;
FOUNDATION_EXPORT NSExceptionName const PGSemaphoreException;
FOUNDATION_EXPORT NSExceptionName const PGReadWriteLockException;
FOUNDATION_EXPORT NSExceptionName const PGOSErrorException;

FOUNDATION_EXPORT NSString *const PGDefaultSemaphoreNamePrefix;

#if !defined(PGAbstractClassError)
    #define PGAbstractClassError do {\
        NSString *reason = PGFormat(@"Instances of abstract class %@ cannot be created.", NSStringFromClass([self class]));\
        @throw [NSException exceptionWithName:NSIllegalSelectorException reason:reason userInfo:nil];\
        __builtin_unreachable();\
    } while(0)
#endif

#if !defined(PGBadConstructorError)
    #define PGBadConstructorError do {\
        NSString *reason = PGFormat(@"The selector \"%@\" cannot be used to create instances of the class %@.", NSStringFromSelector(_cmd), NSStringFromClass([self class]));\
        @throw [NSException exceptionWithName:NSIllegalSelectorException reason:reason userInfo:nil];\
        __builtin_unreachable();\
    } while(0)
#endif

#if !defined(PGNotImplemented)
    #define PGNotImplemented do {\
        NSString *reason = PGFormat(@"The selector \"%@\" is abstract.", NSStringFromSelector(_cmd));\
        @throw [NSException exceptionWithName:NSIllegalSelectorException reason:reason userInfo:nil];\
        __builtin_unreachable();\
    } while(0)
#endif

#endif //__Rubicon_PGDefines_H_
