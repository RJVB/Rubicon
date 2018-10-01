/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSAXEntity.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 9/20/18
 *
 * Copyright © 2018 Project Galen. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *//************************************************************************/

#import "PGSAXParserTools.h"

@implementation PGSAXEntity {
        xmlChar      *_xmlName;
        xmlChar      *_xmlContent;
        xmlChar      *_xmlSystemId;
        xmlChar      *_xmlPublicId;
        xmlEntityPtr _xmlEntity;
    }

    @synthesize name = _name;
    @synthesize content = _content;
    @synthesize systemId = _systemId;
    @synthesize publicId = _publicId;
    @synthesize type = _type;

    -(instancetype)initWithName:(NSString *)name content:(NSString *)content type:(NSInteger)type systemId:(NSString *)systemId publicId:(NSString *)publicId {
        self = [super init];

        if(self) {
            _name     = name;
            _content  = content;
            _systemId = systemId;
            _publicId = publicId;
            _type     = type;
        }

        return self;
    }

    +(instancetype)entityWithName:(NSString *)name content:(NSString *)content type:(NSInteger)type systemId:(NSString *)systemId publicId:(NSString *)publicId {
        return [[self alloc] initWithName:name content:content type:type systemId:systemId publicId:publicId];
    }

    -(BOOL)isEqual:(id)other {
        return (other && ((other == self) || ([other isKindOfClass:[self class]] && [self isEqualToEntity:other])));
    }

    -(BOOL)isEqualToEntity:(PGSAXEntity *)entity {
        return (entity && ((self == entity) || ((self.type == entity.type) && PGStringsEqual(self.name, entity.name))));
    }

    -(NSUInteger)hash {
        NSUInteger hash = [self.name hash];
        hash = ((hash * 31u) + self.type);
        return hash;
    }

    -(xmlEntityPtr)xmlEntity {
        if(_xmlEntity == NULL) {
            @synchronized(self) {
                if(_xmlEntity == NULL) {
                    if(self.name) _xmlName                 = (xmlChar *)strdup(self.name.UTF8String);
                    if(self.content) _xmlContent           = (xmlChar *)strdup(self.content.UTF8String);
                    if(self.systemId) _xmlSystemId         = (xmlChar *)strdup(self.systemId.UTF8String);
                    if(self.publicId) _xmlPublicId         = (xmlChar *)strdup(self.publicId.UTF8String);
                    if(_xmlName && _xmlContent) _xmlEntity = xmlNewEntity(NULL, _xmlName, abs((int)self.type), _xmlPublicId, _xmlSystemId, _xmlContent);
                }
            }
        }

        return _xmlEntity;
    }

    -(void)dealloc {
        if(_xmlEntity) free(_xmlEntity);
        if(_xmlName) free(_xmlName);
        if(_xmlContent) free(_xmlContent);
        if(_xmlPublicId) free(_xmlPublicId);
        if(_xmlSystemId) free(_xmlSystemId);
    }

@end

