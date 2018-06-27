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
        char *_cString;
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
            _length  = (cString ? strlen(cString) : 0);
            _cString = (_length ? PGStrdup(cString) : NULL);
        }

        return self;
    }

    -(const char *)cString {
        return (_cString ?: "");
    }

    -(NSString *)nsString {
        return [NSString stringWithUTF8String:self.cString];
    }

    -(void)dealloc {
        if(_cString) free(_cString);
        _cString = NULL;
        _length  = 0;
    }

    -(NSString *)description {
        return self.nsString;
    }

    +(instancetype)stringWithNSString:(NSString *)string {
        return [[self alloc] initWithNSString:string];
    }

    +(instancetype)stringWithCString:(const char *)cString {
        return [[self alloc] initWithCString:cString];
    }

@end
