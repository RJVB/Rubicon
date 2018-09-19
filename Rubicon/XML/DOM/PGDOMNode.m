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
    @synthesize userData = _userData;

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

            if((_ownerDocument == nil) && self.needsOwnerDocument) {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGDOMErrorMsgOwnerDocumentNull];
            }
        }

        return self;
    }

    -(NSString *)nodeName {
        switch(self.nodeType) {/*@f:0*/
             case PGDOMNodeTypeCDataSection:     return PGDOMNodeNameCDataSection;
             case PGDOMNodeTypeComment:          return PGDOMNodeNameComment;
             case PGDOMNodeTypeDocumentFragment: return PGDOMNodeNameDocumentFragment;
             case PGDOMNodeTypeDocument:         return PGDOMNodeNameDocument;
             case PGDOMNodeTypeText:             return PGDOMNodeNameText;
             default:                            return PGDOMNodeNameUnknown;
          /*@f:1*/}
    }

    +(NSString *)nodeTypeDescription:(PGDOMNodeTypes)ntype {
        switch(ntype) {/*@f:0*/
             case PGDOMNodeTypeAttribute:             return PGDOMNodeTypeDescAttribute;
             case PGDOMNodeTypeCDataSection:          return PGDOMNodeTypeDescCData;
             case PGDOMNodeTypeComment:               return PGDOMNodeTypeDescComment;
             case PGDOMNodeTypeDocumentFragment:      return PGDOMNodeTypeDescDocumentFragment;
             case PGDOMNodeTypeDocument:              return PGDOMNodeTypeDescDocument;
             case PGDOMNodeTypeDTD:                   return PGDOMNodeTypeDescDTD;
             case PGDOMNodeTypeElement:               return PGDOMNodeTypeDescElement;
             case PGDOMNodeTypeDTDEntity:             return PGDOMNodeTypeDescEntity;
             case PGDOMNodeTypeEntityReference:       return PGDOMNodeTypeDescEntityReference;
             case PGDOMNodeTypeDTDNotation:           return PGDOMNodeTypeDescNotation;
             case PGDOMNodeTypeProcessingInstruction: return PGDOMNodeTypeDescProcessingInstruction;
             case PGDOMNodeTypeText:                  return PGDOMNodeTypeDescText;
             default:                                 return nil;
          /*@f:1*/}
    }

    -(void)dealloc {
        [self postUserDataOperation:PGDOMNodeDeleted dest:nil];
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
        [self.parentNode grandchildListChanged];
    }

    -(PGDOMNodeList<PGDOMNode *> *)childNodes {
        PGDOMSyncData;
        PGSETIFNIL(self, self->_childNodes, [[PGDOMNodeList alloc] initWithOwnerNode:self]);
        return _childNodes;
    }

    -(PGDOMNamedNodeMap<PGDOMAttr *> *)attributes {
        PGDOMSyncData;
        PGSETIFNIL(self, self->_attributes, [self createNewAttributeMap]);
        return _attributes;
    }

    -(PGDOMNamedNodeMap<PGDOMAttr *> *)createNewAttributeMap {
        return [[PGDOMNamedNodeMap alloc] initWithOwnerNode:self];
    }

    -(BOOL)isTextNode {
        PGDOMNodeTypes t = self.nodeType;
        return ((t == PGDOMNodeTypeCDataSection) || (t == PGDOMNodeTypeText));
    }

    -(BOOL)isEntityReference {
        return (self.nodeType == PGDOMNodeTypeEntityReference);
    }

    -(BOOL)needsOwnerDocument {
        PGDOMNodeTypes t = self.nodeType;
        return ((t != PGDOMNodeTypeDocument) && (t != PGDOMNodeTypeDocumentFragment));
    }

    -(void)synchronizeData {
        _needsSyncData = NO;
    }

    -(NSException *)createNoModException {
        return [NSException exceptionWithName:PGDOMException reason:PGErrorMsgNoModificationAllowed];
    }

    -(NSException *)createInvArgException:(NSString *)reason {
        return [NSException exceptionWithName:NSInvalidArgumentException reason:reason];
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
        if(self.parentNode != parentNode) {
            PGDOMCheckRO;
            _parentNode    = parentNode;
            _needsSyncData = YES;
        }
    }

    -(void)setPreviousSibling:(PGDOMNode *)previousSibling {
        if(self.previousSibling != previousSibling) {
            PGDOMCheckRO;
            _previousSibling = previousSibling;
            _needsSyncData   = YES;
        }
    }

    -(void)setNextSibling:(PGDOMNode *)nextSibling {
        if(self.nextSibling != nextSibling) {
            PGDOMCheckRO;
            _nextSibling   = nextSibling;
            _needsSyncData = YES;
        }
    }

    -(void)setOwnerDocument:(PGDOMDocument *)document {
        if(self.ownerDocument != document) {
            _ownerDocument = document;
            _needsSyncData = YES;
        }
    }

    -(void)setIsReadOnly:(BOOL)isReadOnly {
        if(self.isReadOnly != isReadOnly) {
            _isReadOnly    = isReadOnly;
            _needsSyncData = YES;
        }
    }

    -(id)userDataForKey:(NSString *)key {
        PGDOMSyncData;
        if(key.notEmpty) return self.userData[key];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Key is either empty or null."];
    }

    -(id)setUserData:(id)data forKey:(NSString *)key handler:(PGDOMUserDataHandler *)handler {
        id oldData = [self userDataForKey:key];
        PGDOMCheckRO;

        if(data) {
            PGSETIFNIL(self, self->_userData, [NSMutableDictionary new]);
            self.userData[key] = [UserDataHolder holderWithKey:key data:data handler:handler];
        }
        else if(oldData) {
            [self.userData removeObjectForKey:key];
        }

        return oldData;
    }

    -(void)postUserDataOperation:(PGDOMUserDataOperations)operation dest:(PGDOMNode *)dest {
        PGDOMSyncData;
        PGDOMNode *src = ((operation == PGDOMNodeDeleted) ? nil : self);

        for(UserDataHolder *holder in self.userData.allValues) {
            PGDOMUserDataHandler *handler = holder.handler;
            if(handler) [handler handleOperation:operation key:holder.key data:holder.data src:src dest:dest];
        }
    }

    -(NSArray<PGDOMNode *> *)allChildNodes {
        static NSArray<PGDOMNode *> *_emptyNodeArray = nil;
        PGSETIFNIL([PGDOMNode class], _emptyNodeArray, [NSArray new]);
        return _emptyNodeArray;
    }

    -(void)setAllChildNodes:(NSArray<PGDOMNode *> *)childNodes {
    }

    -(void)removeAllChildren:(nullable NSMutableArray<PGDOMNode *> *)removedNodes {
    }

    -(void)removeAllChildren {
        NSString *aString = @"Bob";

        PGSWITCH(aString);
            PGCASE(@"Sue");
                /* Do something. */
                break;
            PGCASE(@"Bob");
                /* Do something. */
                break;
            PGDEFAULT;
                /* Do something if none of the above. */
                break;
        PGSWITCHEND;

        if([aString isEqualToString:@"Sue"]) {
            /* Do something. */
        }
        else if([aString isEqualToString:@"Bob"]) {
            /* Do something. */
        }
        else {
            /* Do something if none of the above. */
        }
    }

    -(void)appendAllChildNodes:(NSArray<PGDOMNode *> *)childNodes {
    }

    -(void)insertAllChildNodes:(NSArray<PGDOMNode *> *)childNodes before:(PGDOMNode *)refNode {
    }

    -(BOOL)isDocumentFragment {
        return (self.nodeType == PGDOMNodeTypeDocumentFragment);
    }

    -(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained _Nullable[_Nonnull])buffer count:(NSUInteger)len {
        return 0;
    }

    -(NSEnumerator<PGDOMNode *> *)childNodeEnumerator {
        return [[PGEmptyEnumerator alloc] init];
    }

    -(PGDOMNode *)removeFromParent {
        PGDOMNode *parent = self.parentNode;
        if(parent) [parent removeChild:self];
        return parent;
    }

    -(BOOL)hasNamespace {
        return (self.namespaceURI.nullIfTrimEmpty != nil);
    }


@end
