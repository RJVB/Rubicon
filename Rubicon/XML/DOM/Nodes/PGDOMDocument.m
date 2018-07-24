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

NSString *const PGDOMErrorMsgOpNotSupported = @"Operation Not Supported.";

@interface PGDOMNode(PGDOMDocument)

    -(void)setOwnerDocument:(PGDOMDocument *)document;

@end

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

    -(PGDOMElement *)createElementWithTagName:(NSString *)tagName {
        return [[PGDOMElement alloc] initWithOwnerDocument:self tagName:tagName];
    }

    -(PGDOMElement *)createElementWithQualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI {
        return [[PGDOMElement alloc] initWithOwnerDocument:self qualifiedName:qualifiedName namespaceURI:namespaceURI];
    }

    -(PGDOMComment *)createComment:(NSString *)content {
        return [[PGDOMComment alloc] initWithOwnerDocument:self data:content];
    }

    -(PGDOMProcessingInstruction *)createProcessingInstruction:(NSString *)target data:(NSString *)data {
        return [[PGDOMProcessingInstruction alloc] initWithOwnerDocument:self target:target data:data];
    }

    -(void)_adoptNode:(PGDOMNode *)node {
        if(node.ownerDocument) [node.parentNode removeChild:node];
        node.ownerDocument = self;
        [node postUserDataOperation:PGDOMNodeAdopted dest:nil];
    }

    -(void)_adoptNodeRecursively:(PGDOMNode *)node {
        [self _adoptNode:node];
        NSArray<PGDOMNode *> *children = node.allChildNodes;

        for(PGDOMNode *child in children) [self adoptNode:child];
        for(PGDOMNode *child in children) [node appendChild:child];
    }

    -(PGDOMNode *)adoptNode:(PGDOMNode *)node {
        if(node) {
            switch(node.nodeType) {
                case PGDOMNodeTypeAttribute:
                case PGDOMNodeTypeElement:
                case PGDOMNodeTypeDocumentFragment:
                case PGDOMNodeTypeProcessingInstruction:
                case PGDOMNodeTypeCDataSection:
                case PGDOMNodeTypeComment:
                case PGDOMNodeTypeText:
                    [self _adoptNodeRecursively:node];
                    break;
                case PGDOMNodeTypeEntityReference:
                    [self _adoptNode:node];
                    break;
                case PGDOMNodeTypeDTDNotation:
                case PGDOMNodeTypeDTDEntity:
                    return nil;
                case PGDOMNodeTypeDTD:
                case PGDOMNodeTypeDocument:
                    @throw [NSException exceptionWithName:PGDOMException reason:PGDOMErrorMsgOpNotSupported];
            }
        }

        return node;
    }

@end
