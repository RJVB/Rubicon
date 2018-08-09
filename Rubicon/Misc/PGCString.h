/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGCString.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/27/18
 *  VISIBILITY: Private
 *
 * Copyright © 2018 Project Galen. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this
 * permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
 * AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 **********************************************************************************************************************************************************************************/

#ifndef RUBICON_PGCSTRING_H
#define RUBICON_PGCSTRING_H

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGCString : NSObject<NSCopying>

    @property(nullable, readonly) const char *cString;
    @property(nullable, readonly) NSString   *nsString;
    @property(readonly) /*     */ NSUInteger length;

    -(instancetype)initWithNSString:(nullable NSString *)string;

    -(instancetype)initWithCString:(nullable const char *)cString NS_DESIGNATED_INITIALIZER;

    -(BOOL)isEqualToCString:(nullable const char *)other;

    -(BOOL)isEqualToNSString:(nullable NSString *)other;

    -(BOOL)isEqual:(nullable id)other;

    -(BOOL)isEqualToString:(nullable PGCString *)other;

    -(NSUInteger)hash;

    -(NSComparisonResult)compare:(nullable id)object;

    -(NSComparisonResult)compareToNSString:(nullable NSString *)string;

    -(NSComparisonResult)compareToCString:(nullable const char *)cString;

    +(instancetype)stringWithNSString:(nullable NSString *)string;

    +(instancetype)stringWithCString:(nullable const char *)cString;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGCSTRING_H
