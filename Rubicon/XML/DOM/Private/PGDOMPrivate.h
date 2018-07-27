/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMPrivate.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/27/18
 *  VISIBILITY: Private
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

#ifndef RUBICON_PGDOMPRIVATE_H
#define RUBICON_PGDOMPRIVATE_H

#import "PGInternal.h"
#import "PGDOMDefines.h"

#import "PGDOMCharacterData.h"
#import "PGDOMImplementation.h"
#import "PGDOMImplementationList.h"
#import "PGDOMLocator.h"
#import "PGDOMNamedNodeMap.h"
#import "PGDOMNamespaceAware.h"
#import "PGDOMNode.h"
#import "PGDOMNodeContainer.h"
#import "PGDOMNodeList.h"
#import "PGDOMNotifiedContainer.h"
#import "PGDOMParent.h"
#import "PGDOMUserDataHandler.h"

#import "PGDOMAttributeMap.h"
#import "PGDOMElementNodeList.h"
#import "PGDOMNamedNodeMapImpl.h"
#import "PGDOMNodeEnumerator.h"

#import "PGDOMAttr.h"
#import "PGDOMCDataSection.h"
#import "PGDOMComment.h"
#import "PGDOMDocument.h"
#import "PGDOMDocumentFragment.h"
#import "PGDOMDTD.h"
#import "PGDOMDTDEntity.h"
#import "PGDOMDTDNotation.h"
#import "PGDOMElement.h"
#import "PGDOMEntityReference.h"
#import "PGDOMProcessingInstruction.h"
#import "PGDOMText.h"

@class UserDataHolder;

typedef PGMutableBinaryTreeDictionary<NSString *, PGDOMNode *>   *PGDOMNodeTree;
typedef PGMutableBinaryTreeDictionary<NSString *, PGDOMNodeTree> *PGDOMNodeNodeTree;

typedef BOOL      (^PGDOMProcBlk)(PGDOMNode *node, NSInteger *pRetValue, BOOL forward);

typedef PGDOMNode *(^PGDOMNodeAction)(PGDOMNode *node, PGDOMNode *other, BOOL forward);

NS_ASSUME_NONNULL_BEGIN

#define PGDOMSyncDataN(n) do{if((n).needsSyncData)[(n) synchronizeData];}while(0)
#define PGDOMSyncData     PGDOMSyncDataN(self)
#define PGDOMCheckNRO(n)  do{if((n).isReadOnly)@throw[(n) createNoModException];}while(0)
#define PGDOMCheckRO      PGDOMCheckNRO(self)
#define NSIBLING(n, f)    ((f)?(n.nextSibling):(n.previousSibling))
#define NCHILD(n, f)      ((f)?(n.firstChild):(n.lastChild))
#define NVALUE(n)         ((n).nodeValue?:@"")
#define FORSIBLING(n, v)  for(PGDOMNode *v = n; v != nil; v = v.nextSibling)
#define FORCHILD(p, v)    FORSIBLING(p.firstChild, v)

@interface PGDOMNode()

    @property(nonatomic, readonly, nullable) NSString  *nodeTypeDescription;
    @property(nonatomic, nullable) /*     */ PGDOMNode *parentNode;
    @property(nonatomic, nullable) /*     */ PGDOMNode *previousSibling;
    @property(nonatomic, nullable) /*     */ PGDOMNode *nextSibling;
    @property(nonatomic, readonly) /*     */ BOOL      isTextNode;
    @property(nonatomic, readonly) /*     */ BOOL      isDocumentFragment;
    @property(nonatomic, readonly) /*     */ BOOL      isEntityReference;
    @property(nonatomic) /*               */ BOOL      needsSyncData;
    @property(nonatomic, readonly) /*     */ BOOL      needsOwnerDocument;
    @property(nonatomic) /*               */ BOOL      isReadOnly;

    @property(nonatomic, readonly) /*     */ NSMutableDictionary<NSString *, UserDataHolder *> *userData;
    @property(nonatomic) /*               */ NSArray<PGDOMNode *>                              *allChildNodes;

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType ownerDocument:(nullable PGDOMDocument *)ownerDocument;

    -(PGDOMNamedNodeMap<PGDOMAttr *> *)createNewAttributeMap;

    -(void)grandchildListChanged;

    -(void)synchronizeData;

    +(NSString *)nodeTypeDescription:(PGDOMNodeTypes)ntype;

    -(NSException *)createNoModException;

    -(NSException *)createInvArgException:(NSString *)reason;

    -(void)removeAllChildren:(nullable NSMutableArray<PGDOMNode *> *)removedNodes;

    -(void)removeAllChildren;

    -(void)appendAllChildNodes:(NSArray<PGDOMNode *> *)childNodes;

    -(void)insertAllChildNodes:(NSArray<PGDOMNode *> *)childNodes before:(nullable PGDOMNode *)refNode;

@end

@interface PGDOMParent()

    -(void)testNewChildNode:(PGDOMNode *)node;

    -(void)postChildListChangeNotification;

    -(void)grandchildListChanged;

@end

@interface PGDOMDocument()

    @property(nonatomic, readonly) NSNotificationCenter *notificationCenter;

    -(PGDOMText *)createTextNode:(NSString *)content ofType:(PGDOMNodeTypes)nodeType;

@end

@interface PGDOMDocumentFragment()

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument;

@end

@interface PGDOMNamespaceAware()

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType
                      ownerDocument:(nullable PGDOMDocument *)ownerDocument
                      qualifiedName:(NSString *)qualifiedName
                       namespaceURI:(nullable NSString *)namespaceURI;

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType
                      ownerDocument:(nullable PGDOMDocument *)ownerDocument
                          localName:(NSString *)localName
                             prefix:(nullable NSString *)prefix
                       namespaceURI:(nullable NSString *)namespaceURI;

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType ownerDocument:(nullable PGDOMDocument *)ownerDocument nodeName:(NSString *)nodeName;

    +(NSRegularExpression *)validationRegex;

    -(void)validateCharacters:(NSString *)name;

    -(void)validateCharacters:(NSString *)localName prefix:(NSString *)prefix;

    -(void)validateNames;

    -(void)validateLocalName:(NSString *)lnm prefix:(NSString *)pfx namespaceURI:(NSString *)uri;

@end

@interface PGDOMAttr()

    @property(nonatomic) /*     */ BOOL         isSpecified;
    @property(nonatomic) /*     */ BOOL         isID;
    @property(nonatomic, nullable) PGDOMElement *ownerElement;

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument ownerElement:(nullable PGDOMElement *)ownerElement
                                    name:(NSString *)name
                                   value:(NSString *)value
                             isSpecified:(BOOL)isSpecified
                                    isID:(BOOL)isID;

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument
                            ownerElement:(nullable PGDOMElement *)ownerElement
                           qualifiedName:(NSString *)qualifiedName
                            namespaceURI:(nullable NSString *)namespaceURI
                                   value:(NSString *)value
                             isSpecified:(BOOL)isSpecified
                                    isID:(BOOL)isID;

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument
                            ownerElement:(nullable PGDOMElement *)ownerElement
                               localName:(NSString *)localName
                                  prefix:(nullable NSString *)prefix
                            namespaceURI:(nullable NSString *)namespaceURI
                                   value:(NSString *)value
                             isSpecified:(BOOL)isSpecified
                                    isID:(BOOL)isID;

@end

@interface PGDOMElement()

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument qualifiedName:(NSString *)qualifiedName namespaceURI:(nullable NSString *)namespaceURI;

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument
                               localName:(NSString *)localName
                                  prefix:(nullable NSString *)prefix
                            namespaceURI:(nullable NSString *)namespaceURI;

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument tagName:(NSString *)tagName;

    -(PGDOMNamedNodeMap<PGDOMAttr *> *)createNewAttributeMap;

    -(PGDOMAttr *)_setAttribute:(PGDOMAttr *)attr;

    -(PGDOMAttr *)_setAttributeNS:(PGDOMAttr *)attr;

@end

@interface PGDOMNotifiedContainer()

    @property(nonatomic, readonly, nullable) PGDOMNode                          *ownerNode;
    @property(nonatomic, readonly, nullable) PGDOMDocument                      *ownerDocument;
    @property(nonatomic, readonly) /*     */ NSNotificationCenter               *nc;
    @property(nonatomic, readonly) /*     */ NSMutableArray<NSNotificationName> *notificationNames;

    -(instancetype)initWithOwnerNode:(nullable PGDOMNode *)ownerNode notificationName:(NSNotificationName)notificationName;

    -(void)setupNotifications;

@end

@interface PGDOMNodeContainer<T:PGDOMNode *>()

    @property(nonatomic, readonly) NSMutableArray<T> *items;

    -(instancetype)init;

    -(instancetype)initWithOwnerNode:(nullable PGDOMNode *)ownerNode;

    -(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained _Nullable[_Nullable])buffer count:(NSUInteger)len;

    -(T)objectAtIndexedSubscript:(NSUInteger)idx;

@end

@interface PGDOMNodeList<T:PGDOMNode *>()

@end

@interface PGDOMElementNodeList()

    @property(nonatomic, readonly, nullable) NSString *tagName;
    @property(nonatomic, readonly, nullable) NSString *localName;
    @property(nonatomic, readonly, nullable) NSString *namespaceURI;

    -(instancetype)initWithOwnerNode:(PGDOMElement *)ownerNode tagName:(NSString *)tagName;

    -(instancetype)initWithOwnerNode:(PGDOMElement *)ownerNode localName:(NSString *)localName namespaceURI:(NSString *)namespaceURI;

    -(void)setupNotifications;

    -(void)setupNotifications2;

    -(void)nodeListChangeListener:(NSNotification *)notification;

    -(void)load:(NSMutableArray<PGDOMElement *> *)list from:(PGDOMElement *)parent byTagName:(NSString *)tagName;

    -(void)load:(NSMutableArray<PGDOMElement *> *)list from:(PGDOMElement *)parent byLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI;

@end

@interface PGDOMNamedNodeMap<T:PGDOMNode *>()

@end

@interface PGDOMNamedNodeMapImpl<T:PGDOMNode *>()

    @property(nonatomic, readonly) PGDOMNodeTree     nodeNameCache;
    @property(nonatomic, readonly) PGDOMNodeNodeTree localNameCache;

    -(void)clearCaches;

    -(nullable T)removeNode:(nullable T)node;

    -(nullable T)replaceNode:(nullable T)oldNode withNode:(T)newNode;

@end

@interface PGDOMAttributeMap()

@end

@interface PGDOMCharacterData()

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType ownerDocument:(nullable PGDOMDocument *)ownerDocument data:(NSString *)data;

    -(NSException *)createIndexOutOfBoundsException;

@end

@interface PGDOMText()

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument data:(NSString *)data;

@end

@interface PGDOMCDataSection()

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument data:(NSString *)data;

@end

@interface PGDOMEntityReference()

    @property(nonatomic, nullable) PGDOMDTDEntity *entity;
    @property(nonatomic, readonly) BOOL           hasOnlyTextChildren;

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument entity:(nullable PGDOMDTDEntity *)entity;

    -(BOOL)hasOnlyTextChildren:(PGDOMEntityReference *)parent;

@end

@interface PGDOMComment()

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument data:(NSString *)data;

@end

@interface PGDOMProcessingInstruction()

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument target:(NSString *)target data:(NSString *)data;

@end

@interface PGDOMDTDNotation()

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID;

@end

@interface PGDOMDTDEntity()

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument
                           inputEncoding:(nullable NSString *)inputEncoding
                            notationName:(nullable NSString *)notationName
                                publicID:(nullable NSString *)publicID
                                systemID:(nullable NSString *)systemID
                             xmlEncoding:(nullable NSString *)xmlEncoding
                              xmlVersion:(nullable NSString *)xmlVersion;

@end

@interface PGDOMDTD()

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument
                                    name:(nullable NSString *)name
                                publicID:(nullable NSString *)publicID
                                systemID:(nullable NSString *)systemID
                          internalSubset:(nullable NSString *)internalSubset
                                entities:(PGDOMNamedNodeMap<PGDOMDTDEntity *> *)entities
                               notations:(PGDOMNamedNodeMap<PGDOMDTDNotation *> *)notations;

@end

@interface PGDOMLocator()

    -(instancetype)initWithLineNumber:(NSUInteger)lineNumber
                         columnNumber:(NSUInteger)columnNumber
                           byteOffset:(NSUInteger)byteOffset
                          utf16Offset:(NSUInteger)utf16Offset relatedNode:(nullable PGDOMNode *)relatedNode uri:(nullable NSString *)uri;

@end

@interface PGDOMImplementation()

    -(instancetype)init;

@end

@interface PGDOMImplementationList()

    @property(nonatomic, readonly) NSMutableArray<PGDOMImplementation *> *list;

    -(instancetype)init;

    -(void)setObject:(PGDOMImplementation *)obj atIndexedSubscript:(NSUInteger)idx;

@end

@interface PGDOMBlockUserDataHandler()

    @property(nonatomic, copy) PGDOMUserDataHandlerBlock handler;

@end

@interface UserDataHolder : NSObject

    @property(nonatomic, nullable, copy) PGDOMUserDataHandler *handler;
    @property(nonatomic, copy) /*     */ NSString             *key;
    @property(nonatomic) /*           */ id                   data;

    -(instancetype)initWithKey:(NSString *)key data:(id)data handler:(nullable PGDOMUserDataHandler *)handler;

    +(instancetype)holderWithKey:(NSString *)key data:(id)data handler:(nullable PGDOMUserDataHandler *)handler;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGDOMPRIVATE_H
