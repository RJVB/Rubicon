/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMNodeContainer.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 7/3/18
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

#import "PGDOMPrivate.h"

#pragma clang diagnostic push

@implementation PGDOMNodeContainer {
    }

    @synthesize items = _items;

    -(instancetype)init {
        self = [super init];

        if(self) {
            PGBadConstructorError;
        }

        return self;
    }

    -(instancetype)initWithOwnerNode:(nullable PGDOMNode *)ownerNode {
        self = [super initWithOwnerNode:ownerNode notificationName:PGDOMNodeListChangedNotification];

        if(self) {
            _items = [NSMutableArray new];
        }

        return self;
    }

#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

    -(PGDOMNode *)item:(NSUInteger)idx {
        NSMutableArray<PGDOMNode *> *items = self.items;
        return ((idx < items.count) ? items[idx] : nil);
    }

    -(NSUInteger)count {
        return self.items.count;
    }

    -(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained[])buffer count:(NSUInteger)len {
        return [self.items countByEnumeratingWithState:state objects:buffer count:len];
    }

    -(PGDOMNode *)objectAtIndexedSubscript:(NSUInteger)idx {
        return self.items[idx];
    }

@end

#pragma clang diagnostic pop
