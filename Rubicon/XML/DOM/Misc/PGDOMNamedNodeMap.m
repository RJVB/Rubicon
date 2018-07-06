/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMNamedNodeMap.m
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

#import "PGDOMPrivate.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

@implementation PGDOMNamedNodeMap {
    }

    -(PGDOMNode *)itemWithName:(NSString *)nodeName {
        return nil;
    }

    -(PGDOMNode *)itemWithLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI {
        return nil;
    }

    -(PGDOMNode *)removeItemWithName:(NSString *)nodeName {
        return nil;
    }

    -(PGDOMNode *)removeItemWithLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI {
        return nil;
    }

    -(PGDOMNode *)addItem:(PGDOMNode *)node {
        return nil;
    }

    -(PGDOMNode *)addItemNS:(PGDOMNode *)node {
        return nil;
    }

@end

#pragma clang diagnostic pop
