/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSAXElementContent.h
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

#ifndef __RUBICON_PGSAXELEMENTDECL_H__
#define __RUBICON_PGSAXELEMENTDECL_H__

#import <Rubicon/PGTools.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PGSAXElementContentType) {
    PGSAX_ELEM_CONTENT_PCDATA = 1, PGSAX_ELEM_CONTENT_ELEMENT, PGSAX_ELEM_CONTENT_SEQ, PGSAX_ELEM_CONTENT_OR,
};

typedef NS_ENUM(NSInteger, PGSAXElementContentOccur) {
    PGSAX_ELEM_CONTENT_ONCE = 1, PGSAX_ELEM_CONTENT_OPT, PGSAX_ELEM_CONTENT_MULT, PGSAX_ELEM_CONTENT_PLUS
};

@interface PGSAXElement : NSObject
@end

@interface PGSAXElementDecl : NSObject

    @property(readonly) NSString                 *name;
    @property(readonly) NSString                 *prefix;
    @property(readonly) PGSAXElementContentType  contentType;
    @property(readonly) PGSAXElementContentOccur contentOccur;
    @property(readonly) PGSAXElementDecl         *child1;
    @property(readonly) PGSAXElementDecl         *child2;
    @property(readonly) PGSAXElementDecl         *parent;

    -(BOOL)isEqual:(id)other;

    -(BOOL)isEqualToDecl:(PGSAXElementDecl *)decl;

    -(NSUInteger)hash;

@end

NS_ASSUME_NONNULL_END

#endif // __RUBICON_PGSAXELEMENTDECL_H__
