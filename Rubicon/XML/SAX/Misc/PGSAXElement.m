/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSAXElementContent.m
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

@implementation PGSAXElement {
    }
@end

@implementation PGSAXElementDecl {
    }

    @synthesize name = _name;
    @synthesize prefix = _prefix;
    @synthesize contentType = _contentType;
    @synthesize contentOccur = _contentOccur;
    @synthesize child1 = _child1;
    @synthesize child2 = _child2;
    @synthesize parent = _parent;

    -(instancetype)initWithXmlElementContent:(xmlElementContentPtr)elemContent {
        self = [super init];

        if(self) {
            if(elemContent) {
                _name         = [NSString stringFromXMLString:elemContent->name];
                _prefix       = [NSString stringFromXMLString:elemContent->prefix];
                _contentType  = (PGSAXElementContentType)elemContent->type;
                _contentOccur = (PGSAXElementContentOccur)elemContent->ocur;
                _child1       = [[self class] declWithXmlElementContent:elemContent->c1];
                _child2       = [[self class] declWithXmlElementContent:elemContent->c2];
                _parent       = [[self class] declWithXmlElementContent:elemContent->parent];
            }
            else {
                self = nil;
            }
        }

        return self;
    }

    +(instancetype)declWithXmlElementContent:(xmlElementContentPtr)elemContent {
        return [[self alloc] initWithXmlElementContent:elemContent];
    }

    -(BOOL)isEqual:(id)other {
        return (other && ((other == self) || ([other isKindOfClass:[self class]] && [self isEqualToDecl:other])));
    }

    -(BOOL)isEqualToDecl:(PGSAXElementDecl *)decl {
        return (decl &&
                ((self == decl) ||
                 (PGStringsEqual(self.name, decl.name) &&
                  PGStringsEqual(self.prefix, decl.prefix) &&
                  (self.contentType && decl.contentType) &&
                  (self.contentOccur && decl.contentOccur))));
    }

    -(NSUInteger)hash {
        NSUInteger hash = (31u + [self.name hash]);
        hash = ((hash * 31u) + [self.prefix hash]);
        hash = ((hash * 31u) + (NSUInteger)self.contentType);
        hash = ((hash * 31u) + (NSUInteger)self.contentOccur);
        return hash;
    }

@end
