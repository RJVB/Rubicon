/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGTools.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 12/30/16 11:03 AM
 *  VISIBILITY: Private
 * DESCRIPTION:
 *
 * Copyright © 2016  Project Galen. All rights reserved.
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

#ifndef __Rubicon_PGTools_H_
#define __Rubicon_PGTools_H_

#import <Cocoa/Cocoa.h>
#import <Rubicon/GNUstep.h>

#define PGBitsPerField   (8)
#define PGFieldsPerPixel (4)

NSBitmapImageRep *PGCreateARGBImage(CGFloat width, CGFloat height);

BOOL PGSaveImageAsPNG(NSBitmapImageRep *image, NSString *filename, NSError **error);

/* Tests for equality of floats/doubles.
 * WARNING assumes the values are in the standard IEEE format ...
 * this may not be true on all systems, though afaik it is the case
 * on all systems we target.
 *
 * We use integer arithmetic for speed, assigning the float/double
 * to an integer of the same size and then converting any negative
 * values to twos-complement integer values so that a simple integer
 * comparison can be done.
 *
 * MAX_ULP specified the number of Units in the Last Place by which
 * the two values may differ and still be considered equal.  A value
 * of zero means that the two numbers must be identical.
 *
 * The way that infinity is represented means that it will be considered
 * equal to MAX_FLT (or MAX_DBL) unless we are doing an exact comparison
 * with MAX_ULP set to zero.
 *
 * The implementation will also treat two NaN values as being equal, which
 * is technically wrong ... but is it worth adding a check for that?
 */
#define MAX_ULP        0
#define CGFLOAT_IS_DBL 1

static inline BOOL almostEqual(CGFloat A, CGFloat B) {
#if    MAX_ULP == 0
	return (A == B) ? YES : NO;
#else	/* MAX_UPL == 0 */
	#if	defined(CGFLOAT_IS_DBL)
	union {int64_t i; double d;} valA, valB;

	valA.d = A;
	valB.d = B;
#if	GS_SIZEOF_LONG == 8
	if (valA.i < 0)
	  {
		valA.i = 0x8000000000000000L - valA.i;
	  }
	if (valB.i < 0)
	  {
		valB.i = 0x8000000000000000L - valB.i;
	  }
	if (labs(valA.i - valB.i) <= MAX_ULP)
	  {
		return YES;
	  }
#else	/* GS_SIZEOF_LONG == 8 */
	if (valA.i < 0)
	  {
		valA.i = 0x8000000000000000LL - valA.i;
	  }
	if (valB.i < 0)
	  {
		valB.i = 0x8000000000000000LL - valB.i;
	  }
	if (llabs(valA.i - valB.i) <= MAX_ULP)
	  {
		return YES;
	  }
#endif	/* GS_SIZEOF_LONG == 8 */
	return NO;
	#else	/* DEFINED(CGFLOAT_IS_DBL) */
	union {int32_t i; float f;} valA, valB;

	valA.f = A;
	if (valA.i < 0)
	  {
		valA.i = 0x80000000 - valA.i;
	  }
	valB.f = B;
	if (valB.i < 0)
	  {
		valB.i = 0x80000000 - valB.i;
	  }
	if (abs(valA.i - valB.i) <= MAX_ULP)
	  {
		return YES;
	  }
	return NO;
	#endif	/* DEFINED(CGFLOAT_IS_DBL) */
#endif	/* MAX_UPL == 0 */
}

#endif //__Rubicon_PGTools_H_
