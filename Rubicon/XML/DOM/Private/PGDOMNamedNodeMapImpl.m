/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMNamedNodeMapImpl.m
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

#import "PGDOMNamedNodeMapImpl.h"
#import "PGDOMPrivate.h"

@implementation PGDOMNamedNodeMapImpl {
    }

    @synthesize nodeNameCache = _nodeNameCache;
    @synthesize localNameCache = _localNameCache;

    -(instancetype)init {
        self = [super init];

        if(self) {
            _nodeNameCache  = [PGMutableBinaryTreeDictionary new];
            _localNameCache = [PGMutableBinaryTreeDictionary new];
        }

        return self;
    }

    -(instancetype)initWithOwnerNode:(PGDOMNode *)ownerNode {
        self = [super initWithOwnerNode:ownerNode];

        if(self) {
            _nodeNameCache  = [PGMutableBinaryTreeDictionary new];
            _localNameCache = [PGMutableBinaryTreeDictionary new];
        }

        return self;
    }

    -(void)nodeListChangeListener:(NSNotification *)notification {
        [self clearCaches];
    }

    -(void)clearCaches {
        [self.nodeNameCache removeAllObjects];
        [self.localNameCache removeAllObjects];
    }

    -(PGDOMNode *)itemWithName:(NSString *)nodeName {
        if(nodeName) {
            PGDOMNode *node = self.nodeNameCache[nodeName];

            if(node) return node;

            for(node in self.items) {
                if([node.nodeName isEqualToString:nodeName]) {
                    self.nodeNameCache[nodeName] = node;
                    return node;
                }
            }
        }

        return nil;
    }

    -(PGDOMNode *)itemWithLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI {
        if(!namespaceURI) {
            return [self itemWithName:localName];
        }
        else if(localName) {
            PGDOMNodeTree ntree = self.localNameCache[namespaceURI];
            PGDOMNode     *node = (ntree ? ntree[localName] : nil);

            if(node) return node;

            for(node in self.items) {
                if([node.localName isEqualToString:localName] && [node.namespaceURI isEqualToString:namespaceURI]) {
                    if(!ntree) self.localNameCache[namespaceURI] = ntree = [PGMutableBinaryTreeDictionary new];
                    ntree[localName]                             = node;
                    return node;
                }
            }
        }

        return nil;
    }

    -(PGDOMNode *)removeNode:(PGDOMNode *)node {
        if(node) {
            [self.items removeObjectIdenticalTo:node];
            [self clearCaches];
            [self.nc postNotificationName:PGDOMNodeListChangedNotification object:self];
        }

        return node;
    }

    -(PGDOMNode *)removeItemWithName:(NSString *)nodeName {
        return [self removeNode:[self itemWithName:nodeName]];
    }

    -(PGDOMNode *)removeItemWithLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI {
        return [self removeNode:[self itemWithLocalName:localName namespaceURI:namespaceURI]];
    }

    -(PGDOMNode *)replaceNode:(PGDOMNode *)oldNode withNode:(PGDOMNode *)newNode {
        if(newNode) {
            if(self.ownerDocument && (self.ownerDocument != newNode.ownerDocument)) {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGDOMErrorMsgOwnerDocumentMismatch];
            }
            else if(oldNode) {
                if(newNode != oldNode) [self.items replaceObjectIdenticalTo:oldNode withObject:newNode];
            }
            else {
                [self.items addObject:newNode];
            }

            [self clearCaches];
            [self.nc postNotificationName:PGDOMNodeListChangedNotification object:self];
            return oldNode;
        }

        return nil;
    }

    -(PGDOMNode *)addItem:(PGDOMNode *)node {
        return [self replaceNode:[self itemWithName:node.nodeName] withNode:node];
    }

    -(PGDOMNode *)addItemNS:(PGDOMNode *)node {
        return [self replaceNode:[self itemWithLocalName:node.localName namespaceURI:node.namespaceURI] withNode:node];
    }


@end
