/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMNotifiedContainer.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/29/18
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

#import "PGDOMNotifiedContainer.h"
#import "PGDOMPrivate.h"

@implementation PGDOMNotifiedContainer {
    }

    @synthesize ownerNode = _ownerNode;
    @synthesize ownerDocument = _ownerDocument;
    @synthesize nc = _nc;

    -(instancetype)initWithOwnerNode:(nullable PGDOMNode *)ownerNode notificationName:(NSNotificationName)notificationName {
        self = [super init];

        if(self) {
            _ownerNode     = ownerNode;
            _ownerDocument = _ownerNode.ownerDocument;
            _nc            = (_ownerDocument.notificationCenter ?: [NSNotificationCenter defaultCenter]);

            [self.nc addObserver:self selector:@selector(nodeListChangeListener:) name:PGDOMNodeListChangedNotification object:self.ownerNode];
            [self nodeListChangeListener:[NSNotification notificationWithName:notificationName object:self.ownerNode]];
        }

        return self;
    }

    -(void)dealloc {
        [self.nc removeObserver:self];
    }

    -(void)nodeListChangeListener:(NSNotification *)notification {
    }

@end
