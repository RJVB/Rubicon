/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGXMLParsedEntity.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 5/31/18
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

#import "PGXMLParsedEntity.h"
#import "PGTools.h"

@implementation PGXMLParsedEntity {
        NSRecursiveLock *_lock;
        xmlEntityPtr    _xmlEntity;
        NSString        *_content;
        NSString        *_publicID;
        NSString        *_systemID;
        xmlEntityType   _type;
        xmlChar         *_xName;
        xmlChar         *_xPublicID;
        xmlChar         *_xSystemID;
    }

    -(instancetype)initWithName:(NSString *)name content:(NSString *)content publicID:(NSString *)publicID systemID:(NSString *)systemID type:(xmlEntityType)type {
        self = [super init];

        if(self) {
            _lock  = [NSRecursiveLock new];
            _name  = [name copy];
            _xName = ((xmlChar *)strdup(self.name.UTF8String));
            self.content  = content;
            self.publicID = publicID;
            self.systemID = systemID;
            self.type     = type;
        }

        return self;
    }

    -(BOOL)isEqual:(id)other {
        return (other && ((other == self) || ([other isKindOfClass:[self class]] && [self _isEqualToEntity:other])));
    }

    -(BOOL)isEqualToEntity:(PGXMLParsedEntity *)entity {
        return (entity && ((entity == self) || [self _isEqualToEntity:entity]));
    }

    -(BOOL)_isEqualToEntity:(PGXMLParsedEntity *)ent {
        return (PGStringsEqual(self.name, ent.name) &&
                PGStringsEqual(self.content, ent.content) &&
                PGStringsEqual(self.publicID, ent.publicID) &&
                PGStringsEqual(self.systemID, ent.systemID) &&
                (self.type == ent.type));
    }

    -(NSUInteger)hash {
        return (((((31u + self.name.hash) * 31u + self.content.hash) * 31u + self.publicID.hash) * 31u + self.systemID.hash) * 31u + (NSUInteger)self.type);
    }

    +(instancetype)entityWithName:(NSString *)name content:(NSString *)content publicID:(NSString *)publicID systemID:(NSString *)systemID type:(xmlEntityType)type {
        return [[self alloc] initWithName:name content:content publicID:publicID systemID:systemID type:type];
    }

    +(instancetype)entityWithName:(NSString *)name content:(NSString *)content {
        return [[self alloc] initWithName:name content:content publicID:nil systemID:nil type:XML_INTERNAL_GENERAL_ENTITY];
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        PGXMLParsedEntity *copy = [((PGXMLParsedEntity *)[[self class] allocWithZone:zone]) init];

        if(copy != nil) {
            copy->_name   = [_name copy];
            copy.content  = self.content;
            copy.publicID = self.publicID;
            copy.systemID = self.systemID;
            copy.type     = self.type;
        }

        return copy;
    }

    -(xmlEntityPtr)xmlEntity {
        if(_xmlEntity == nil) {
            [_lock lock];
            @try {
                if(_xmlEntity == nil) {
                    _xPublicID = (self.publicID ? (xmlChar *)strdup(self.publicID.UTF8String) : NULL);
                    _xSystemID = (self.systemID ? (xmlChar *)strdup(self.systemID.UTF8String) : NULL);

                    xmlEntityPtr ent = PGCalloc(1, sizeof(xmlEntity));
                    ent->name       = _xName;
                    ent->ExternalID = _xPublicID;
                    ent->SystemID   = _xSystemID;
                    ent->type       = XML_ENTITY_DECL;
                    ent->etype      = (xmlEntityType)self.type; //XML_INTERNAL_GENERAL_ENTITY;
                    ent->content    = (xmlChar *)strdup(self.content.UTF8String);
                    ent->length     = xmlStrlen(ent->content);
                    ent->orig       = xmlStrdup(ent->content);
                    _xmlEntity = ent;
                }
            }
            @finally { [_lock unlock]; }
        }

        return _xmlEntity;
    }

    -(void)freeEntity {
        [_lock lock];
        xmlEntityPtr ent = _xmlEntity;
        _xmlEntity = NULL;
        [_lock unlock];
        [self _freeEntity:ent];
    }

    -(void)_freeEntity:(xmlEntity *)ent {
        if(ent) {
            free(ent->content);
            free(ent->orig);
            free(ent);

            if(_xPublicID) free(_xPublicID);
            if(_xSystemID) free(_xSystemID);
        }
    }

    -(void)dealloc {
        [self _freeEntity:_xmlEntity];
        if(_xName) free(_xName);
    }

    -(NSString *)content {
        return _content;
    }

    -(NSString *)publicID {
        return _publicID;
    }

    -(NSString *)systemID {
        return _systemID;
    }

    -(xmlEntityType)type {
        return _type;
    }

    -(void)setContent:(NSString *)content {
        if(!PGStringsEqual(content, _content)) {
            _content = [content copy];
            [self freeEntity];
        }
    }

    -(void)setPublicID:(NSString *)publicID {
        if(!PGStringsEqual(publicID, _publicID)) {
            _publicID = [publicID copy];
            [self freeEntity];
        }
    }

    -(void)setSystemID:(NSString *)systemID {
        if(!PGStringsEqual(systemID, _systemID)) {
            _systemID = [systemID copy];
            [self freeEntity];
        }
    }

    -(void)setType:(xmlEntityType)type {
        if(type != _type) {
            _type = type;
            [self freeEntity];
        }
    }


@end
