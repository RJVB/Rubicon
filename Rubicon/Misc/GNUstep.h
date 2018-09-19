/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: GNUstep.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/21/16 3:19 PM
 *  VISIBILITY: Public
 * DESCRIPTION:
 *
 * Copyright © 2016 Galen Rhodes All rights reserved.
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
 *//************************************************************************/

#ifndef __Rubicon_GNUstep_H_
#define __Rubicon_GNUstep_H_

/*
 * This library is designed to work with clang.
 */
#if !defined(__clang__) || (__clang_major__ < 5)
    #error "Unsupported compiler detected"
#endif

#import <Cocoa/Cocoa.h>
#import <Rubicon/AppleFoundation.h>

#ifndef PG_ARC
    #if defined(__has_feature) && __has_feature(objc_arc)
        #define PG_ARC 1
    #else
        #define PG_ARC 0
    #endif
#endif

/* @formatter:off */
#ifdef __GNUSTEP_RUNTIME__
	#if PG_ARC && !defined(OS_OBJECT_USE_OBJC_RETAIN_RELEASE)
		#define OS_OBJECT_USE_OBJC_RETAIN_RELEASE 0
	#endif

	#if defined(__cplusplus)
		#define FOUNDATION_EXTERN extern "C"
	#else
		#define FOUNDATION_EXTERN extern
	#endif

	#if !defined(NS_INLINE)
		#if defined(__GNUC__)
			#define NS_INLINE static __inline__ __attribute__((always_inline))
		#elif defined(__MWERKS__) || defined(__cplusplus)
			#define NS_INLINE static inline
		#elif defined(_MSC_VER)
			#define NS_INLINE static __inline
		#elif TARGET_OS_WIN32
			#define NS_INLINE static __inline__
		#endif
	#endif

	#ifndef OS_INLINE
		#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
			#define OS_INLINE static inline
		#else
			#define OS_INLINE static __inline__
		#endif
	#endif

	#ifndef NS_DESIGNATED_INITIALIZER
		#if __has_attribute(objc_designated_initializer)
			#define NS_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
		#else
			#define NS_DESIGNATED_INITIALIZER
		#endif
	#endif

	#ifndef FOUNDATION_STATIC_INLINE
		#define FOUNDATION_STATIC_INLINE static __inline__
	#endif

	#ifndef FOUNDATION_EXTERN_INLINE
		#define FOUNDATION_EXTERN_INLINE extern __inline__
	#endif
#endif
/* @formatter:on */

#endif //__Rubicon_GNUstep_H_
