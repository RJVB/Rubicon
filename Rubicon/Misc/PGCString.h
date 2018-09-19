/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGCString.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/27/18
 *       NOTES: If you will be using PGCString in a multithreaded environment and you will be making changes to the underlying raw data
 *              (updating the char array returned by the "cString" property) then it is advisable to lock this object before reading or
 *              writing to the underlying string buffer and unlocking afterwards.For example:
 *
 *                  PGCString *pgcstr = [PGCString stringWithCString:"a string"];
 *                  [pgcstr lock];
 *                  @try {
 *                      char *buf = pgcstr.cString;
 *                      <do something that updates the contents of "buf">
 *                  }
 *                  @finally { [pgcstr unlock]; }
 *
 *              The methods hash, isEqual:, isEqualToCString:, isEqualToNSString:, isEqualToString:, compare:, compareToNSString:,
 *              compareToCString:, setCString:, copy, and copyWithZone: automatically lock and unlock the object when called.
 *
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

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * If you will be using PGCString in a multithreaded environment and you will be making changes to the underlying raw data
 * (updating the char array returned by the "cString" property) then it is advisable to lock this object before reading or
 * writing to the underlying string buffer and unlocking afterwards. For example:
 *
 *     PGCString *pgcstr = [PGCString stringWithCString:"a string"];
 *     [pgcstr lock];
 *     @try {
 *         char *buf = pgcstr.cString;
 *         <do something that updates the contents of "buf">
 *     }
 *     @finally { [pgcstr unlock]; }
 *
 * The methods hash, isEqual:, isEqualToCString:, isEqualToNSString:, isEqualToString:, compare:, compareToNSString:,
 * compareToCString:, setCString:, copy, and copyWithZone: automatically lock and unlock the object when called.
 */

@interface PGCString : NSObject<NSCopying, NSLocking>

    @property(nullable) /*     */ const char *cString;
    @property(nullable, readonly) NSString   *nsString;
    @property(readonly) /*     */ NSUInteger length;

    -(instancetype)initWithNSString:(nullable NSString *)string;

    -(instancetype)initWithCString:(nullable const char *)cString NS_DESIGNATED_INITIALIZER;

    -(BOOL)isEqualToCString:(nullable const char *)other;

    -(BOOL)isEqualToNSString:(nullable NSString *)other;

    -(BOOL)isEqualToString:(nullable PGCString *)other;

    -(BOOL)isEqual:(nullable id)other;

    -(NSUInteger)hash;

    -(NSComparisonResult)compare:(nullable id)object;

    -(NSComparisonResult)compareToNSString:(nullable NSString *)string;

    -(id)copyWithZone:(nullable NSZone *)zone;

    -(NSComparisonResult)compareToCString:(nullable const char *)cString;

    +(instancetype)stringWithNSString:(nullable NSString *)string;

    +(instancetype)stringWithCString:(nullable const char *)cString;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGCSTRING_H
