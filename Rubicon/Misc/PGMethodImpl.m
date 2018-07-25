/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGMethodImpl.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 7/24/18
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

#import "PGMethodImpl.h"

@implementation PGMethodImpl {
    }

    @synthesize f = _f;
    @synthesize sel = _sel;
    @synthesize obj = _obj;

    -(instancetype)initWithSelector:(SEL)sel forObject:(id)obj {
        self = [super init];

        if(self) {
            _f = ([obj respondsToSelector:sel] ? [obj methodForSelector:sel] : nil);

            if(_f) {
                _sel = sel;
                _obj = obj;
            }
            else {
                self = nil;
            }
        }

        return self;
    }

    +(instancetype)methodWithSelector:(SEL)sel forObject:(id)obj {
        return [[self alloc] initWithSelector:sel forObject:obj];
    }

@end
