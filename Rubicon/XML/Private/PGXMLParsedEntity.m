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
#import "NSException+PGException.h"

@interface PGXMLParsedEntity()

    @property(copy) NSString *name;

    -(BOOL)_isEqualToEntity:(PGXMLParsedEntity *)ent;

    -(void)freeEntity:(xmlEntity *)ent;

@end

@implementation PGXMLParsedEntity {
        NSRecursiveLock *_lock;
        xmlEntityPtr    _xmlEntity;
        NSString        *_name;
        NSString        *_content;
        NSString        *_publicID;
        NSString        *_systemID;
        xmlEntityType   _type;
    }

    -(instancetype)init {
        self = [super init];
        @throw [NSException exceptionWithName:NSIllegalSelectorException reason:@"Do not call this initializer."];
    }

    -(instancetype)initWithName:(NSString *)name content:(NSString *)content publicID:(NSString *)publicID systemID:(NSString *)systemID type:(xmlEntityType)type {
        self = [super init];

        if(self) {
            _lock = [NSRecursiveLock new];

            self.name     = name;
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

    -(instancetype)copyWithZone:(nullable NSZone *)zone {
        PGXMLParsedEntity *copy = [((PGXMLParsedEntity *)[[self class] allocWithZone:zone]) init];

        if(copy != nil) {
            copy.name     = self.name;
            copy.content  = self.content;
            copy.publicID = self.publicID;
            copy.systemID = self.systemID;
            copy.type     = self.type;
        }

        return copy;
    }

    -(xmlEntityPtr)xmlEntity {
        [self lock];
        @try {
            if((_xmlEntity == nil) && self.name.length) {
                _xmlEntity = PGCalloc(1, sizeof(xmlEntity));

                _xmlEntity->type    = XML_ENTITY_DECL;
                _xmlEntity->etype   = self.type;
                _xmlEntity->name    = xmlStrdup((xmlChar *)self.name.UTF8String);
                _xmlEntity->content = xmlStrdup((xmlChar *)(self.content ?: @"").UTF8String);
                _xmlEntity->orig    = xmlStrdup(_xmlEntity->content);
                _xmlEntity->length  = xmlStrlen(_xmlEntity->content);

                if(self.publicID) _xmlEntity->ExternalID = xmlStrdup((xmlChar *)self.publicID.UTF8String);
                if(self.systemID) _xmlEntity->SystemID   = xmlStrdup((xmlChar *)self.systemID.UTF8String);
            }
        }
        @finally { [self unlock]; }
        return _xmlEntity;
    }

    -(void)freeEntity:(xmlEntity *)ent {
        if(ent) {
            if(ent->name) free((void *)ent->name);
            if(ent->content) free(ent->content);
            if(ent->orig) free(ent->orig);
            if(ent->ExternalID) free((void *)ent->ExternalID);
            if(ent->SystemID) free((void *)ent->SystemID);
            free(ent);
        }
    }

    -(void)dealloc {
        [self freeEntity:_xmlEntity];
    }

    -(void)lock {
        [_lock lock];
    }

    -(void)unlock {
        [_lock unlock];
    }

    -(NSString *)name {
        [self lock];
        NSString *v = _name;
        [self unlock];
        return v;
    }

    -(NSString *)content {
        [self lock];
        NSString *v = _content;
        [self unlock];
        return v;
    }

    -(NSString *)publicID {
        [self lock];
        NSString *v = _publicID;
        [self unlock];
        return v;
    }

    -(NSString *)systemID {
        [self lock];
        NSString *v = _systemID;
        [self unlock];
        return v;
    }

    -(xmlEntityType)type {
        [self lock];
        xmlEntityType v = _type;
        [self unlock];
        return v;
    }

    -(void)setName:(NSString *)name {
        [self lock];
        if(!PGStringsEqual(_name, name)) {
            _name = [name copy];
            if(_xmlEntity) [self freeEntity:_xmlEntity];
        }
        [self unlock];
    }

    -(void)setContent:(NSString *)content {
        [self lock];
        if(!PGStringsEqual(content, _content)) {
            _content = [content copy];
            if(_xmlEntity) [self freeEntity:_xmlEntity];
        }
        [self unlock];
    }

    -(void)setPublicID:(NSString *)publicID {
        [self lock];
        if(!PGStringsEqual(publicID, _publicID)) {
            _publicID = [publicID copy];
            if(_xmlEntity) [self freeEntity:_xmlEntity];
        }
        [self unlock];
    }

    -(void)setSystemID:(NSString *)systemID {
        [self lock];
        if(!PGStringsEqual(systemID, _systemID)) {
            _systemID = [systemID copy];
            if(_xmlEntity) [self freeEntity:_xmlEntity];
        }
        [self unlock];
    }

    -(void)setType:(xmlEntityType)type {
        [self lock];
        if(type != _type) {
            _type = type;
            if(_xmlEntity) [self freeEntity:_xmlEntity];
        }
        [self unlock];
    }

    +(instancetype)entityWithName:(NSString *)name content:(NSString *)content publicID:(NSString *)publicID systemID:(NSString *)systemID type:(xmlEntityType)type {
        return [[self alloc] initWithName:name content:content publicID:publicID systemID:systemID type:type];
    }

    +(instancetype)entityWithName:(NSString *)name content:(NSString *)content {
        return [[self alloc] initWithName:name content:content publicID:nil systemID:nil type:XML_INTERNAL_GENERAL_ENTITY];
    }

    +(instancetype)parameterEntityWithName:(NSString *)name content:(NSString *)content {
        return [[self alloc] initWithName:name content:content publicID:nil systemID:nil type:XML_INTERNAL_PARAMETER_ENTITY];
    }

@end
