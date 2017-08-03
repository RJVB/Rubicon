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
 *******************************************************************************/

#import "PGTools.h"
#import "NSObject+PGObject.h"
#import "PGTimeSpec.h"

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

NSString *PGFormat(NSString *fmt, ...) {
    va_list  args;
    NSString *str = nil;
    va_start(args, fmt);
    str = [[NSString alloc] initWithFormat:fmt arguments:args];
    va_end(args);
    return str;
}

/**************************************************************************************************//**
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
    if(obj1 == obj2) {
        return NSOrderedSame;
    }
    else if(obj1 && obj2) {
        if([obj1 isEqual:obj2]) {
            return NSOrderedSame;
        }
        else {
            Class cls = [obj1 superclassInCommonWith:obj2];

            if([cls instancesRespondToSelector:@selector(compare:)]) {
                return [obj1 compare:obj2];
            }
            else {
                NSString *className1 = NSStringFromClass([obj1 class]);
                NSString *className2 = NSStringFromClass([obj2 class]);
                NSString *reason     = PGFormat(@"Class %@ cannot be compared to class %@.", className1, className2);
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
            }
        }
    }
    else {
        return (obj2 ? NSOrderedAscending : NSOrderedDescending);
    }
}
