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
        char            *_cString;
        NSRecursiveLock *_lock;
    }

    @synthesize length = _length;

    -(instancetype)init {
        return (self = [self initWithCString:""]);
    }

    -(instancetype)initWithNSString:(NSString *)string {
        return (self = [self initWithCString:string.UTF8String]);
    }

    -(instancetype)initWithCString:(const char *)cString {
        self = [super init];

        if(self) {
            if(cString) {
                _length  = strlen(cString);
                _cString = PGStrdup(cString);
            }
        }

        return self;
    }

    -(const char *)cString {
        return _cString;
    }

    -(NSString *)nsString {
        return (_cString ? (_length ? [NSString stringWithUTF8String:_cString] : @"") : nil);
    }

    -(void)dealloc {
        _length = self.clearBuffer;
    }

    -(NSString *)description {
        return self.nsString;
    }

    -(BOOL)isEqualToCString:(const char *)other {
        [self lock];
        @try { return ((_cString == other) || (_cString && other && !strcmp(_cString, other))); } @finally { [self unlock]; }
    }

    -(BOOL)isEqual:(id)other {
        return (other && ((other == self) || ([other isKindOfClass:[self class]] && [self isEqualToCString:[other cString]])));
    }

    -(BOOL)isEqualToString:(PGCString *)string {
        if(!string) return NO;
        if(self == string) return YES;
        [string lock];
        @try { return [self isEqualToCString:string.cString]; } @finally { [string unlock]; }
    }

    -(BOOL)isEqualToNSString:(nullable NSString *)other {
        return [self isEqualToCString:other.UTF8String];
    }

    -(NSUInteger)hash {
        [self lock];
        @try { return PGByteBufferHash(_cString, _length); } @finally { [self unlock]; }
    }

    -(NSComparisonResult)compareToCString:(const char *)cString {
        [self lock];
        @try { return PGCompareCStrings(_cString, cString); } @finally { [self unlock]; }
    }

    -(NSComparisonResult)_compare:(PGCString *)other {
        [other lock];
        @try { return [self compareToCString:[other cString]]; } @finally { [other unlock]; }
    }

    -(NSComparisonResult)compare:(id)object {
        if(!object) return NSOrderedDescending;
        else if(self == object) return NSOrderedSame;
        else if([object isKindOfClass:[self class]]) return [self _compare:object];
        else @throw PGCreateCompareException(self, object);
    }

    -(NSComparisonResult)compareToNSString:(NSString *)string {
        return (string ? [self compareToCString:string.UTF8String] : NSOrderedDescending);
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        [self lock];
        @try { return [(PGCString *)[[self class] alloc] initWithCString:_cString]; } @finally { [self unlock]; }
    }

    +(instancetype)stringWithNSString:(NSString *)string {
        return [[self alloc] initWithNSString:string];
    }

    +(instancetype)stringWithCString:(const char *)cString {
        return [[self alloc] initWithCString:cString];
    }

    -(void)lock {
        PGSETIFNIL(self, _lock, [NSRecursiveLock new]);
        [_lock lock];
    }

    -(void)unlock {
        [_lock unlock];
    }

    -(NSUInteger)reallocCopy:(const char *)cString {
        NSUInteger length = strlen(cString);
        NSUInteger nsz    = (length + 1);

        if(length != _length) _cString = PGRealloc(_cString, nsz);
        memcpy(_cString, cString, nsz);
        return length;
    }

    -(NSUInteger)clearBuffer {
        if(_cString) free(_cString);
        _cString = NULL;
        return 0;
    }

    -(void)setCString:(const char *)cString {
        [self lock];
        @try {
            if(_cString != cString) {
                _length = ((cString && !_cString) ? PGCopyString(&_cString, cString) : ((_cString && !cString) ? self.clearBuffer : [self reallocCopy:cString]));
            }
        }
        @finally { [self unlock]; }
    }

@end
