/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGCString.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/27/18
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

#import "PGCString.h"
#import "PGTools.h"

@implementation PGCString {
        char       *_cString;
        NSString   *_nsString;
        NSUInteger _hash;
    }

    @synthesize length = _length;

    -(instancetype)init {
        return (self = [self initWithCString:NULL]);
    }

    -(instancetype)initWithNSString:(NSString *)string {
        return (self = [self initWithCString:string.UTF8String]);
    }

    -(instancetype)initWithCString:(const char *)cString {
        self = [super init];

        if(self) {
            _length   = (cString ? strlen(cString) : 0);
            _cString  = (cString ? PGStrdup(cString) : NULL);
            _nsString = nil;
            _hash     = 0;
        }

        return self;
    }

    -(const char *)cString {
        return _cString;
    }

    -(NSString *)nsString {
        if(_cString) PGSETIFNIL(self, _nsString, [NSString stringWithUTF8String:_cString]);
        return _nsString;
    }

    -(void)dealloc {
        if(_cString) free(_cString);
        _cString = NULL;
        _length  = 0;
    }

    -(NSString *)description {
        return self.nsString;
    }

    -(BOOL)isEqual:(id)other {
        return (other && ((other == self) || ([other isKindOfClass:[self class]] && [self isEqualToCString:[other cString]])));
    }

    -(BOOL)isEqualToString:(PGCString *)string {
        return (string && ((string == self) || [self isEqualToCString:string.cString]));
    }

    -(BOOL)isEqualToCString:(const char *)other {
        return ((_cString == NULL) ? (other == NULL) : ((_cString == other) || (strcmp(_cString, other) == 0)));
    }

    -(BOOL)isEqualToNSString:(nullable NSString *)other {
        return [self isEqualToCString:other.UTF8String];
    }

    -(NSUInteger)hash {
        /*
         * This class is immutable so we really only need
         * to calculate the hash value once. We will do so
         * on demand.
         */
        PGSETIFZERO(self, _hash, PGCStringHash(_cString, _length));
        return _hash;
    }

    -(NSComparisonResult)compare:(id)object {
        if(object) {
            if(self == object) return NSOrderedSame;
            else if([object isKindOfClass:[self class]]) return [self compareToCString:[((PGCString *)(object)) cString]];
            else @throw PGCreateCompareException(self, object);
        }

        return NSOrderedDescending;
    }

    -(NSComparisonResult)compareToNSString:(NSString *)string {
        return (string ? [self compareToCString:string.UTF8String] : NSOrderedDescending);
    }

    -(NSComparisonResult)compareToCString:(const char *)cString {
        return PGCompareCStrings(_cString, cString);
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        return [(PGCString *)[[self class] alloc] initWithCString:_cString];
    }

    +(instancetype)stringWithNSString:(NSString *)string {
        return [[self alloc] initWithNSString:string];
    }

    +(instancetype)stringWithCString:(const char *)cString {
        return [[self alloc] initWithCString:cString];
    }

@end
