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

#import <Foundation/Foundation.h>
#import <Rubicon/PGTime.h>

/*
 * Definitions for standard 32-bit RGBA color model.
 */
#define PGBitsPerField   (8)
#define PGFieldsPerPixel (4)

/**************************************************************************************************//**
 * Test the equality of two objects. Safely handles the case of either or both objects being NULL.
 * Two objects are considered equal if both are NULL or [obj1 isEquals:obj2] returns TRUE.
 *
 * @param obj1 the first object.
 * @param obj2 the second object.
 * @return YES if both objects are either NULL or equal according to the isEqual: selector.
 */
NS_INLINE BOOL PGObjectsEqual(id obj1, id obj2) {
	return ((obj1 == nil) ? (obj2 == nil) : ((obj2 == nil) ? NO : [obj1 isEqual:obj2]));
}

/**************************************************************************************************//**
 * Safely set a value by reference without having to constantly write code to check the pointers validaty.
 * If the value of reference is not nil then the pointer will be de-referenced and the value val will be
 * stored.  Otherwise the value val is simply returned.
 *
 * @param ref the reference.
 * @param val the value.
 * @return the value.
 */
NS_INLINE id PGSetReference(id *ref, id val) {
	if(ref) *ref = val;
	return val;
}

/**************************************************************************************************//**
 * Compares to objects for order.  Returns NSOrderedAscending, NSOrderedSame, NSOrderedDescending if
 * obj1 is less than, equal to, or greater than obj2.
 * @param obj1 the first object.
 * @param obj2 the second object.
 * @return NSOrderedAscending, NSOrderedSame, NSOrderedDescending if obj1 is less than, equal to, or
 *         greater than obj2.
 ******************************************************************************************************/
FOUNDATION_EXPORT NSComparisonResult PGCompare(id obj1, id obj2);

/**************************************************************************************************//**
 * Creates and returns a bitmap image compatible with PNG file formats.  This allows you
 * to create off-screen images and then save them to a PNG file.
 *
 * @param width the width of the image.
 * @param height the height of the image.
 * @return a bitmap image for off-screen drawing.
 ******************************************************************************************************/
FOUNDATION_EXPORT NSBitmapImageRep *PGCreateARGBImage(NSFloat width, NSFloat height);

/**************************************************************************************************//**
 * Takes an off-screen image and saves it as a PNG file.
 *
 * @param image the off-screen bitmap image.
 * @param filename the filename to write the image to.
 * @param error a pointer to an error object field that will receive an error object if an error
 *              occurs.
 ******************************************************************************************************/
FOUNDATION_EXPORT BOOL PGSaveImageAsPNG(NSBitmapImageRep *image, NSString *filename, NSError **error);

/**************************************************************************************************//**
 * Returns an NSString as by calling the C function strerror(int).
 *
 * @param osErrNo the C library error number usually obtained from the global variable errno.
 * @return The C library generated error message as an NSString object.
 ******************************************************************************************************/
FOUNDATION_EXPORT NSString *PGStrError(int osErrNo);

/**************************************************************************************************//**
 * Convenience function for [NSString stringWithFormat:fmt, ...].
 * @param fmt the format string.
 * @param ... the parameters.
 * @return a new string.
 */
FOUNDATION_EXPORT NSString *PGFormat(NSString *fmt, ...) NS_FORMAT_FUNCTION(1, 2);

#endif //__Rubicon_PGTools_H_

