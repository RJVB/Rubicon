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
 *//************************************************************************/
#ifndef __Rubicon_PGTools_H_
#define __Rubicon_PGTools_H_

#import <Rubicon/PGTime.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT const NSByte UTF8_2ByteMarker;
FOUNDATION_EXPORT const NSByte UTF8_3ByteMarker;
FOUNDATION_EXPORT const NSByte UTF8_4ByteMarker;
FOUNDATION_EXPORT const NSByte UTF8_2ByteMarkerMask;
FOUNDATION_EXPORT const NSByte UTF8_3ByteMarkerMask;
FOUNDATION_EXPORT const NSByte UTF8_4ByteMarkerMask;

@class NSStream;

/*
 * Definitions for standard 32-bit RGBA color model.
 */
#define PGBitsPerField   (8)
#define PGFieldsPerPixel (4)

#define PGThrowInvArgException(r)   @throw [NSException exceptionWithName:NSInvalidArgumentException reason:r userInfo:nil]
#define PGThrowOutOfMemoryException @throw [NSException exceptionWithName:NSMallocException reason:@"Out of memory" userInfo:nil]
#define PGThrowNullPointerException PGThrowInvArgException(@"NULL Pointer")

#define PGSETIFNIL(l, f, v)  dispatch_sync(PGSharedSerialQueue(), ^{ if((f)  == nil) (f) = (v); })
#define PGSETIFNULL(l, f, v) dispatch_sync(PGSharedSerialQueue(), ^{ if((f) == NULL) (f) = (v); })
#define PGSETIFZERO(l, f, v) dispatch_sync(PGSharedSerialQueue(), ^{ if((f)  == (0)) (f) = (v); })

#define PG_BRDG_CAST(t)  (__bridge t *)

#ifndef PG_HASOVERLOADABLE
    #define PG_HASOVERLOADABLE __has_extension(attribute_overloadable)

    #if PG_HASOVERLOADABLE
        #define PG_OVERLOADABLE __attribute__((overloadable))
    #else
        #error "CLANG Overloadable Attribute must be supported."
    #endif
#endif

#define PGSharedSerialQueueLabel "com.projectgalen.sharedSerialQueue"

FOUNDATION_EXPORT dispatch_queue_t PGSharedSerialQueue();

FOUNDATION_EXPORT NSData *PGGetEmptyNSDataSingleton(void);

FOUNDATION_EXPORT size_t PGCopyString(char **ptr, const char *str);

FOUNDATION_EXPORT NSUInteger PGHash(const void *buffer, size_t length);

/**
 * Given a string, this function will prefix all of the specified characters with the escapeChar.
 *
 * @param str the string.
 * @param escapeChar the character that will be prefixed to each of the following characters. If the string contains more than one character then only the first one is used.
 * @param ... a list of strings containing the characters to escape. If any of the strings contains more than one character (composed character, such as emojis,
 *            count as one character) then each character will be broken out separately.
 * @return a new string with the escaped sequences.
 */
FOUNDATION_EXPORT NSString *PGEscapeString(NSString *str, NSString *escapeChar, ...) NS_REQUIRES_NIL_TERMINATION;

FOUNDATION_EXPORT NSString *_Nullable PGValidateDate(NSString *dateString);

FOUNDATION_EXPORT NSString *_Nullable PGValidateTime(NSString *timeString);

FOUNDATION_EXPORT NSByte *PGMemReverse(NSByte *buffer, NSUInteger length);

FOUNDATION_EXPORT voidp PGMemDup(cvoidp src, size_t size);

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
FOUNDATION_EXPORT NSBitmapImageRep *PGCreateARGBImage(NSFloat width, NSFloat height);

/**
 * Takes an off-screen image and saves it as a PNG file.
 *
 * @param image the off-screen bitmap image.
 * @param filename the filename to write the image to.
 * @param error a pointer to an error object field that will receive an error object if an error
 *              occurs.
 */
FOUNDATION_EXPORT BOOL PGSaveImageAsPNG(NSBitmapImageRep *image, NSString *filename, NSError *_Nullable *_Nullable error);

/**
 * Returns an NSString as by calling the C function strerror(int).
 *
 * @param osErrNo the C library error number usually obtained from the global variable errno.
 * @return The C library generated error message as an NSString object.
 */
FOUNDATION_EXPORT NSString *PGStrError(int osErrNo);

/**
 * Convenience function for [NSString stringWithFormat:fmt, ...].
 * @param fmt the format string.
 * @param ... the parameters.
 * @return a new string.
 */
FOUNDATION_EXPORT NSString *PGFormat(NSString *fmt, ...) NS_FORMAT_FUNCTION(1, 2);

FOUNDATION_EXPORT void PGPrintf(NSString *fmt, ...) NS_FORMAT_FUNCTION(1, 2);

FOUNDATION_EXPORT void PGFPrintf(NSString *filename, NSError **error, NSString *fmt, ...) NS_FORMAT_FUNCTION(3, 4);

FOUNDATION_EXPORT void PGSPrintf(NSOutputStream *outs, NSString *fmt, ...) NS_FORMAT_FUNCTION(2, 3);

FOUNDATION_EXPORT void PGSPrintfVA(NSOutputStream *outs, NSString *fmt, va_list args);

FOUNDATION_EXPORT void PGFPrintfVA(NSString *filename, NSError **error, NSString *fmt, va_list args);

FOUNDATION_EXPORT NSString *PGFormatVA(NSString *fmt, va_list args);

FOUNDATION_EXPORT void PGLog(NSString *fmt, ...) NS_FORMAT_FUNCTION(1, 2);

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
FOUNDATION_EXPORT NSURL *_Nullable PGTemporaryFile(NSString *filenamePostfix, NSError *_Nullable *_Nullable error);

FOUNDATION_EXPORT NSError *PGCreateError(NSString *domain, NSInteger code, NSString *description);

FOUNDATION_EXPORT NSError *PGOpenInputStream(NSInputStream *input);

FOUNDATION_EXPORT NSException *PGCreateCompareException(id obj1, id obj2);

/**
 * This function provides a bit of an easier way to read from an input stream into a buffer. This function returns a simple YES if data
 * was put into the buffer or NO if it wasn't.  Then all you have to do is check the value of 'readStatus' to see if the reason for
 * no data was because of end-of-input (0) or I/O error (< 0).  If there was data put in the buffer then 'readStatus' indicates the number
 * of bytes read. If there was an error then the 'error' parameter will be set to the value given by the input stream.
 *
 * @param input the input stream to read the bytes from.
 * @param buffer the buffer to receive the bytes.
 * @param maxLength the maximum number of bytes that 'buffer' can hold.
 * @param readStatus same as what's returned from NSInputStream's 'read:maxLength:' method.
 * @param error error
 * @return YES if data was read or NO if EOF or ERROR.
 */
FOUNDATION_EXPORT BOOL PGReadIntoBuffer(NSInputStream *input, void *buffer, NSUInteger maxLength, int *readStatus, NSError **error);

FOUNDATION_EXPORT NSUInteger PGCStringHash(const char *str, size_t len) PG_OVERLOADABLE;

FOUNDATION_EXPORT char *PGCleanStr(const char *str, size_t len, char includeSpaces) PG_OVERLOADABLE;

NS_INLINE NSUInteger PG_OVERLOADABLE PGCStringHash(const char *str) {
    return PGCStringHash(str, (str ? strlen(str) : 0));
}

NS_INLINE char *PG_OVERLOADABLE PGCleanStr(const char *str, char includeSpaces) {
    return PGCleanStr(str, strlen(str), includeSpaces);
}

NS_INLINE voidp PGTestPtr(voidp _Nullable _ptr) {
    if(_ptr) return (_ptr); else PGThrowOutOfMemoryException;
}

NS_INLINE void PGSwapPtr(voidp *x, voidp *y) {
    voidp z = *x;
    *x = *y;
    *y = z;
}

NS_INLINE void PGSwapObjs(id *x, id *y) {
    id z = *x;
    *x = *y;
    *y = z;
}

NS_INLINE char *PGStrdup(const char *str) {
    return PGTestPtr(strdup(str));
}

NS_INLINE voidp PGMalloc(size_t _sz) {
    return PGTestPtr(malloc(_sz));
}

NS_INLINE voidp PGCalloc(size_t count, size_t size) {
    return PGTestPtr(calloc(count, size));
}

NS_INLINE voidp PGRealloc(voidp _Nullable _ptr, size_t _sz) {
    return PGTestPtr(_ptr ? realloc(_ptr, _sz) : malloc(_sz));
}

NS_INLINE voidp PGMemCopy(voidp dest, cvoidp src, size_t length) {
    return (length ? memcpy(dest, src, length) : dest);
}

NS_INLINE voidp PGMemPCopy(voidp dest, cvoidp src, size_t length) {
    return (length ? (memcpy(dest, src, length) + length) : dest);
}

NS_INLINE size_t PGMemLCopy(voidp dest, cvoidp src, size_t length) {
    if(length) memcpy(dest, src, length);
    return length;
}

NS_INLINE voidp PGMemMove(voidp dest, cvoidp src, size_t length) {
    return (length ? memmove(dest, src, length) : dest);
}

NS_INLINE voidp PGMemPMove(voidp dest, cvoidp src, size_t length) {
    return (length ? (memmove(dest, src, length) + length) : dest);
}

NS_INLINE size_t PGMemLMove(void *dest, const void *src, size_t length) {
    if(length) memmove(dest, src, length);
    return length;
}

NS_INLINE voidp PGMemShift(voidp src, NSInteger delta, NSUInteger length) {
    return PGMemMove((src + delta), src, length);
}

NS_INLINE voidp PGMemPShift(voidp src, NSInteger delta, NSUInteger length) {
    return (PGMemShift(src, delta, length) + length);
}

NS_INLINE NSInteger PGMemCmp(cvoidp p1, cvoidp p2, NSUInteger length) {
    return (length ? memcmp(p1, p2, length) : 0);
}

NS_INLINE BOOL PGMemEqu(cvoidp p1, cvoidp p2, NSUInteger length) {
    return ((length == 0) || (memcmp(p1, p2, length) == 0));
}

NS_INLINE NSComparisonResult PGCompareCStrings(const char *_Nullable s1, const char *_Nullable s2) {
    if(s1 == s2) return NSOrderedSame;
    if(s1 == NULL) return NSOrderedAscending;
    if(s2 == NULL) return NSOrderedDescending;
    int cc = strcmp(s1, s2);
    return ((cc == 0) ? NSOrderedSame : ((cc < 0) ? NSOrderedAscending : NSOrderedDescending));
}

NS_INLINE NSComparisonResult PGInvertComparison(NSComparisonResult cr) {
    return ((NSComparisonResult)(((NSInteger)(cr)) * -1L));
}

NS_INLINE NSUInteger PGRangeLength(NSUInteger startingLoc, NSUInteger endingLoc) {
    return (MAX(startingLoc, endingLoc) - MIN(startingLoc, endingLoc));
}

NS_INLINE NSRange PGRangeFromIndexes(NSUInteger loc1, NSUInteger loc2) {
    return NSMakeRange(MIN(loc1, loc2), PGRangeLength(loc1, loc2));
}

NS_INLINE NSException *_Nullable PGValidateRange(NSString *string, NSRange range) {
    if(range.location < string.length && NSMaxRange(range) < string.length) return nil;
    NSString *r = PGFormat(PGErrorMsgRangeOutOfBounds, range.location, range.length, string.length);
    return [NSException exceptionWithName:NSRangeException reason:r userInfo:nil];
}

/**
 * If the given string reference is null then return an empty string literal. (@"")
 *
 * @param str the string reference.
 * @return the same string reference or @"" if the string reference is null.
 */
NS_INLINE NSString *PGEmptyIfNull(NSString *const _Nullable str) {
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
    return ((str1 == nil) ? (str2 == nil) : (str2 && ((str1 == str2) || [str1 isEqualToString:str2])));
}

/**
 * Test the equality of two arrays. Safely handles the case of either or both arrays being NULL.
 *
 * @param ar1 the first array.
 * @param ar2 the second array.
 * @return YES if both string are either NULL or equal according to the isEqualToArray: selector.
 */
NS_INLINE BOOL PGArraysEqual(NSArray *const _Nullable ar1, NSArray *const _Nullable ar2) {
    return ((ar1 == nil) ? (ar2 == nil) : (ar2 && ((ar1 == ar2) || [ar1 isEqualToArray:ar2])));
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

NS_INLINE void PGFreeBuffer(void *_Nullable buffer, size_t length, char secure) {
    if(buffer) {
        if(secure) getrandom(buffer, length, 0);
        free(buffer);
    }
}

NS_ASSUME_NONNULL_END

#endif //__Rubicon_PGTools_H_
