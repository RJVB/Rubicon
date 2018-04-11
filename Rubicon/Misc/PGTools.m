/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGTools.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/30/16 11:03 AM
 * DESCRIPTION:
 *
 * Copyright © 2016 Project Galen. All rights reserved.
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

#import "PGTools.h"
#import "NSObject+PGObject.h"

NSBitmapImageRep *PGCreateARGBImage(NSFloat width, NSFloat height) {
    NSInteger iWidth  = (NSInteger)ceil(width);
    NSInteger iHeight = (NSInteger)ceil(height);

    return [[NSBitmapImageRep alloc]
                              initWithBitmapDataPlanes:NULL
                                            pixelsWide:iWidth
                                            pixelsHigh:iHeight
                                         bitsPerSample:PGBitsPerField
                                       samplesPerPixel:PGFieldsPerPixel
                                              hasAlpha:YES
                                              isPlanar:NO
                                        colorSpaceName:NSDeviceRGBColorSpace
                                          bitmapFormat:NSAlphaFirstBitmapFormat
                                           bytesPerRow:(iWidth * PGFieldsPerPixel)
                                          bitsPerPixel:(PGBitsPerField * PGFieldsPerPixel)];
}

BOOL PGSaveImageAsPNG(NSBitmapImageRep *image, NSString *filename, NSError **error) {
    NSData *pngData = [image representationUsingType:NSPNGFileType properties:@{}];
    return [pngData writeToFile:filename options:0 error:error];
}

NSString *PGStrError(int osErrNo) {
    return [NSString stringWithUTF8String:strerror(osErrNo)];
}

NSString *PGFormatVA(NSString *fmt, va_list args) {
    return [[NSString alloc] initWithFormat:fmt arguments:args];
}

NSString *PGFormat(NSString *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    NSString *str = [[NSString alloc] initWithFormat:fmt arguments:args];
    va_end(args);
    return str;
}

void PGFPrintfVA(NSString *filename, NSError **error, NSString *fmt, va_list args) {
    NSError *err = nil;
    [PGFormatVA(fmt, args) writeToFile:filename atomically:NO encoding:NSUTF8StringEncoding error:&err];
    if(error) *error = err;
}

void PGFPrintf(NSString *filename, NSError **error, NSString *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    PGFPrintfVA(filename, error, fmt, args);
    va_end(args);
}

void PGPrintf(NSString *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    PGFPrintfVA(@"/dev/stdout", nil, fmt, args);
    va_end(args);
}

void PGSPrintfVA(NSOutputStream *outs, NSString *fmt, va_list args) {
    NSString   *str    = PGFormatVA(fmt, args);
    const char *buffer = str.UTF8String;
    size_t     bufflen = strlen(buffer);
    size_t     buffsnt = 0;

    while(buffsnt < bufflen) {
        NSInteger r = [outs write:(const uint8_t *)(buffer + buffsnt) maxLength:(bufflen - buffsnt)];
        if(r <= 0) break;
        buffsnt += r;
    }
}

void PGSPrintf(NSOutputStream *outs, NSString *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    PGSPrintfVA(outs, fmt, args);
    va_end(args);
}

NSComparisonResult PGDateCompare(NSDate *d1, NSDate *d2) {
    return ((d1 == d2) ? NSOrderedSame : ((d1 && d2) ? [d1 compare:d2] : (d2 ? NSOrderedAscending : NSOrderedDescending)));
}

NSComparisonResult PGNumCompare(NSNumber *n1, NSNumber *n2) {
    return ((n1 == n2) ? NSOrderedSame : ((n1 && n2) ? [n1 compare:n2] : (n2 ? NSOrderedAscending : NSOrderedDescending)));
}

NSComparisonResult PGStrCompare(NSString *str1, NSString *str2) {
    return ((str1 == str2) ? NSOrderedSame : ((str1 && str2) ? [str1 compare:str2] : (str2 ? NSOrderedAscending : NSOrderedDescending)));
}

NSComparisonResult _PGCompare(id obj1, id obj2) {
    if([[obj1 superclassInCommonWith:obj2] instancesRespondToSelector:@selector(compare:)]) return [obj1 compare:obj2];

    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:PGFormat(@"Class %@ cannot be compared to class %@.", NSStringFromClass([obj1 class]), NSStringFromClass([obj2 class]))
                                 userInfo:nil];
}

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
NSComparisonResult PGCompare(id obj1, id obj2) {
    return ((obj1 == obj2) ? NSOrderedSame : ((obj1 && obj2) ? _PGCompare(obj1, obj2) : (obj2 ? NSOrderedAscending : NSOrderedDescending)));
}

NSURL *PGTemporaryDirectory(NSError **error) {
    return [[NSFileManager defaultManager]
                           URLForDirectory:NSItemReplacementDirectory
                                  inDomain:NSUserDomainMask
                         appropriateForURL:[NSURL fileURLWithPath:NSHomeDirectory() isDirectory:YES]
                                    create:YES
                                     error:error];
}

NSURL *PGTemporaryFile(NSString *filenamePostfix, NSError **error) {
    NSURL *tempDir = PGTemporaryDirectory(error);

    if(tempDir) {
        if(filenamePostfix.length == 0) filenamePostfix = @"temp.tmp";
        return [tempDir URLByAppendingPathComponent:PGFormat(@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], filenamePostfix)];
    }

    return nil;
}

NSBytePtr PGMemoryReverse(NSBytePtr buffer, NSUInteger length) {
    if(buffer && length > 1) {
        NSBytePtr a = buffer, b = (buffer + length);

        while((b - a) > 1) {
            NSByte t = *a;
            *(a++) = *(--b);
            *b     = t;
        }
    }

    return buffer;
}
