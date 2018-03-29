/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGTools.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/30/16 11:03 AM
 *  VISIBILITY: Private
 * DESCRIPTION:
 *
 * Copyright © 2016  Project Galen. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this
 * permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
 * AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#ifndef __Rubicon_PGTools_H_
#define __Rubicon_PGTools_H_

#import <Rubicon/PGTime.h>

/*
 * Definitions for standard 32-bit RGBA color model.
 */
#define PGBitsPerField   (8)
#define PGFieldsPerPixel (4)

/**
 * If the given string reference is null then return an empty string literal. (@"")
 *
 * @param str the string reference.
 * @return the same string reference or @"" if the string reference is null.
 */
NS_INLINE NSString *_Nonnull PGEmptyIfNull(NSString *const _Nullable str) {
    return (str ?: @"");
}

/**
 * Test the equality of two objects. Safely handles the case of either or both objects being NULL.
 * Two objects are considered equal if both are NULL or [obj1 isEqual:obj2] returns TRUE.
 *
 * @param obj1 the first object.
 * @param obj2 the second object.
 * @return YES if both objects are either NULL or equal according to the isEqual: selector.
 */
NS_INLINE BOOL PGObjectsEqual(id _Nullable obj1, id _Nullable obj2) {
    return ((obj1 == nil) ? (obj2 == nil) : ((obj2 == nil) ? NO : [obj1 isEqual:obj2]));
}

/**
 * Test the equality of two strings. Safely handles the case of either or both strings being NULL.
 * Two strings are considered equal if both are NULL or [str1 isEqualToString:str2] returns TRUE.
 *
 * @param str1 the first string.
 * @param str2 the second string.
 * @return YES if both strings are either NULL or equal according to the isEqualToString: selector.
 */
NS_INLINE BOOL PGStringsEqual(NSString *const _Nullable str1, NSString *const _Nullable str2) {
    return ((str1 == nil) ? (str2 == nil) : (str2 == nil) ? NO : [str1 isEqualToString:str2]);
}

/**
 * Safely set a value by reference without having to constantly write code to check the pointers validity.
 * If the value of reference is not nil then the pointer will be de-referenced and the value val will be
 * stored.  Otherwise the value val is simply returned.
 *
 * @param ref the reference.
 * @param val the value.
 * @return the value.
 */
NS_INLINE id _Nullable PGSetReference(id _Nullable *_Nullable ref, id _Nullable val) {
    if(ref) *ref = val;
    return val;
}

FOUNDATION_EXPORT NSComparisonResult PGDateCompare(NSDate *_Nullable d1, NSDate *_Nullable d2);

FOUNDATION_EXPORT NSComparisonResult PGNumCompare(NSNumber *_Nullable n1, NSNumber *_Nullable n2);

FOUNDATION_EXPORT NSComparisonResult PGStrCompare(NSString *_Nullable str1, NSString *_Nullable str2);

/**
 * This function attempts to generically compare two objects to determine their sort ordering. Two
 * objects are fully comparable if 1) they share a common superclass and 2) instances of that
 * superclass implement the "compare:" selector.
 *
 * NOTE: just because two objects have the same ordering weight (this function returns NSOrderedSame)
 * does not automatically mean they have equal values. Equality should still be determined by the
 * "isEqual:" method.
 *
 * @param obj1 the first object.
 * @param obj2 the second object.
 * @return NSOrderedSame if both objects have the same sorting weight, NSOrderedAscending if the first
 *          object's sorting weight is less than the second, and NSOrderedDescending if the first
 *          object's sorting weight is greater than the second.
 * @throws NSException named "NSInvalidArgumentException" if the two objects are not comparable.
 */
FOUNDATION_EXPORT NSComparisonResult PGCompare(id _Nullable obj1, id _Nullable obj2);

/**
 * Creates and returns a bitmap image compatible with PNG file formats.  This allows you
 * to create off-screen images and then save them to a PNG file.
 *
 * @param width the width of the image.
 * @param height the height of the image.
 * @return a bitmap image for off-screen drawing.
 */
FOUNDATION_EXPORT NSBitmapImageRep *_Nonnull PGCreateARGBImage(NSFloat width, NSFloat height);

/**
 * Takes an off-screen image and saves it as a PNG file.
 *
 * @param image the off-screen bitmap image.
 * @param filename the filename to write the image to.
 * @param error a pointer to an error object field that will receive an error object if an error
 *              occurs.
 */
FOUNDATION_EXPORT BOOL PGSaveImageAsPNG(NSBitmapImageRep *_Nonnull image, NSString *_Nonnull filename, NSError *_Nullable *_Nullable error);

/**
 * Returns an NSString as by calling the C function strerror(int).
 *
 * @param osErrNo the C library error number usually obtained from the global variable errno.
 * @return The C library generated error message as an NSString object.
 */
FOUNDATION_EXPORT NSString *_Nonnull PGStrError(int osErrNo);

/**
 * Convenience function for [NSString stringWithFormat:fmt, ...].
 * @param fmt the format string.
 * @param ... the parameters.
 * @return a new string.
 */
FOUNDATION_EXPORT NSString *_Nonnull PGFormat(NSString *_Nonnull fmt, ...) NS_FORMAT_FUNCTION(1, 2);

/**
 * Convenience function for getting the user's temporary file directory.
 *
 * @param error a pointer to an error object field that will receive an error object if an error occurs.
 * @return a URL to the temporary directory or NULL if an error occurs.
 */
FOUNDATION_EXPORT NSURL *_Nullable PGTemporaryDirectory(NSError *_Nullable *_Nullable error);

/**
 * Convenience function for getting a URL to a temporary file.
 *
 * @param filenamePostfix the string to append to the unique filename of the temporary file.
 * @param error a pointer to an error object field that will receive an error object if an error occurs.
 * @return a URL to a temporary file or NULL if an error occurs.
 */
FOUNDATION_EXPORT NSURL *_Nullable PGTemporaryFile(NSString *_Nonnull filenamePostfix, NSError *_Nullable *_Nullable error);

#endif //__Rubicon_PGTools_H_
