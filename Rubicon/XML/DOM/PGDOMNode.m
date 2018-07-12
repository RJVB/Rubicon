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
        PGDOMNodeTypes                 _nodeType;
        PGDOMNode                      *_parentNode;
        PGDOMNode                      *_previousSibling;
        PGDOMNode                      *_nextSibling;
        PGDOMDocument                  *_ownerDocument;
        BOOL                           _isReadOnly;
    }

    @synthesize needsSyncData = _needsSyncData;

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
            _isReadOnly    = YES;
            _needsSyncData = YES;

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
            case PGDOMNodeTypeDocumentFragment:
                return PGDOMNodeNameDocumentFragment;
            case PGDOMNodeTypeDocument:
                return PGDOMNodeNameDocument;
            case PGDOMNodeTypeText:
                return PGDOMNodeNameText;
            default:
                return PGDOMNodeNameUnknown;
        }
    }

    +(NSString *)nodeTypeDescription:(PGDOMNodeTypes)ntype {
        switch(ntype) {
            case PGDOMNodeTypeAttribute:
                return PGDOMNodeTypeDescAttribute;
            case PGDOMNodeTypeCDataSection:
                return PGDOMNodeTypeDescCData;
            case PGDOMNodeTypeComment:
                return PGDOMNodeTypeDescComment;
            case PGDOMNodeTypeDocumentFragment:
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

    -(NSString *)nodeTypeDescription {
        return [PGDOMNode nodeTypeDescription:self.nodeType];
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
        PGDOMSyncData;
        PGDOMNodeTypes t = self.nodeType;
        return ((t == PGDOMNodeTypeCDataSection) || (t == PGDOMNodeTypeText));
    }

    -(BOOL)isEntityReference {
        PGDOMSyncData;
        return (self.nodeType == PGDOMNodeTypeEntityReference);
    }

    -(BOOL)needsOwnerDocument {
        PGDOMSyncData;
        PGDOMNodeTypes t = self.nodeType;
        return ((t != PGDOMNodeTypeDocument) && (t != PGDOMNodeTypeDocumentFragment));
    }

    -(void)synchronizeData {
        _needsSyncData = NO;
    }

    -(BOOL)hasTextOnlyChildren {
        PGDOMProcBlk a = ^BOOL(PGDOMNode *n, NSInteger *rv, BOOL f) { return !n.hasTextOnlyChildren; };
        PGDOMProcBlk b = ^BOOL(PGDOMNode *n, NSInteger *rv, BOOL f) { return NO; };
        PGDOMProcBlk c = ^BOOL(PGDOMNode *n, NSInteger *rv, BOOL f) { return YES; };

        PGDOMSyncData;
        return (BOOL)[self textProc:self.firstChild forward:YES blkEntRef:a blkText:b blkDefault:c defRetVal:NO endRetVal:YES];
    }

    -(BOOL)canModify:(BOOL)fwd {
        __block BOOL tc = NO;
        PGDOMProcBlk a  = ^BOOL(PGDOMNode *n1, NSInteger *rv1, BOOL f1) {
            PGDOMProcBlk d = ^BOOL(PGDOMNode *n2, NSInteger *rv2, BOOL f2) { return !((BOOL)([n2 canModify:f2] ? (tc = YES) : (*rv1 = NO))); };
            PGDOMProcBlk e = ^BOOL(PGDOMNode *n2, NSInteger *rv2, BOOL f2) { return !(tc = YES); };
            PGDOMProcBlk f = ^BOOL(PGDOMNode *n2, NSInteger *rv2, BOOL f2) { return ((*rv1 = !tc) || YES); };

            return (BOOL)[self textProc:NCHILD(n1, f1) forward:f1 blkEntRef:d blkText:e blkDefault:f defRetVal:YES endRetVal:NO];
        };
        PGDOMProcBlk b  = ^BOOL(PGDOMNode *n, NSInteger *rv, BOOL f) { return NO; };
        PGDOMProcBlk c  = ^BOOL(PGDOMNode *n, NSInteger *rv, BOOL f) { return YES; };

        PGDOMSyncData;
        return (BOOL)[self textProc:NSIBLING(self, fwd) forward:fwd blkEntRef:a blkText:b blkDefault:c defRetVal:YES endRetVal:YES];
    }

    -(BOOL)canModifyPrev {
        return [self canModify:NO];
    }

    -(BOOL)canModifyNext {
        return [self canModify:YES];
    }

    -(NSInteger)textProc:(PGDOMNode *)n
                 forward:(BOOL)fwd
               blkEntRef:(PGDOMProcBlk)blkEntRef
                 blkText:(PGDOMProcBlk)blkText
                blkCData:(PGDOMProcBlk)blkCData
              blkDefault:(PGDOMProcBlk)blkDefault
               defRetVal:(NSInteger)x
               endRetVal:(NSInteger)y {
        return [self nodeProc:n
                      forward:fwd
                    blkEntRef:blkEntRef
                     blkCData:blkCData
                      blkText:blkText
                      blkAttr:nil
                   blkElement:nil
                   blkComment:nil
                  blkNotation:nil
                  blkProcInst:nil
                  blkDocument:nil
                   blkDocFrag:nil
                       blkDTD:nil
                    blkEntity:nil
                   blkDefault:blkDefault
                    defRetVal:x
                    endRetVal:y];
    }

    -(NSInteger)textProc:(PGDOMNode *)n
                 forward:(BOOL)fwd
               blkEntRef:(PGDOMProcBlk)blkEntRef
                 blkText:(PGDOMProcBlk)blkText
              blkDefault:(PGDOMProcBlk)blkDefault
               defRetVal:(BOOL)x
               endRetVal:(BOOL)y {
        return [self textProc:n forward:fwd blkEntRef:blkEntRef blkText:blkText blkCData:blkText blkDefault:blkDefault defRetVal:x endRetVal:y];
    }

    -(NSInteger)nodeProc:(PGDOMNode *)n
                 forward:(BOOL)fwd blkEntRef:(PGDOMProcBlk)blkEntRef blkCData:(PGDOMProcBlk)blkCData blkText:(PGDOMProcBlk)blkText
                 blkAttr:(PGDOMProcBlk)blkAttr blkElement:(PGDOMProcBlk)blkElement
              blkComment:(PGDOMProcBlk)blkComment blkNotation:(PGDOMProcBlk)blkNotation blkProcInst:(PGDOMProcBlk)blkProcInst
             blkDocument:(PGDOMProcBlk)blkDocument blkDocFrag:(PGDOMProcBlk)blkDocFrag
                  blkDTD:(PGDOMProcBlk)blkDTD
               blkEntity:(PGDOMProcBlk)blkEntity
              blkDefault:(PGDOMProcBlk)blkDefault
               defRetVal:(NSInteger)x
               endRetVal:(NSInteger)y {
        NSInteger    rv = x;
        PGDOMProcBlk dd = ^BOOL(PGDOMNode *n, NSInteger *rv, BOOL f) { return NO; };

        if(!blkDefault) blkDefault = dd;

        while(n) {
            switch(n.nodeType) { /*@f:0*/
                case PGDOMNodeTypeEntityReference:       if((blkEntRef   ?: blkDefault)(n, &rv, fwd)) return rv; break;
                case PGDOMNodeTypeCDataSection:          if((blkCData    ?: blkDefault)(n, &rv, fwd)) return rv; break;
                case PGDOMNodeTypeText:                  if((blkText     ?: blkDefault)(n, &rv, fwd)) return rv; break;
                case PGDOMNodeTypeAttribute:             if((blkAttr     ?: blkDefault)(n, &rv, fwd)) return rv; break;
                case PGDOMNodeTypeElement:               if((blkElement  ?: blkDefault)(n, &rv, fwd)) return rv; break;
                case PGDOMNodeTypeComment:               if((blkComment  ?: blkDefault)(n, &rv, fwd)) return rv; break;
                case PGDOMNodeTypeNotation:              if((blkNotation ?: blkDefault)(n, &rv, fwd)) return rv; break;
                case PGDOMNodeTypeProcessingInstruction: if((blkProcInst ?: blkDefault)(n, &rv, fwd)) return rv; break;
                case PGDOMNodeTypeDocument:              if((blkDocument ?: blkDefault)(n, &rv, fwd)) return rv; break;
                case PGDOMNodeTypeDocumentFragment:      if((blkDocFrag  ?: blkDefault)(n, &rv, fwd)) return rv; break;
                case PGDOMNodeTypeDTD:                   if((blkDTD      ?: blkDefault)(n, &rv, fwd)) return rv; break;
                case PGDOMNodeTypeEntity:                if((blkEntity   ?: blkDefault)(n, &rv, fwd)) return rv; break;
                default:                                 if(                 blkDefault(n, &rv, fwd)) return rv; break; /*@f:1*/
            }

            n = NSIBLING(n, fwd);
        }

        return y;
    }

    -(NSException *)createNoModificationException {
        return [NSException exceptionWithName:PGDOMException reason:PGErrorMsgNoModificationAllowed];
    }

    -(PGDOMNodeTypes)nodeType {
        PGDOMSyncData;
        return _nodeType;
    }

    -(PGDOMNode *)parentNode {
        PGDOMSyncData;
        return _parentNode;
    }

    -(PGDOMNode *)previousSibling {
        PGDOMSyncData;
        return _previousSibling;
    }

    -(PGDOMNode *)nextSibling {
        PGDOMSyncData;
        return _nextSibling;
    }

    -(PGDOMDocument *)ownerDocument {
        PGDOMSyncData;
        return _ownerDocument;
    }

    -(BOOL)isReadOnly {
        PGDOMSyncData;
        return _isReadOnly;
    }

    -(void)setParentNode:(PGDOMNode *)parentNode {
        PGDOMSyncData;
        _parentNode    = parentNode;
        _needsSyncData = YES;
    }

    -(void)setPreviousSibling:(PGDOMNode *)previousSibling {
        PGDOMSyncData;
        _previousSibling = previousSibling;
        _needsSyncData   = YES;
    }

    -(void)setNextSibling:(PGDOMNode *)nextSibling {
        PGDOMSyncData;
        _nextSibling   = nextSibling;
        _needsSyncData = YES;
    }

    -(void)setIsReadOnly:(BOOL)isReadOnly {
        PGDOMSyncData;
        _isReadOnly    = isReadOnly;
        _needsSyncData = YES;
    }

@end
