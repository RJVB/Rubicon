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
 *******************************************************************************/

#ifndef __Rubicon_PGDefines_H_
#define __Rubicon_PGDefines_H_

#import <Rubicon/GNUstep.h>

typedef long long NSLong;
typedef CGFloat   NSFloat;  // For the Sheldon Cooper in me.

static const NSUInteger NSUNotFound = NSUIntegerMax;

#if defined(__APPLE__)
	#define PGMaxSemaphoreNameLength 30
#else
	#define PGMaxSemaphoreNameLength 251
#endif

#if !defined(PGNotImplemented)
	#define PGNotImplemented [self doesNotRecognizeSelector:_cmd]; __builtin_unreachable()
#endif

#if NS_BLOCKS_AVAILABLE

typedef BOOL (^PGBinaryTreeTravelBlock)(id nodeKey, id nodeValue);

#endif

@protocol PGBinaryTreeTraveler

	-(BOOL)visitNodeWithKey:(id)aKey andValue:(id)aValue;

@end

FOUNDATION_EXPORT NSString *const PGErrorDomain;

FOUNDATION_EXPORT NSString *const PGTimedWorkerException;
FOUNDATION_EXPORT NSString *const PGSemaphoreException;
FOUNDATION_EXPORT NSString *const PGReadWriteLockException;
FOUNDATION_EXPORT NSString *const PGOSErrorException;
FOUNDATION_EXPORT NSString *const PGDOMException;

FOUNDATION_EXPORT NSString *const PGDefaultSemaphoreNamePrefix;

#endif //__Rubicon_PGDefines_H_