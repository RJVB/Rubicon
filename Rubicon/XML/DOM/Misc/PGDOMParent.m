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

#import "PGDOMPrivate.h"

NSString *const PGDOMErrorMsgNodeListError = @"Node list exception";

#define __CLICK(f, l) ((f) && !(l))
#define __CLACK(f, l) ((l) && !(f))

@interface PGDOMParent(Internal)

    -(void)_clearEndPointers;

    -(void)_takeChildren:(PGDOMParent *)parent before:(PGDOMNode *)refNode;

    -(void)_insertNodeList:(PGDOMNode *)first last:(PGDOMNode *)last before:(PGDOMNode *)refNode;

    -(void)_testNewChildNode:(PGDOMNode *)node;

    -(void)_testAllNewChildNodes:(NSArray<PGDOMNode *> *)allNodes;

    -(void)_insertChild:(PGDOMNode *)newNode before:(PGDOMNode *)refNode;

    -(void)_insertAllChildNodes:(NSArray<PGDOMNode *> *)childNodes before:(PGDOMNode *)refNode;

    -(void)_insertAllChildNodes:(NSEnumerator<PGDOMNode *> *)en prev:(PGDOMNode *)prev next:(PGDOMNode *)next last:(PGDOMNode *)last;

    -(void)_replaceChild:(PGDOMNode *)oldNode with:(PGDOMNode *)newNode;

    -(void)_removeChild:(PGDOMNode *)oldNode;

    -(void)_joinLeftNode:(PGDOMNode *)left andRightNode:(PGDOMNode *)right;

    -(void)_removeAllChildren:(NSMutableArray<PGDOMNode *> *)removedNodes;

    -(void)_setTextContent:(NSString *)textContent;

@end

NS_INLINE PGDOMNode *_joinNodes(PGDOMNode *leftNode, PGDOMNode *rightNode) {
    if(leftNode) leftNode.nextSibling       = rightNode;
    if(rightNode) rightNode.previousSibling = leftNode;
    return rightNode;
}

NS_INLINE PGDOMNode *_setNodePointers(PGDOMNode *node, PGDOMNode *parent, PGDOMNode *previous, PGDOMNode *next) {
    node.parentNode = parent;
    _joinNodes(previous, node);
    _joinNodes(node, next);
    return node;
}

NS_INLINE PGDOMNode *_clearNodePointers(PGDOMNode *oldNode) {
    oldNode.parentNode = oldNode.nextSibling = oldNode.previousSibling = nil;
    return oldNode;
}

NS_INLINE void _sendNotification(PGDOMNode *node, NSNotificationName name) {
    [node.ownerDocument.notificationCenter postNotificationName:name object:node];
    [node.parentNode grandchildListChanged];
}

NS_INLINE void _sanityCheck2(PGDOMNode *f, PGDOMNode *l) {
    if((f) && (l) && (f != l)) {
        PGDOMNode *n = f;
        while(n.nextSibling) n = n.nextSibling;
        if(n != l) @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:PGDOMErrorMsgNodeListError];
        n = l;
        while(n.previousSibling) n = n.previousSibling;
        if(n != f) @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:PGDOMErrorMsgNodeListError];
    }
}

NS_INLINE BOOL _sanityCheck1(PGDOMNode **first, PGDOMNode **last) {
    PGDOMNode *f = *first;
    PGDOMNode *l = *last;

    if(__CLICK(f, l)) {
        l = f;
        while(l.nextSibling) l = l.nextSibling;
        *last = l;
        return YES;
    }
    else if(__CLACK(f, l)) {
        f = l;
        while(f.previousSibling) f = f.previousSibling;
        *first = f;
        return YES;
    }

    return NO;
}

NS_INLINE void _sanityCheck(PGDOMNode **first, PGDOMNode **last) {
    _sanityCheck1(first, last);
    _sanityCheck2(*first, *last);
}

#define RMND(n)   do{if(self==(n).parentNode)[self _removeChild:(n)];else[n.parentNode removeChild:n];}while(0)
#define PSTCHG    do{_childListChanged++;[self postChildListChangeNotification];}while(0)
#define SETPTR(n) do{if(!(n).previousSibling)_firstChild=(n);if(!(n).nextSibling)_lastChild=(n);}while(0)

@implementation PGDOMParent {
        PGDOMNode       *_firstChild;
        PGDOMNode       *_lastChild;
        NSUInteger      _childListChanged;
        NSRecursiveLock *_lck;
    }

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType ownerDocument:(PGDOMDocument *)ownerDocument {
        self = [super initWithNodeType:nodeType ownerDocument:ownerDocument];

        if(self) {
            PGAbstractClassTest(PGDOMParent);
        }

        return self;
    }

    /**
     * Although the PGDOM* library as a whole is not thread safe we want to
     * make the operations here as atomic as possible. This is because we
     * are dealing with a linked list of nodes that we don't want to get
     * messed up if the operations happens to be called from separate
     * threads. So we will be using a recursive lock to make sure that one
     * operation on child nodes completes before another one starts.
     */
    -(void)lock {
        PGSETIFNIL(self, _lck, [NSRecursiveLock new]);
        [_lck lock];
    }

    -(void)unlock {
        [_lck unlock];
    }

    -(BOOL)needsSyncData {
        return ((__CLICK(_firstChild, _lastChild) || __CLACK(_firstChild, _lastChild)) || (super.needsSyncData));
    }

    -(void)synchronizeData {
        if(_sanityCheck1(&_firstChild, &_lastChild)) ++_childListChanged;
        [super synchronizeData];
    }

    -(PGDOMNode *)firstChild {
        PGDOMSyncData;
        return _firstChild;
    }

    -(PGDOMNode *)lastChild {
        PGDOMSyncData;
        return _lastChild;
    }

    -(BOOL)canAcceptNode:(PGDOMNode *)node {
        PGDOMSyncData;
        return (node.nodeType != PGDOMNodeTypeDocument);
    }

    -(NSString *)textContent {
        NSMutableString *s = [NSMutableString new];
        [self lock];
        @try { FORCHILD(self, n) [s appendString:n.textContent]; } @finally { [self unlock]; }
        return s;
    }

    -(NSArray<PGDOMNode *> *)allChildNodes {
        NSMutableArray<PGDOMNode *> *list = [NSMutableArray new];
        [self lock];
        @try { FORCHILD(self, n) [list addObject:n]; } @finally { [self unlock]; }
        return list;
    }

    -(void)testNewChildNode:(PGDOMNode *)node {
        if(!node) @throw [self createInvArgException:PGFormat(PGDOMErrorMsgNodeNull, PGDOMMsgNewChild)];
        if(node.isDocumentFragment) { FORCHILD(node, dfNode) [self _testNewChildNode:dfNode]; } else [self _testNewChildNode:node];
    }

    -(PGDOMNode *)appendChild:(PGDOMNode *)newNode {
        return [self insertChild:newNode before:nil];
    }

    -(PGDOMNode *)insertChild:(PGDOMNode *)newNode before:(PGDOMNode *)refNode {
        [self lock];
        @try {
            PGDOMSyncData;
            PGDOMCheckRO;
            if(refNode && (self != refNode.parentNode)) @throw [self createInvArgException:PGFormat(PGDOMErrorMsgNodeNotChild, PGDOMMsgReference)];
            [self testNewChildNode:newNode];
            [self _insertChild:newNode before:refNode];
            PSTCHG;
        }
        @finally { [self unlock]; }
        return newNode;
    }

    -(PGDOMNode *)replaceChild:(PGDOMNode *)oldNode with:(PGDOMNode *)newNode {
        [self lock];
        @try {
            PGDOMSyncData;
            PGDOMCheckRO;
            if(!oldNode) @throw [self createInvArgException:PGFormat(PGDOMErrorMsgNodeNull, PGDOMMsgOld)];
            if(self != oldNode.parentNode) @throw [self createInvArgException:PGFormat(PGDOMErrorMsgNodeNotChild, PGDOMMsgOld)];
            [self testNewChildNode:newNode];
            [self _replaceChild:oldNode with:newNode];
            PSTCHG;
        }
        @finally { [self unlock]; }
        return oldNode;
    }

    -(PGDOMNode *)removeChild:(PGDOMNode *)oldNode {
        [self lock];
        @try {
            PGDOMSyncData;
            PGDOMCheckRO;
            if(!oldNode) @throw [self createInvArgException:PGFormat(PGDOMErrorMsgNodeNull, PGDOMMsgOld)];
            if(self != oldNode.parentNode) @throw [self createInvArgException:PGFormat(PGDOMErrorMsgNodeNotChild, PGDOMMsgOld)];
            [self _removeChild:oldNode];
            PSTCHG;
        }
        @finally { [self unlock]; }
        return oldNode;
    }

    -(void)setTextContent:(NSString *)textContent {
        [self lock];
        @try {
            PGDOMSyncData;
            PGDOMCheckRO;
            [self _setTextContent:textContent];
            PSTCHG;
        }
        @finally { [self unlock]; }
    }

    /**
     * Quickly remove all the child nodes. Optionally put the removed
     * nodes into an array in the same order they existed in this node.
     *
     * @param removedNodes an array to receive the removed nodes.
     */
    -(void)removeAllChildren:(NSMutableArray<PGDOMNode *> *)removedNodes {
        [self lock];
        @try {
            PGDOMSyncData;
            PGDOMCheckRO;
            [self _removeAllChildren:removedNodes];
            PSTCHG;
        }
        @finally { [self unlock]; }
    }

    -(void)removeAllChildren {
        [self removeAllChildren:nil];
    }

    /**
     * A fast way to set all the child nodes in one call. All current child nodes are first removed.
     *
     * @param childNodes an array of nodes to add to this node.
     */
    -(void)setAllChildNodes:(NSArray<PGDOMNode *> *)childNodes {
        [self lock];
        @try {
            PGDOMSyncData;
            PGDOMCheckRO;
            [self _testAllNewChildNodes:childNodes];
            [self _removeAllChildren:nil];
            [self _insertAllChildNodes:childNodes before:nil];
            PSTCHG;
        }
        @finally { [self unlock]; }
    }

    -(void)appendAllChildNodes:(NSArray<PGDOMNode *> *)childNodes {
        [self insertAllChildNodes:childNodes before:nil];
    }

    -(void)insertAllChildNodes:(NSArray<PGDOMNode *> *)childNodes before:(PGDOMNode *)refNode {
        [self lock];
        @try {
            PGDOMSyncData;
            PGDOMCheckRO;
            if(refNode && (self != refNode.parentNode)) @throw [self createInvArgException:PGFormat(PGDOMErrorMsgNodeNotChild, PGDOMMsgReference)];
            [self _testAllNewChildNodes:childNodes];
            [self _insertAllChildNodes:childNodes before:refNode];
            PSTCHG;
        }
        @finally { [self unlock]; }
    }

    -(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained _Nullable[_Nonnull])buffer count:(NSUInteger)len {
        /*
         * Make sure we're not trying to get data right in the middle of an
         * operation that might change the list. And make sure an operation
         * doesn't change the list while we're getting it.
         */
        [self lock];
        NSUInteger count = 0;

        @try {
            if(state->state == 0) {
                PGDOMSyncData;
                state->state = 1;
                state->extra[0] = ((unsigned long)((__bridge void *)self.firstChild));
                state->mutationsPtr = &_childListChanged;
            }

            if(state->state == 1) {
                PGDOMNode __unsafe_unretained *node = ((__bridge PGDOMNode *)((void *)state->extra[0]));

                while(node && (count < len)) {
                    buffer[count++] = node;
                    node = node.nextSibling;
                }

                if(node) {
                    state->extra[0] = ((unsigned long)((__bridge void *)node));
                }
                else {
                    state->extra[0] = 0;
                    state->state = 2;
                }
            }
        }
        @finally { [self unlock]; }

        return count;
    }

    -(NSEnumerator<PGDOMNode *> *)childNodeEnumerator {
        return [PGDOMNodeEnumerator enumeratorWithOwner:self];
    }

    -(void)grandchildListChanged {
        _sendNotification(self, PGDOMCascadeNodeListChangedNotification);
    }

    -(void)postChildListChangeNotification {
        _sendNotification(self, PGDOMNodeListChangedNotification);
    }

    -(void)_testNewChildNode:(PGDOMNode *)node {
        /*
         * Check that this node can accept a new child node of that type.
         */
        if(![self canAcceptNode:node]) {
            NSString *reason = PGFormat(PGDOMErrorMsgBadChildType, node.nodeTypeDescription, self.nodeTypeDescription);
            @throw [self createInvArgException:reason];
        }
        /*
         * Check that this node and the new child node have the same owning document.
         */
        if(self.ownerDocument != node.ownerDocument) {
            @throw [self createInvArgException:PGDOMErrorMsgOwnerDocumentMismatch];
        }

        /*
         * Make sure this node and the new child node are not the same
         * node and make sure that neither this node nor any of it's parents
         * are a child of the new child node.
         */
        PGDOMNode *n = self;
        do {
            if(n == node) {
                @throw [self createInvArgException:PGDOMErrorMsgHierarchy];
            }
            n = n.parentNode;
        }
        while(n);
    }

    -(void)_testAllNewChildNodes:(NSArray<PGDOMNode *> *)allNodes {
        for(PGDOMNode *node in allNodes) [self testNewChildNode:node];
    }

    -(void)_insertChild:(PGDOMNode *)newNode before:(PGDOMNode *)refNode {
        if(refNode.isDocumentFragment) {
            [self _takeChildren:(PGDOMParent *)newNode before:refNode];
        }
        else {
            RMND(newNode);
            _setNodePointers(newNode, self, (refNode ? refNode.previousSibling : _lastChild), refNode);
            SETPTR(newNode);
        }
    }

    -(void)_insertAllChildNodes:(NSArray<PGDOMNode *> *)childNodes before:(PGDOMNode *)refNode {
        if(childNodes.count) {
            NSEnumerator<PGDOMNode *> *en = childNodes.objectEnumerator;
            [self _insertAllChildNodes:en prev:(refNode ? refNode.previousSibling : _lastChild) next:en.nextObject last:refNode];
        }
    }

    -(void)_insertAllChildNodes:(NSEnumerator<PGDOMNode *> *)en prev:(PGDOMNode *)prev next:(PGDOMNode *)next last:(PGDOMNode *)last {
        if(!prev) _firstChild = next;

        do {
            next.parentNode = self;
            prev = _joinNodes(prev, next);
            next = en.nextObject;
        }
        while(next);

        if(!_joinNodes(prev, last)) _lastChild = prev;
    }

    -(void)_replaceChild:(PGDOMNode *)oldNode with:(PGDOMNode *)newNode {
        if(newNode.isDocumentFragment) {
            [self _takeChildren:(PGDOMParent *)newNode before:oldNode];
            [self _removeChild:oldNode];
        }
        else {
            RMND(newNode);
            _setNodePointers(newNode, self, oldNode.previousSibling, oldNode.nextSibling);
            _clearNodePointers(oldNode);
            SETPTR(newNode);
        }
    }

    -(void)_removeChild:(PGDOMNode *)oldNode {
        [self _joinLeftNode:oldNode.previousSibling andRightNode:oldNode.nextSibling];
        _clearNodePointers(oldNode);
    }

    -(void)_joinLeftNode:(PGDOMNode *)left andRightNode:(PGDOMNode *)right {
        _joinNodes(left, right);
        if(right == nil) _lastChild = left;
        if(left == nil) _firstChild = right;
    }

    -(void)_removeAllChildren:(NSMutableArray<PGDOMNode *> *)removedNodes {
        PGDOMNode *t, *node = _firstChild;
        _firstChild = _lastChild = nil;

        if(node) {
            if(removedNodes) {
                while(node) {
                    t = node.nextSibling;
                    _clearNodePointers(node);
                    [removedNodes addObject:node];
                    node = t;
                }
            }
            else {
                while(node) {
                    t = node.nextSibling;
                    _clearNodePointers(node);
                    node = t;
                }
            }
        }
    }

    -(void)_setTextContent:(NSString *)textContent {
        [self _removeAllChildren:nil];
        (_firstChild = _lastChild = [self.ownerDocument createTextNode:textContent]).parentNode = self;
    }

    -(void)_clearEndPointers {
        _firstChild = _lastChild = nil;
    }

    -(void)_takeChildren:(PGDOMParent *)parent before:(PGDOMNode *)refNode {
        if(parent) {
            PGDOMNode *first = nil, *last = nil;
            [parent lock];
            @try {
                first = parent.firstChild;
                last  = parent.lastChild;
                [parent _clearEndPointers];
            }
            @finally { [parent unlock]; }
            [self _insertNodeList:first last:last before:refNode];
        }
    }

    -(void)_insertNodeList:(PGDOMNode *)first last:(PGDOMNode *)last before:(PGDOMNode *)refNode {
        _sanityCheck(&first, &last);
        if(first && last) {
            FORSIBLING(first, n) n.parentNode = self;
            _joinNodes((refNode ? refNode.previousSibling : _lastChild), first);
            _joinNodes(last, refNode);
            SETPTR(first);
            SETPTR(last);
        }
    }

@end
