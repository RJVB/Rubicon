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
#import "PGDOMNode.h"
#import "PGDOMParent.h"
#import "PGDOMNamespaceAware.h"
#import "PGDOMAttr.h"
#import "PGDOMElement.h"
#import "PGDOMNodeList.h"
#import "PGDOMNamedNodeMap.h"
#import "PGDOMNotifiedContainer.h"
#import "PGDOMNodeContainer.h"
#import "PGDOMAttributeMap.h"
#import "PGDOMNamedNodeMapImpl.h"
#import "PGDOMElementNodeList.h"
#import "PGDOMCharacterData.h"
#import "PGDOMText.h"

typedef PGMutableBinaryTreeDictionary<NSString *, PGDOMNode *>   *PGDOMNodeTree;
typedef PGMutableBinaryTreeDictionary<NSString *, PGDOMNodeTree> *PGDOMNodeNodeTree;

typedef BOOL (^PGDOMNodeProcBlock)(PGDOMNode *node, NSInteger *pRetValue, BOOL forward);

NS_ASSUME_NONNULL_BEGIN

#define PGDOMSyncData do{if(self.needsSyncData)[self synchronizeData];}while(0)

@interface PGDOMNode()

    @property(nonatomic, readonly, nullable) NSString  *nodeTypeDescription;
    @property(nonatomic, nullable) /*     */ PGDOMNode *parentNode;
    @property(nonatomic, nullable) /*     */ PGDOMNode *previousSibling;
    @property(nonatomic, nullable) /*     */ PGDOMNode *nextSibling;
    @property(nonatomic, readonly) /*     */ BOOL      isTextNode;
    @property(nonatomic, readonly) /*     */ BOOL      isEntityReference;
    @property(nonatomic) /*               */ BOOL      needsSyncData;
    @property(nonatomic, readonly) /*     */ BOOL      needsOwnerDocument;
    @property(nonatomic, readonly) /*     */ BOOL      hasTextOnlyChildren;
    @property(nonatomic, readonly) /*     */ BOOL      canModifyPrev;
    @property(nonatomic, readonly) /*     */ BOOL      canModifyNext;

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType ownerDocument:(nullable PGDOMDocument *)ownerDocument;

    -(PGDOMNamedNodeMap<PGDOMAttr *> *)createNewAttributeMap;

    -(void)grandchildListChanged;

    -(void)synchronizeData;

    -(NSInteger)childTextNodeProc:(BOOL)forward
                        entRefBlk:(PGDOMNodeProcBlock)entRefBlk
                      textNodeBlk:(PGDOMNodeProcBlock)textNodeBlk
                     cdataNodeBlk:(PGDOMNodeProcBlock)cdataNodeBlk
                       defaultBlk:(PGDOMNodeProcBlock)defaultBlk
                 startReturnValue:(NSInteger)startReturnValue
                finishReturnValue:(NSInteger)finishReturnValue;

    -(NSInteger)textNodeProc:(PGDOMNode *)node
                     forward:(BOOL)forward
                   entRefBlk:(PGDOMNodeProcBlock)entRefBlk
                 textNodeBlk:(PGDOMNodeProcBlock)textNodeBlk
                cdataNodeBlk:(PGDOMNodeProcBlock)cdataNodeBlk
                  defaultBlk:(PGDOMNodeProcBlock)defaultBlk
            startReturnValue:(NSInteger)startReturnValue
           finishReturnValue:(NSInteger)finishReturnValue;
@end

@interface PGDOMParent()

    -(NSException *)createException:(NSString *)reason;

    -(void)testNewChildNode:(PGDOMNode *)node;

    -(void)postChildListChangeNotification;

    -(void)grandchildListChanged;

@end

@interface PGDOMDocument()

    @property(nonatomic, readonly) NSNotificationCenter *notificationCenter;

@end

@interface PGDOMNamespaceAware()

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType
                      ownerDocument:(PGDOMDocument *)ownerDocument
                      qualifiedName:(NSString *)qualifiedName
                       namespaceURI:(NSString *)namespaceURI;

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType
                      ownerDocument:(PGDOMDocument *)ownerDocument
                          localName:(NSString *)localName
                             prefix:(NSString *)prefix
                       namespaceURI:(NSString *)namespaceURI;

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType ownerDocument:(PGDOMDocument *)ownerDocument nodeName:(NSString *)nodeName;

    -(NSException *)createException:(NSString *)reason;

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

    -(instancetype)initWithOwnerDocument:(PGDOMDocument *)ownerDocument
                            ownerElement:(PGDOMElement *)ownerElement
                                    name:(NSString *)name
                                   value:(NSString *)value
                             isSpecified:(BOOL)isSpecified
                                    isID:(BOOL)isID;

    -(instancetype)initWithOwnerDocument:(PGDOMDocument *)ownerDocument
                            ownerElement:(PGDOMElement *)ownerElement
                           qualifiedName:(NSString *)qualifiedName
                            namespaceURI:(NSString *)namespaceURI
                                   value:(NSString *)value
                             isSpecified:(BOOL)isSpecified
                                    isID:(BOOL)isID;

    -(instancetype)initWithOwnerDocument:(PGDOMDocument *)ownerDocument
                            ownerElement:(PGDOMElement *)ownerElement
                               localName:(NSString *)localName
                                  prefix:(NSString *)prefix
                            namespaceURI:(NSString *)namespaceURI
                                   value:(NSString *)value
                             isSpecified:(BOOL)isSpecified
                                    isID:(BOOL)isID;

@end

@interface PGDOMElement()

    -(instancetype)initWithOwnerDocument:(PGDOMDocument *)ownerDocument qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI;

    -(instancetype)initWithOwnerDocument:(PGDOMDocument *)ownerDocument localName:(NSString *)localName prefix:(NSString *)prefix namespaceURI:(NSString *)namespaceURI;

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

@end

@interface PGDOMText()

    -(instancetype)initWithOwnerDocument:(nullable PGDOMDocument *)ownerDocument data:(NSString *)data;

    -(BOOL)getWholeTextBackward:(NSMutableString *)wholeText node:(PGDOMNode *)node parent:(PGDOMNode *)parent;

    -(BOOL)getWholeTextForward:(NSMutableString *)wholeText node:(PGDOMNode *)node parent:(PGDOMNode *)parent;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGDOMPRIVATE_H
