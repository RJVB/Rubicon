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
        BOOL                           _needsSyncData;
    }

    @synthesize nodeType = _nodeType;
    @synthesize parentNode = _parentNode;
    @synthesize previousSibling = _previousSibling;
    @synthesize nextSibling = _nextSibling;
    @synthesize ownerDocument = _ownerDocument;
    @synthesize isReadOnly = _isReadOnly;

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
            _isReadOnly    = NO;
            _needsSyncData = NO;

            if((_ownerDocument == nil) && self.needsOwnerDocument) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGDOMErrorMsgOwnerDocumentNull];
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
        PGDOMSyncData;
        [self.parentNode grandchildListChanged];
    }

    -(PGDOMNodeList<PGDOMNode *> *)childNodes {
        PGDOMSyncData;
        PGSETIFNIL(self, _childNodes, [[PGDOMNodeList alloc] initWithOwnerNode:self]);
        return _childNodes;
    }

    -(PGDOMNamedNodeMap<PGDOMAttr *> *)attributes {
        PGDOMSyncData;
        PGSETIFNIL(self, _attributes, [self createNewAttributeMap]);
        return _attributes;
    }

    -(PGDOMNamedNodeMap<PGDOMAttr *> *)createNewAttributeMap {
        return [[PGDOMNamedNodeMap alloc] initWithOwnerNode:self];
    }

    -(BOOL)isTextNode {
        switch(self.nodeType) {
            case PGDOMNodeTypeCDataSection:
            case PGDOMNodeTypeText:
                return YES;
            default:
                return NO;
        }
    }

    -(BOOL)isEntityReference {
        return (self.nodeType == PGDOMNodeTypeEntityReference);
    }

    -(BOOL)needsOwnerDocument {
        switch(self.nodeType) {
            case PGDOMNodeTypeDocument:
            case PGDOMNOdeTypeDocumentFragment:
                return NO;
            default:
                return YES;
        }
    }

    -(BOOL)needsSyncData {
        return _needsSyncData;
    }

    -(void)setNeedsSyncData:(BOOL)needsSyncData {
        if(_needsSyncData != needsSyncData) {
            _needsSyncData = needsSyncData;

            if(needsSyncData) {
                self.previousSibling.needsSyncData = needsSyncData;
                self.nextSibling.needsSyncData     = needsSyncData;
                self.parentNode.needsSyncData      = needsSyncData;
            }
        }
    }

    -(void)synchronizeData {
        self.needsSyncData = NO;
    }

    -(BOOL)hasTextOnlyChildren {
        return (BOOL)[self textNodeProc:self.firstChild
                                forward:YES
                              entRefBlk:^BOOL(PGDOMNode *n, NSInteger *rv, BOOL f) { return !n.hasTextOnlyChildren; }
                            textNodeBlk:^BOOL(PGDOMNode *n, NSInteger *rv, BOOL f) { return NO; }
                             defaultBlk:^BOOL(PGDOMNode *n, NSInteger *rv, BOOL f) { return YES; }
                       startReturnValue:NO
                      finishReturnValue:YES];
    }

    -(BOOL)canModify:(BOOL)f {
        __block BOOL tc = NO;

        return [self textNodeProc:(f ? self.nextSibling : self.previousSibling)
                          forward:f
                        entRefBlk:^BOOL(PGDOMNode *n, NSInteger *rv, BOOL f) {
                            return (BOOL)[self textNodeProc:(f ? n.firstChild : n.lastChild)
                                                    forward:f
                                                  entRefBlk:^BOOL(PGDOMNode *n2, NSInteger *rv2, BOOL f2) { return !((BOOL)([n2 canModify:f2] ? (tc = YES) : (*rv = NO))); }
                                                textNodeBlk:^BOOL(PGDOMNode *n2, NSInteger *rv2, BOOL f2) { return !(tc = YES); }
                                                 defaultBlk:^BOOL(PGDOMNode *n2, NSInteger *rv2, BOOL f2) { return ((*rv = !tc) || YES); }
                                           startReturnValue:YES
                                          finishReturnValue:NO];
                        }
                      textNodeBlk:^BOOL(PGDOMNode *n, NSInteger *rv, BOOL f) { return NO; }
                       defaultBlk:^BOOL(PGDOMNode *n, NSInteger *rv, BOOL f) { return YES; }
                 startReturnValue:YES
                finishReturnValue:YES];
    }

    -(BOOL)canModifyPrev {
        return [self canModify:NO];
    }

    -(BOOL)canModifyNext {
        return [self canModify:YES];
    }

    -(NSInteger)textNodeProc:(PGDOMNode *)node
                     forward:(BOOL)forward
                   entRefBlk:(PGDOMNodeProcBlock)entRefBlk
                 textNodeBlk:(PGDOMNodeProcBlock)textNodeBlk
                cdataNodeBlk:(PGDOMNodeProcBlock)cdataNodeBlk
                  defaultBlk:(PGDOMNodeProcBlock)defaultBlk
            startReturnValue:(NSInteger)startReturnValue
           finishReturnValue:(NSInteger)finishReturnValue {
        NSInteger retValue = startReturnValue;

        while(node) {
            switch(node.nodeType) {
                case PGDOMNodeTypeEntityReference:
                    if(entRefBlk(node, &retValue, forward)) return retValue;
                    break;
                case PGDOMNodeTypeText:
                    if(textNodeBlk(node, &retValue, forward)) return retValue;
                    break;
                case PGDOMNodeTypeCDataSection:
                    if(cdataNodeBlk(node, &retValue, forward)) return retValue;
                    break;
                default:
                    if(defaultBlk(node, &retValue, forward)) return retValue;
                    break;
            }

            node = (forward ? node.nextSibling : node.previousSibling);
        }

        return finishReturnValue;
    }

    -(BOOL)textNodeProc:(PGDOMNode *)node
                forward:(BOOL)forward
              entRefBlk:(PGDOMNodeProcBlock)entRefBlk
            textNodeBlk:(PGDOMNodeProcBlock)textNodeBlk
             defaultBlk:(PGDOMNodeProcBlock)defaultBlk
       startReturnValue:(BOOL)startReturnValue
      finishReturnValue:(BOOL)finishReturnValue {
        return (BOOL)[self textNodeProc:node
                                forward:forward
                              entRefBlk:entRefBlk
                            textNodeBlk:textNodeBlk
                           cdataNodeBlk:textNodeBlk
                             defaultBlk:defaultBlk
                       startReturnValue:startReturnValue
                      finishReturnValue:finishReturnValue];
    }

@end
