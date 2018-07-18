/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMDocument.m
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

#import "PGDOMPrivate.h"

@implementation PGDOMDocument {
    }

    @synthesize notificationCenter = _notificationCenter;

    -(instancetype)init {
        self = [super initWithNodeType:PGDOMNodeTypeDocument ownerDocument:nil];

        if(self) {
            _notificationCenter = [NSNotificationCenter new];
            self.isReadOnly = NO;
        }

        return self;
    }

    -(PGDOMText *)createTextNode:(NSString *)content {
        return [[PGDOMText alloc] initWithOwnerDocument:self data:content];
    }

    -(PGDOMCDataSection *)createCDataSection:(NSString *)content {
        return [[PGDOMCDataSection alloc] initWithOwnerDocument:self data:content];
    }

    -(PGDOMText *)createTextNode:(NSString *)content ofType:(PGDOMNodeTypes)nodeType {
        if(nodeType == PGDOMNodeTypeText) return [self createTextNode:content];
        if(nodeType == PGDOMNodeTypeCDataSection) return [self createCDataSection:content];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGFormat(PGDOMErrorMsgNotTextNode, [PGDOMNode nodeTypeDescription:nodeType])];
    }

@end
