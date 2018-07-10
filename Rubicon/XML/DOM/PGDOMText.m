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

#import "PGDOMText.h"
#import "PGDOMPrivate.h"

@implementation PGDOMText {
        BOOL     _isElementContentWhitespace;
        NSString *_wholeText;
    }

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument data:(NSString *)data {
        self = [super initWithNodeType:PGDOMNodeTypeText ownerDocument:ownerDocument data:data];

        if(self) {
        }

        return self;
    }

    -(BOOL)isElementContentWhitespace {
        PGDOMSyncData;
        return _isElementContentWhitespace;
    }

    -(BOOL)canModifyNext:(PGDOMNode *)node {
        BOOL      textFirstChild = NO;
        PGDOMNode *next          = node.nextSibling;

        while(next) {
            switch(next.nodeType) {
                case PGDOMNodeTypeEntityReference: {
                    PGDOMNode *firstChild = next.firstChild;
                    if(!firstChild) return NO;

                    while(firstChild) {
                        switch(firstChild.nodeType) {
                            case PGDOMNodeTypeEntityReference:
                                if(![self canModifyNext:firstChild]) return NO;
                            case PGDOMNodeTypeText:
                            case PGDOMNodeTypeCDataSection:
                                textFirstChild = YES;
                                break;
                            default:
                                return !textFirstChild;
                        }

                        firstChild = firstChild.nextSibling;
                    }
                }
                case PGDOMNodeTypeText:
                case PGDOMNodeTypeCDataSection:
                    break;
                default:
                    return YES;
            }
            next = next.nextSibling;
        }
        return YES;
    }

    -(BOOL)canModifyPrev:(PGDOMNode *)node {
        BOOL      textLastChild = NO;
        PGDOMNode *prev         = node.previousSibling;

        while(prev) {
            switch(prev.nodeType) {
                case PGDOMNodeTypeEntityReference: {
                    PGDOMNode *lastChild = prev.lastChild;
                    if(!lastChild) return NO;

                    while(lastChild) {
                        switch(lastChild.nodeType) {
                            case PGDOMNodeTypeEntityReference:
                                if(![self canModifyPrev:lastChild]) return NO;
                            case PGDOMNodeTypeText:
                            case PGDOMNodeTypeCDataSection:
                                textLastChild = YES;
                                break;
                            default:
                                return !textLastChild;
                        }

                        lastChild = lastChild.previousSibling;
                    }
                }
                case PGDOMNodeTypeText:
                case PGDOMNodeTypeCDataSection:
                    break;
                default:
                    return YES;
            }

            prev = prev.previousSibling;
        }

        return YES;
    }

    -(BOOL)hasTextOnlyChildren:(PGDOMNode *)node {
        PGDOMNode *child = node;

        if(child) {
            child = child.firstChild;

            while(child) {
                switch(child.nodeType) {
                    case PGDOMNodeTypeEntityReference:
                        if(![self hasTextOnlyChildren:child]) return NO;
                    case PGDOMNodeTypeCDataSection:
                    case PGDOMNodeTypeText:
                        break;
                    default:
                        return NO;
                }

                child = child.nextSibling;
            }

            return YES;
        }

        return NO;
    }

    -(BOOL)getWholeTextBackward:(NSMutableString *)wholeText node:(PGDOMNode *)node parent:(PGDOMNode *)parent {
        while(node) {
            switch(node.nodeType) {
                case PGDOMNodeTypeEntityReference:
                    if([self getWholeTextBackward:wholeText node:node.lastChild parent:node]) return YES;
                    break;
                case PGDOMNodeTypeText:
                case PGDOMNodeTypeCDataSection:
                    if(node.nodeValue.length) [wholeText insertString:node.nodeValue atIndex:0];
                    break;
                default:
                    return YES;
            }

            node = node.previousSibling;
        }

        if(parent.nodeType == PGDOMNodeTypeEntityReference) {
            [self getWholeTextBackward:wholeText node:parent.previousSibling parent:parent.parentNode];
            return YES;
        }

        return NO;
    }

    -(BOOL)getWholeTextForward:(NSMutableString *)wholeText node:(PGDOMNode *)node parent:(PGDOMNode *)parent {
        while(node) {
            switch(node.nodeType) {
                case PGDOMNodeTypeEntityReference:
                    if([self getWholeTextForward:wholeText node:node.firstChild parent:node]) return YES;
                    break;
                case PGDOMNodeTypeText:
                case PGDOMNodeTypeCDataSection:
                    if(node.nodeValue.length) [wholeText appendString:node.nodeValue];
                    break;
                default:
                    return YES;
            }

            node = node.nextSibling;
        }

        if(parent.nodeType == PGDOMNodeTypeEntityReference) {
            [self getWholeTextForward:wholeText node:parent.nextSibling parent:parent.parentNode];
            return YES;
        }

        return NO;
    }

    -(NSString *)wholeText {
        PGDOMSyncData;

        if(_wholeText == nil) {
            NSMutableString *wholeText = [NSMutableString new];
            PGDOMNode       *parent    = self.parentNode;
            NSString        *data      = self.data;

            if(data.length) [wholeText appendString:data];

            if(parent) {
                [self getWholeTextBackward:wholeText node:self.previousSibling parent:parent];
                [self getWholeTextForward:wholeText node:self.nextSibling parent:parent];
            }

            _wholeText = wholeText;
        }

        return _wholeText;
    }

    -(instancetype)replaceWholeTextWith:(NSString *)content {
        PGDOMSyncData;
        self.needsSyncData = YES;
        return nil;
    }

    -(instancetype)splitTextAtOffset:(NSUInteger)offset {
        if(self.isReadOnly) @throw [NSException exceptionWithName:PGDOMException reason:PGErrorMsgNoModificationAllowed];
        PGDOMSyncData;
        NSString *data = self.data;

        if(offset > data.length) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGErrorMsgIndexOutOfBounds];

        self.data = [data substringToIndex:offset];
        PGDOMText *text = [self.ownerDocument createTextNode:[data substringFromIndex:offset]];
        [self.parentNode insertChild:text before:self.nextSibling];
        self.needsSyncData = YES;
        return text;
    }

    -(void)synchronizeData {
        _wholeText = nil;
        [super synchronizeData];
    }

@end
