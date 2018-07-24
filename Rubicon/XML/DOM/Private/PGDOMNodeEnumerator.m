/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMNodeEnumerator.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 7/20/18
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

#import "PGDOMNodeEnumerator.h"
#import "PGDOMParent.h"
#import "PGDOMPrivate.h"

@implementation PGDOMNodeEnumerator {
        PGDOMNode *_next;
    }

    @synthesize owner = _owner;

    -(instancetype)initWithOwner:(PGDOMParent *)owner {
        self = [super init];

        if(self) {
            _owner = owner;
            _next  = owner.firstChild;
        }

        return self;
    }

    +(instancetype)enumeratorWithOwner:(PGDOMParent *)owner {
        return [[self alloc] initWithOwner:owner];
    }

    -(PGDOMNode *)nextObject {
        if(_next) {
            PGDOMNode *n = _next;
            _next = n.nextSibling;
            return n;
        }

        _owner = nil;
        return nil;
    }

@end
