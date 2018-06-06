/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGXMLParsedNamespace.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 5/30/18
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

#import "PGInternal.h"
#import "PGXMLParsedNamespace.h"

@implementation PGXMLParsedNamespace {
    }

    -(instancetype)initWithPrefix:(NSString *)prefix uri:(NSString *)uri {
        self = [super init];

        if(self) {
            _prefix = [prefix copy];
            _uri    = [uri copy];
        }

        return self;
    }

    +(instancetype)namespaceWithPrefix:(NSString *)prefix uri:(NSString *)uri {
        return [[self alloc] initWithPrefix:prefix uri:uri];
    }

    -(BOOL)_isEqualToNamespace:(PGXMLParsedNamespace *)aNamespace {
        return (PGStringsEqual(_prefix, aNamespace.prefix) && PGStringsEqual(_uri, aNamespace.uri));
    }

    -(BOOL)isEqual:(id)other {
        return (other && ((other == self) || ([other isKindOfClass:[self class]] && [self _isEqualToNamespace:other])));
    }

    -(BOOL)isEqualToNamespace:(PGXMLParsedNamespace *)aNamespace {
        return (aNamespace && ((aNamespace == self) || [self _isEqualToNamespace:aNamespace]));
    }

    -(NSUInteger)hash {
        return (((31u + [self.prefix hash]) * 31u) + [self.uri hash]);
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        return self;
    }

@end
