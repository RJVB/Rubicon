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

typedef NS_ENUM(NSByte, PGDOMAdoptAction) {
    PGDOMAdoptActionNode, PGDOMAdoptActionParent, PGDOMAdoptActionElement, PGDOMAdoptActionNever, PGDOMAdoptActionInvalid
};

typedef PGDOMNode *(^PGDOMAdoptBlock)(PGDOMDocument *_document, PGDOMNode *_node, PGDOMAdoptAction _action);

PGDOMNode *_adopt(PGDOMDocument *document, PGDOMNode *node, PGDOMAdoptBlock block);

PGDOMNode *_adoptElement(PGDOMDocument *document, PGDOMElement *element);

PGDOMNode *_adoptParent(PGDOMDocument *document, PGDOMParent *parent);

PGDOMNode *_adoptNode(PGDOMDocument *document, PGDOMNode *node);

@interface PGDOMNode()

    @property(nonatomic, nullable) PGDOMDocument *ownerDocument;

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

    -(PGDOMNode *)adoptNode:(PGDOMNode *)node {
        return _adopt(self, node, ^PGDOMNode *(PGDOMDocument *_document, PGDOMNode *_node, PGDOMAdoptAction _action) {
            if(_node.nodeType == PGDOMNodeTypeAttribute) {
                [((PGDOMAttr *)_node).ownerElement removeAttributeNS:((PGDOMAttr *)_node)];
            }
            switch(_action) { /*@f:0*/
                case PGDOMAdoptActionNode:    [_node removeFromParent]; return _adoptNode(_document, _node);
                case PGDOMAdoptActionParent:  [_node removeFromParent]; return _adoptParent(_document, (PGDOMParent *)_node);
                case PGDOMAdoptActionElement: [_node removeFromParent]; return _adoptElement(_document, (PGDOMElement *)_node);
                case PGDOMAdoptActionNever:   return nil;
                case PGDOMAdoptActionInvalid:
                default: @throw [NSException exceptionWithName:PGDOMException reason:PGDOMErrorMsgOpNotSupported];
            /*@f:1*/ }
            return _node;
        });
    }

@end

PGDOMNode *_adoptNode(PGDOMDocument *document, PGDOMNode *node) {
    node.ownerDocument = document;
    [node postUserDataOperation:PGDOMNodeAdopted dest:nil];
    return node;
}

PGDOMNode *_adoptParent(PGDOMDocument *document, PGDOMParent *parent) {
    for(PGDOMNode *child in parent.allChildNodes) {
        _adopt(document, child, ^PGDOMNode *(PGDOMDocument *_document, PGDOMNode *_node, PGDOMAdoptAction _action) {
            switch(_action) { /*@f:0*/
                case PGDOMAdoptActionNode:    return _adoptNode(_document, _node);
                case PGDOMAdoptActionParent:  return _adoptParent(_document, (PGDOMParent *)_node);
                case PGDOMAdoptActionElement: return _adoptElement(_document, (PGDOMElement *)_node);
                case PGDOMAdoptActionNever:
                case PGDOMAdoptActionInvalid:
                default: [_node removeFromParent]; return nil;
            /*@f:1*/ }
        });
    }
    return _adoptNode(document, parent);
}

PGDOMNode *_adoptElement(PGDOMDocument *document, PGDOMElement *element) {
    for(PGDOMAttr *attr in element.attributes) {
        _adoptParent(document, attr);
    }
    return _adoptParent(document, element);
}

PGDOMNode *_adopt(PGDOMDocument *document, PGDOMNode *node, PGDOMAdoptBlock block) {
    if(node) {
        switch(node.nodeType) { /*@f:0*/
            case PGDOMNodeTypeElement:               return block(document, node, PGDOMAdoptActionElement);
            case PGDOMNodeTypeAttribute:             return block(document, node, PGDOMAdoptActionParent);
            case PGDOMNodeTypeDocumentFragment:      return block(document, node, PGDOMAdoptActionParent);
            case PGDOMNodeTypeProcessingInstruction: return block(document, node, PGDOMAdoptActionNode);
            case PGDOMNodeTypeCDataSection:          return block(document, node, PGDOMAdoptActionNode);
            case PGDOMNodeTypeComment:               return block(document, node, PGDOMAdoptActionNode);
            case PGDOMNodeTypeText:                  return block(document, node, PGDOMAdoptActionNode);
            case PGDOMNodeTypeEntityReference:       return block(document, node, PGDOMAdoptActionNode);
            case PGDOMNodeTypeDTDNotation:           return block(document, node, PGDOMAdoptActionNever);
            case PGDOMNodeTypeDTDEntity:             return block(document, node, PGDOMAdoptActionNever);
            case PGDOMNodeTypeDTD:                   return block(document, node, PGDOMAdoptActionInvalid);
            case PGDOMNodeTypeDocument:              return block(document, node, PGDOMAdoptActionInvalid);
            default:                                 return block(document, node, PGDOMAdoptActionInvalid);
        /*@f:1*/ }
    }

    return node;
}
