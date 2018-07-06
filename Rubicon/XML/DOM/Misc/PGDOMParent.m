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
         * Make sure this node and the new child node are not the same node and make sure that either this node nor any of it's parents
         * are not a child of the new child node.
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
        if(newNode) {
            [self testNewChildNode:newNode];
            /*
             * Appending to the end is pretty straight forward.
             */
            if(_lastChild) _lastChild.nextSibling = newNode; else _firstChild = newNode;
            newNode.previousSibling = _lastChild;
            _lastChild = newNode;
            newNode.parentNode  = self;
            newNode.nextSibling = nil;

            [self postChildListChangeNotification];
        }

        return newNode;
    }

    -(PGDOMNode *)insertChild:(PGDOMNode *)newNode before:(PGDOMNode *)refNode {
        if(!refNode) return [self appendChild:newNode];

        if(newNode) {
            if(self != refNode.parentNode) @throw [self createException:PGFormat(PGDOMErrorMsgNodeNotChild, PGDOMMsgReference)];
            [self testNewChildNode:newNode];

            newNode.parentNode                  = self;
            newNode.previousSibling             = refNode.previousSibling;
            refNode.previousSibling             = newNode;
            newNode.nextSibling                 = refNode;
            newNode.previousSibling.nextSibling = newNode;
            if(_firstChild == refNode) _firstChild = newNode;

            [self postChildListChangeNotification];
        }

        return newNode;
    }

    -(PGDOMNode *)replaceChild:(PGDOMNode *)oldNode with:(PGDOMNode *)newNode {
        if(oldNode) {
            if(self != oldNode.parentNode) @throw [self createException:PGFormat(PGDOMErrorMsgNodeNotChild, PGDOMMsgOld)];
            /*
             * Replacing a node with itself does nothing.
             */
            if(newNode != oldNode) {
                [self testNewChildNode:newNode];
                newNode.parentNode      = self;
                newNode.nextSibling     = oldNode.nextSibling;
                newNode.previousSibling = oldNode.previousSibling;

                if(_lastChild == oldNode) _lastChild   = newNode;
                if(_firstChild == oldNode) _firstChild = newNode;

                oldNode.previousSibling = nil;
                oldNode.nextSibling     = nil;
                oldNode.parentNode      = nil;

                [self postChildListChangeNotification];
            }
        }
        else @throw [self createException:PGFormat(PGDOMErrorMsgNodeNull, PGDOMMsgOld)];

        return oldNode;
    }

    -(PGDOMNode *)removeChild:(PGDOMNode *)oldNode {
        if(oldNode) {
            if(self != oldNode.parentNode) @throw [self createException:PGFormat(PGDOMErrorMsgNodeNotChild, PGDOMMsgOld)];
            if(_lastChild == oldNode) _lastChild   = oldNode.previousSibling;
            if(_firstChild == oldNode) _firstChild = oldNode.nextSibling;

            oldNode.previousSibling.nextSibling = oldNode.nextSibling;
            oldNode.nextSibling.previousSibling = oldNode.previousSibling;
            oldNode.previousSibling             = nil;
            oldNode.nextSibling                 = nil;
            oldNode.parentNode                  = nil;

            [self postChildListChangeNotification];
        }

        return oldNode;
    }

    -(void)postChildListChangeNotification {
        [self.ownerDocument.notificationCenter postNotificationName:PGDOMNodeListChangedNotification object:self];
    }

@end
