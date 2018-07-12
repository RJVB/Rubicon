/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMParent.m
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

#import "PGDOMParent.h"
#import "NSException+PGException.h"
#import "PGDOMPrivate.h"

NS_INLINE void _clearNodePointers(PGDOMNode *oldNode) {
    oldNode.previousSibling = nil;
    oldNode.nextSibling     = nil;
    oldNode.parentNode      = nil;
}

NS_INLINE void _sendNotification(PGDOMNode *node, NSNotificationName name) {
    [node.ownerDocument.notificationCenter postNotificationName:name object:node];
    [node.parentNode grandchildListChanged];
}

@implementation PGDOMParent {
        PGDOMNode *_firstChild;
        PGDOMNode *_lastChild;
    }

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType ownerDocument:(PGDOMDocument *)ownerDocument {
        self = [super initWithNodeType:nodeType ownerDocument:ownerDocument];

        if(self) {
            PGAbstractClassTest(PGDOMParent);
        }

        return self;
    }

    -(PGDOMNode *)firstChild {
        return _firstChild;
    }

    -(PGDOMNode *)lastChild {
        return _lastChild;
    }

    -(BOOL)canAcceptNode:(PGDOMNode *)node {
        return (node.nodeType != PGDOMNodeTypeDocument);
    }

    -(NSException *)createException:(NSString *)reason {
        return [NSException exceptionWithName:NSInvalidArgumentException reason:reason];
    }

    -(void)testNewChildNode:(PGDOMNode *)node {
        /*
         * Check that this node can accept a new child node of that type.
         */
        if(![self canAcceptNode:node]) {
            NSString *reason = PGFormat(PGDOMErrorMsgBadChildType, node.nodeTypeDescription, self.nodeTypeDescription);
            @throw [self createException:reason];
        }
        /*
         * Check that this node and the new child node have the same owning document.
         */
        if(self.ownerDocument != node.ownerDocument) @throw [self createException:PGDOMErrorMsgOwnerDocumentMismatch];

        PGDOMNode *_n = self;
        /*
         * Make sure this node and the new child node are not the same
         * node and make sure that neither this node nor any of it's parents
         * are a child of the new child node.
         */
        do {
            if(_n == node) @throw [self createException:PGDOMErrorMsgHierarchy];
            _n = _n.parentNode;
        }
        while(_n);
        /*
         * Finally, if this new child already has a parent (even if it's us) then remove it from that parent first.
         */
        if(node.parentNode) [node.parentNode removeChild:node];
    }

    -(PGDOMNode *)appendChild:(PGDOMNode *)newNode {
        if(self.isReadOnly) @throw [self createNoModificationException];
        if(newNode) {
            [self testNewChildNode:newNode];
            [self _appendChild:newNode];
            [self postChildListChangeNotification];
        }

        return newNode;
    }

    -(PGDOMNode *)insertChild:(PGDOMNode *)newNode before:(PGDOMNode *)refNode {
        if(!refNode) return [self appendChild:newNode];
        if(self.isReadOnly) @throw [self createNoModificationException];
        if(newNode) {
            if(self != refNode.parentNode) @throw [self createException:PGFormat(PGDOMErrorMsgNodeNotChild, PGDOMMsgReference)];
            [self testNewChildNode:newNode];
            [self _insertChild:newNode before:refNode];
            [self postChildListChangeNotification];
        }

        return newNode;
    }

    -(PGDOMNode *)replaceChild:(PGDOMNode *)oldNode with:(PGDOMNode *)newNode {
        if(self.isReadOnly) @throw [self createNoModificationException];
        if(oldNode) {
            if(self != oldNode.parentNode) @throw [self createException:PGFormat(PGDOMErrorMsgNodeNotChild, PGDOMMsgOld)];
            /*
             * Replacing a node with itself does nothing.
             */
            if(newNode != oldNode) {
                [self testNewChildNode:newNode];
                [self _replaceChild:oldNode with:newNode];
                [self postChildListChangeNotification];
            }
        }
        else @throw [self createException:PGFormat(PGDOMErrorMsgNodeNull, PGDOMMsgOld)];

        return oldNode;
    }

    -(PGDOMNode *)removeChild:(PGDOMNode *)oldNode {
        if(self.isReadOnly) @throw [self createNoModificationException];
        if(oldNode) {
            if(self != oldNode.parentNode) @throw [self createException:PGFormat(PGDOMErrorMsgNodeNotChild, PGDOMMsgOld)];
            [self _removeChild:oldNode];
            [self postChildListChangeNotification];
        }

        return oldNode;
    }

    -(void)grandchildListChanged {
        _sendNotification(self, PGDOMCascadeNodeListChangedNotification);
    }

    -(void)postChildListChangeNotification {
        _sendNotification(self, PGDOMNodeListChangedNotification);
    }

    -(void)_updateFirst:(PGDOMNode *)first last:(PGDOMNode *)last ifCurrentIs:(PGDOMNode *)existing {
        /*
         * On a replace or a remove the old node may have been
         * the first node, last node, or both in the linked
         * list so we have to updated those with the new nodes.
         */
        if(_firstChild == existing) _firstChild = first;
        if(_lastChild == existing) _lastChild   = last;
    }

    -(void)_appendChild:(PGDOMNode *)newNode {
        /*
         * Appending to the end is pretty straight forward.
         */
        newNode.parentNode      = self;
        newNode.nextSibling     = nil;
        newNode.previousSibling = _lastChild;
        /*
         * On an append the new node will ALWAYS
         * be the last node in the linked list.
         */
        _lastChild = (_lastChild ? (_lastChild.nextSibling = newNode) : (_firstChild = newNode));
    }

    -(void)_insertChild:(PGDOMNode *)newNode before:(PGDOMNode *)refNode {
        /*
         * Asseert that there is at least one existing
         * child node and that refNode is one of them.
         */
        newNode.parentNode                  = refNode.parentNode;
        newNode.nextSibling                 = refNode;
        newNode.previousSibling             = refNode.previousSibling;
        newNode.previousSibling.nextSibling = newNode;
        refNode.previousSibling             = newNode;
        /*
         * On an insert the new node will never be
         * the last node in the linked list.
         */
        if(_firstChild == refNode) _firstChild = newNode;
    }

    -(void)_replaceChild:(PGDOMNode *)oldNode with:(PGDOMNode *)newNode {
        newNode.parentNode                  = oldNode.parentNode;
        newNode.nextSibling                 = oldNode.nextSibling;
        newNode.previousSibling             = oldNode.previousSibling;
        newNode.nextSibling.previousSibling = newNode;
        newNode.previousSibling.nextSibling = newNode;
        /*
         * If the old node is the first node, last node, or both
         * in the linked list then the new node will take its place.
         */
        [self _updateFirst:newNode last:newNode ifCurrentIs:oldNode];
        _clearNodePointers(oldNode);
    }

    -(void)_removeChild:(PGDOMNode *)oldNode {
        /*
         * If the old node was the first and/or last node
         * in the linked list then it will be replaced with
         * it's next and/or previous siblings respectively.
         */
        [self _updateFirst:oldNode.nextSibling last:oldNode.previousSibling ifCurrentIs:oldNode];
        oldNode.previousSibling.nextSibling = oldNode.nextSibling;
        oldNode.nextSibling.previousSibling = oldNode.previousSibling;
        _clearNodePointers(oldNode);
    }

@end
