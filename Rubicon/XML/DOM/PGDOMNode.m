/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMNode.m
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

@implementation PGDOMNode {
        PGDOMNodeList<PGDOMNode *>     *_childNodes;
        PGDOMNamedNodeMap<PGDOMAttr *> *_attributes;
    }

    @synthesize nodeType = _nodeType;
    @synthesize parentNode = _parentNode;
    @synthesize previousSibling = _previousSibling;
    @synthesize nextSibling = _nextSibling;
    @synthesize ownerDocument = _ownerDocument;

    -(instancetype)init {
        self = [super init];

        if(self) {
            PGBadConstructorError;
        }

        return self;
    }

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType ownerDocument:(PGDOMDocument *)ownerDocument {
        self = [super init];

        if(self) {
            PGAbstractClassTest(PGDOMNode);
            _nodeType      = nodeType;
            _ownerDocument = ownerDocument;
            if((_ownerDocument == nil) && (self.class != PGDOMDocument.class))
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGDOMErrorMsgOwnerDocumentNull];
        }

        return self;
    }

    -(NSString *)nodeName {
        switch(self.nodeType) {
            case PGDOMNodeTypeCDataSection:
                return PGDOMNodeNameCDataSection;
            case PGDOMNodeTypeComment:
                return PGDOMNodeNameComment;
            case PGDOMNOdeTypeDocumentFragment:
                return PGDOMNodeNameDocumentFragment;
            case PGDOMNodeTypeDocument:
                return PGDOMNodeNameDocument;
            case PGDOMNodeTypeText:
                return PGDOMNodeNameText;
            default:
                return PGDOMNodeNameUnknown;
        }
    }

    -(NSString *)nodeTypeDescription {
        switch(self.nodeType) {
            case PGDOMNodeTypeAttribute:
                return PGDOMNodeTypeDescAttribute;
            case PGDOMNodeTypeCDataSection:
                return PGDOMNodeTypeDescCData;
            case PGDOMNodeTypeComment:
                return PGDOMNodeTypeDescComment;
            case PGDOMNOdeTypeDocumentFragment:
                return PGDOMNodeTypeDescDocumentFragment;
            case PGDOMNodeTypeDocument:
                return PGDOMNodeTypeDescDocument;
            case PGDOMNodeTypeDTD:
                return PGDOMNodeTypeDescDTD;
            case PGDOMNodeTypeElement:
                return PGDOMNodeTypeDescElement;
            case PGDOMNodeTypeEntity:
                return PGDOMNodeTypeDescEntity;
            case PGDOMNodeTypeEntityReference:
                return PGDOMNodeTypeDescEntityReference;
            case PGDOMNodeTypeNotation:
                return PGDOMNodeTypeDescNotation;
            case PGDOMNodeTypeProcessingInstruction:
                return PGDOMNodeTypeDescProcessingInstruction;
            case PGDOMNodeTypeText:
                return PGDOMNodeTypeDescText;
            default:
                return nil;
        }
    }

    -(NSString *)nodeValue {
        return nil;
    }

    -(void)setNodeValue:(NSString *)nodeValue {
    }

    -(NSString *)localName {
        return nil;
    }

    -(NSString *)prefix {
        return nil;
    }

    -(void)setPrefix:(NSString *)prefix {
    }

    -(NSString *)namespaceURI {
        return nil;
    }

    -(NSString *)baseURI {
        return nil;
    }

    -(NSString *)textContent {
        return nil;
    }

    -(void)setTextContent:(NSString *)textContent {
    }

    -(PGDOMNode *)firstChild {
        return nil;
    }

    -(PGDOMNode *)lastChild {
        return nil;
    }

    -(PGDOMNode *)appendChild:(PGDOMNode *)newNode {
        return nil;
    }

    -(PGDOMNode *)insertChild:(PGDOMNode *)newNode before:(PGDOMNode *)refNode {
        return nil;
    }

    -(PGDOMNode *)replaceChild:(PGDOMNode *)oldNode with:(PGDOMNode *)newNode {
        return nil;
    }

    -(PGDOMNode *)removeChild:(PGDOMNode *)oldNode {
        return nil;
    }

    -(void)grandchildListChanged {
        [self.parentNode grandchildListChanged];
    }

    -(PGDOMNodeList<PGDOMNode *> *)childNodes {
        PGSETIFNIL(self, _childNodes, [[PGDOMNodeList alloc] initWithOwnerNode:self]);
        return _childNodes;
    }

    -(PGDOMNamedNodeMap<PGDOMAttr *> *)attributes {
        PGSETIFNIL(self, _attributes, [self createNewAttributeMap]);
        return _attributes;
    }

    -(PGDOMNamedNodeMap<PGDOMAttr *> *)createNewAttributeMap {
        return [[PGDOMNamedNodeMap alloc] initWithOwnerNode:self];
    }


@end
