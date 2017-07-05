/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGKeyValueData.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 3/29/17 10:39 AM
 * DESCRIPTION:
 *
 * Copyright © 2017 Project Galen. All rights reserved.
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

#import "PGKeyValueData.h"
#import "NSObject+PGObject.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

@implementation PGKeyValueData {
    }

    @synthesize key = _key;
    @synthesize value = _value;

    -(instancetype)initWithValue:(id)value forKey:(id<NSCopying>)key {
        self = [super init];

        if(self) {
            if(value) {
                if(key && [(id)key respondsToSelector:@selector(compare:)]) {  // I love reflection and instrospection.
                    _key = [(id)key copy];
                    self.value = value;
                }
                else {
                    NSString *reason = (key ? @"Key cannot be null." : @"Key must respond to the compare: selector.");
                    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
                }
            }
            else {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Value cannot be null." userInfo:nil];
            }
        }

        return self;
    }

    +(instancetype)dataWithValue:(id)value forKey:(id)key {
        return [[self alloc] initWithValue:value forKey:key];
    }

    -(NSComparisonResult)compare:(PGKeyValueData *)kvData {
        return [self compareKeyTo:kvData.key];
    }

    -(NSComparisonResult)compareKeyTo:(id)otherKey {
        return PGCompare(self.key, otherKey);
    }

@end

#pragma clang diagnostic pop
