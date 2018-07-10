/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMElementNodeList.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 7/6/18
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

#import "PGDOMElementNodeList.h"
#import "PGDOMPrivate.h"

NS_INLINE BOOL _compare(NSString *given, NSString *found) {
    return ([given isEqualToString:@"*"] || PGStringsEqual(given, found));
}

@implementation PGDOMElementNodeList {
    }

    @synthesize tagName = _tagName;
    @synthesize localName = _localName;
    @synthesize namespaceURI = _namespaceURI;

    -(instancetype)initWithOwnerNode:(PGDOMElement *)ownerNode tagName:(NSString *)tagName {
        self = [super initWithOwnerNode:ownerNode];

        if(self) {
            _tagName = (tagName.length ? tagName.copy : @"*");
            [self setupNotifications];
        }

        return self;
    }

    -(instancetype)initWithOwnerNode:(PGDOMElement *)ownerNode localName:(NSString *)localName namespaceURI:(NSString *)namespaceURI {
        self = [super initWithOwnerNode:ownerNode];

        if(self) {
            _localName    = (localName.length ? localName.copy : @"*");
            _namespaceURI = (namespaceURI.length ? namespaceURI.copy : @"*");

            [self.notificationNames addObject:PGDOMCascadeNodeListChangedNotification];
            [self setupNotifications2];
        }

        return self;
    }

    -(void)setupNotifications {
        /*
         * We don't want the object to load the items from the owner until after the tagName or localName/namespaceURI have been set.
         */
    }

    -(void)setupNotifications2 {
        [super setupNotifications];
    }

    -(void)nodeListChangeListener:(NSNotification *)notification {
        if([self.notificationNames containsObject:notification.name] && (notification.object == self.ownerNode)) {
            [self.items removeAllObjects];
            if(self.tagName.length) [self load:self.items from:(PGDOMElement *)self.ownerNode byTagName:self.tagName];
            else [self load:self.items from:(PGDOMElement *)self.ownerNode byLocalName:self.localName namespaceURI:self.namespaceURI];
        }
    }

    -(void)load:(NSMutableArray<PGDOMElement *> *)list from:(PGDOMElement *)parent byTagName:(NSString *)tagName {
        for(PGDOMNode *node in parent.childNodes) {
            if(node.nodeType == PGDOMNodeTypeElement) {
                if(_compare(tagName, node.nodeName)) [list addObject:(PGDOMElement *)node];
                [self load:list from:(PGDOMElement *)node byTagName:tagName];
            }
        }
    }

    -(void)load:(NSMutableArray<PGDOMElement *> *)list from:(PGDOMElement *)parent byLocalName:(NSString *)localName namespaceURI:(NSString *)namespaceURI {
        for(PGDOMNode *node in parent.childNodes) {
            if(node.nodeType == PGDOMNodeTypeElement) {
                if(_compare(localName, node.localName) && _compare(namespaceURI, node.namespaceURI)) [list addObject:(PGDOMElement *)node];
                [self load:list from:(PGDOMElement *)node byLocalName:localName namespaceURI:namespaceURI];
            }
        }
    }

@end
