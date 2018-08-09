/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMText.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 7/9/18
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

#define canModifySiblings(n) (canModifySiblingsDirection(n, YES) && canModifySiblingsDirection(n, NO))
#define removeAdjacentTextNodes(n) PGBLKOPEN removeTextNodesAdjacentTo((n),NO);removeTextNodesAdjacentTo((n),YES); PGBLKCLOSE

BOOL canModifySiblingsDirection(PGDOMNode *node, BOOL fwd);

void removeTextNodesAdjacentTo(PGDOMText *currentNode, BOOL fwd);

NSString *getWholeText(PGDOMText *node);

@implementation PGDOMText {
        BOOL _isElementContentWhitespace;
    }

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument data:(NSString *)data {
        return (self = [super initWithNodeType:PGDOMNodeTypeText ownerDocument:ownerDocument data:data]);
    }

    -(BOOL)isElementContentWhitespace {
        PGDOMSyncData;
        return _isElementContentWhitespace;
    }

    -(NSString *)wholeText {
        PGDOMSyncData;
        return getWholeText(self);
    }

    -(PGDOMText *)replaceWholeTextWith:(NSString *)content node:(PGDOMText *)node {
        PGDOMNode *parent = node.parentNode;

        if(content) {
            if(!canModifySiblings(node)) {
                @throw [node createNoModException];
            }
            else if(node.isReadOnly) {
                PGDOMText *textNode = [node.ownerDocument createTextNode:content ofType:node.nodeType];

                if(parent) {
                    [parent replaceChild:node with:textNode];
                    removeAdjacentTextNodes(textNode);
                }

                return textNode;
            }
            else {
                node.data = content;
                removeAdjacentTextNodes(node);
                return node;
            }
        }
        else if(parent) {
            removeAdjacentTextNodes(node);
            [parent removeChild:node];
        }

        return nil;
    }

    -(instancetype)replaceWholeTextWith:(NSString *)content {
        PGDOMSyncData;
        return [self replaceWholeTextWith:content node:self];
    }

    -(instancetype)splitTextAtOffset:(NSUInteger)offset {
        PGDOMCheckRO;
        NSString *data = self.data;

        if(offset > data.length) @throw [self createIndexOutOfBoundsException];

        self.data = [data substringToIndex:offset];
        PGDOMText *text = [self.ownerDocument createTextNode:[data substringFromIndex:offset] ofType:self.nodeType];
        [self.parentNode insertChild:text before:self.nextSibling];

        return text;
    }

@end

NS_INLINE BOOL isTextNodeType(PGDOMNode *node) {
    PGDOMNodeTypes nt = node.nodeType;
    return ((nt == PGDOMNodeTypeText) || (nt == PGDOMNodeTypeCDataSection) || ((nt == PGDOMNodeTypeEntityReference) && ((PGDOMEntityReference *)node).hasOnlyTextChildren));
}

BOOL canModifySiblingsDirectionEntRef(BOOL fwd, BOOL *retval, BOOL *textChild, PGDOMNode *child) {
    if(child) {
        do {
            switch(child.nodeType) {
                case PGDOMNodeTypeEntityReference:
                    if(!canModifySiblingsDirection(child, fwd)) {
                        (*retval) = NO;
                        return YES;
                    }
                case PGDOMNodeTypeText:
                case PGDOMNodeTypeCDataSection:
                    (*textChild) = YES;
                    break;
                default:
                    (*retval) = !(*textChild);
                    return YES;
            }
        }
        while((child = NSIBLING(child, fwd)));

        return NO;
    }

    (*retval) = NO;
    return YES;
}

BOOL canModifySiblingsDirection(PGDOMNode *node, BOOL fwd) {
    BOOL      retval;
    BOOL      textChild = NO;
    PGDOMNode *next     = NSIBLING(node, fwd);

    while(next) {
        switch(next.nodeType) {
            case PGDOMNodeTypeEntityReference:
                if(canModifySiblingsDirectionEntRef(fwd, &retval, &textChild, NCHILD(next, fwd))) return retval;
            case PGDOMNodeTypeText:
            case PGDOMNodeTypeCDataSection:
                break;
            default:
                return YES;
        }

        next = NSIBLING(next, fwd);
    }

    return YES;
}

void removeTextNodesAdjacentTo(PGDOMText *currentNode, BOOL fwd) {
    PGDOMNode *parent = currentNode.parentNode;

    if(parent) {
        PGDOMNode *node = NSIBLING(currentNode, fwd);

        while(node) {
            if(isTextNodeType(node)) {
                [parent removeChild:node];
                node = NSIBLING(currentNode, fwd);
            }
            else break;
        }
    }
}

PGDOMNode *findFirstSiblingTextNode(PGDOMNode *node) {
    if(node.parentNode) {
        PGDOMNode *sibling = node.previousSibling;

        while(sibling) {
            if(isTextNodeType(sibling)) {
                node    = sibling;
                sibling = node.previousSibling;
            }
            else break;
        }
    }

    return node;
}

BOOL concatTextNodes(NSMutableString *buffer, PGDOMNode *node) {
    NSMutableString *tbuffer = nil;

    while(node) {
        switch(node.nodeType) {
            case PGDOMNodeTypeText:
            case PGDOMNodeTypeCDataSection:
                [buffer appendString:NVALUE(node)];
                break;
            case PGDOMNodeTypeEntityReference:
                if(!tbuffer) tbuffer = [NSMutableString new];
                if(concatTextNodes(tbuffer, node.firstChild)) return YES;
                [buffer appendString:tbuffer];
                tbuffer.string = @"";
                break;
            default:
                return YES;
        }

        node = node.nextSibling;
    }

    return NO;
}

NSString *getWholeText(PGDOMText *node) {
    NSMutableString *wholeText = [NSMutableString new];
    concatTextNodes(wholeText, findFirstSiblingTextNode(node));
    return wholeText;
}
