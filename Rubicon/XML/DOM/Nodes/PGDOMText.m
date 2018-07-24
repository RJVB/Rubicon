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

@implementation PGDOMText {
        BOOL     _isElementContentWhitespace;
        NSString *_wholeText;
    }

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType ownerDocument:(nullable PGDOMDocument *)ownerDocument data:(NSString *)data {
        self = [super initWithNodeType:nodeType ownerDocument:ownerDocument data:data];

        if(self) {
        }

        return self;
    }

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument data:(NSString *)data {
        return (self = [self initWithNodeType:PGDOMNodeTypeText ownerDocument:ownerDocument data:data]);
    }

    -(BOOL)isElementContentWhitespace {
        PGDOMSyncData;
        return _isElementContentWhitespace;
    }

    -(BOOL)getWholeText:(NSMutableString *)txt forward:(BOOL)fwd node:(PGDOMNode *)node parent:(PGDOMNode *)parent {
        /*@f:0*/
        PGDOMProcBlk a = ^BOOL(PGDOMNode *n, NSInteger *r, BOOL f) { NSString *v = n.nodeValue; if(v.length) { if(f) [txt appendString:v]; else [txt insertString:v atIndex:0]; } return NO; };
        PGDOMProcBlk b = ^BOOL(PGDOMNode *n, NSInteger *r, BOOL f) { return [self getWholeText:txt forward:f node:NCHILD(n, f) parent:n]; };
        PGDOMProcBlk c = ^BOOL(PGDOMNode *n, NSInteger *r, BOOL f) { return YES; };

        if([self textProc:node forward:fwd blkEntRef:b blkText:a blkDefault:c defRetVal:YES endRetVal:NO]) return YES;
        if(parent.isEntityReference) { [self getWholeText:txt forward:fwd node:NSIBLING(parent, fwd) parent:parent.parentNode]; return YES; }
        return NO;
        /*@f:1*/
    }

    -(NSString *)wholeText {
        PGDOMSyncData;

        if(_wholeText == nil) {
            NSMutableString *txt  = [NSMutableString new];
            PGDOMNode       *prnt = self.parentNode;
            NSString        *data = self.data;

            if(data.length) [txt appendString:data];

            if(prnt) {
                [self getWholeText:txt forward:NO node:self.previousSibling parent:prnt];
                [self getWholeText:txt forward:YES node:self.nextSibling parent:prnt];
            }

            _wholeText = txt;
        }

        return _wholeText;
    }

    -(instancetype)replaceWholeTextWith:(NSString *)content {
        PGDOMSyncData;
        PGDOMCheckRO;
        PGDOMNode *parent      = self.parentNode;
        PGDOMText *currentNode = nil;

        if(content.length == 0) {
            [parent removeChild:self];
            return nil;
        }

        if(!(self.canModifyPrev && self.canModifyNext)) @throw [self createNoModException];

        if(self.isReadOnly) {
            PGDOMText *node = [self.ownerDocument createTextNode:content];

            if(parent) {
                [parent insertChild:node before:self];
                [parent removeChild:self];
                currentNode = node;
            }
            else return node;
        }
        else {
            self.data = content;
            currentNode = self;
        }

        self.needsSyncData = YES;
        [self         performAction:^PGDOMNode *(PGDOMNode *n, PGDOMNode *o, BOOL f) {
            [n.parentNode removeChild:n];
            return o;
        } onTextNodesAdjacentToNode:currentNode];

        return currentNode;
    }

    -(void)performAction:(PGDOMNodeAction)blkAction onTextNodesAdjacentToNode:(PGDOMNode *)node goingForward:(BOOL)fwd {
        PGDOMNode *sibling = NSIBLING(node, fwd);

        while(sibling) {
            if(sibling.isTextNode || (sibling.isEntityReference && sibling.hasTextOnlyChildren)) sibling = blkAction(sibling, node, fwd); else break;
            sibling = NSIBLING(sibling, fwd);
        }
    }

    -(void)performAction:(PGDOMNodeAction)action onTextNodesAdjacentToNode:(PGDOMNode *)node {
        [self performAction:action onTextNodesAdjacentToNode:node goingForward:NO];
        [self performAction:action onTextNodesAdjacentToNode:node goingForward:YES];
    }

    -(instancetype)splitTextAtOffset:(NSUInteger)offset {
        PGDOMSyncData;
        PGDOMCheckRO;
        NSString *data = self.data;

        if(offset > data.length) @throw [self createIndexOutOfBoundsException];

        self.data = [data substringToIndex:offset];
        PGDOMText *text = [self.ownerDocument createTextNode:[data substringFromIndex:offset] ofType:self.nodeType];
        [self.parentNode insertChild:text before:self.nextSibling];

        self.needsSyncData = YES;
        return text;
    }

    -(void)synchronizeData {
        _wholeText = nil;
        [super synchronizeData];
    }

    -(void)setData:(NSString *)data {
        PGDOMSyncData;
        PGDOMCheckRO;
        [super setData:data];
        self.needsSyncData = YES;

        PGDOMNodeAction a = ^PGDOMNode *(PGDOMNode *n, PGDOMNode *o, BOOL f) {
            n.needsSyncData = YES;
            return n;
        };

        [self performAction:a onTextNodesAdjacentToNode:self];
    }

    -(NSString *)textContent {
        return self.data;
    }

    -(void)setTextContent:(NSString *)textContent {
        self.data = textContent;
    }


@end
