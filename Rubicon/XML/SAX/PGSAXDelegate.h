/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSAXDelegate.h
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

#ifndef __RUBICON_PGSAXDELEGATE_H__
#define __RUBICON_PGSAXDELEGATE_H__

#import <Rubicon/PGTools.h>
#import <Rubicon/PGSAXLocator.h>
#import <Rubicon/PGSAXEntity.h>
#import "PGSAXElementDecl.h"
#import <Rubicon/PGSAXAttribute.h>
#import <Rubicon/PGSAXNamespace.h>

@class PGSAXParser;

NS_ASSUME_NONNULL_BEGIN

@protocol PGSAXDelegate<NSObject>

  @optional

/* @f:0 */

    -(void)internalSubset:(PGSAXParser *)parser name:(nullable NSString *)name externalID:(nullable NSString *)externalId systemID:(nullable NSString *)systemId;

    -(void)externalSubset:(PGSAXParser *)parser name:(nullable NSString *)name externalID:(nullable NSString *)externalId systemID:(nullable NSString *)systemId;

    -(BOOL)isStandalone:(PGSAXParser *)parser;

    -(BOOL)hasInternalSubset:(PGSAXParser *)parser;

    -(BOOL)hasExternalSubset:(PGSAXParser *)parser;

    -(nullable NSString *)getEntity:(PGSAXParser *)parser name:(nullable NSString *)name;

    -(nullable NSString *)getParameterEntity:(PGSAXParser *)parser name:(nullable NSString *)name;

    -(nullable NSData *)resolveEntity:(PGSAXParser *)parser publicID:(nullable NSString *)publicId systemID:(nullable NSString *)systemId;

    -(void)entityDecl:(PGSAXParser *)parser name:(nullable NSString *)name type:(int)type publicID:(nullable NSString *)publicId systemID:(nullable NSString *)systemId content:(nullable NSString *)content;

    -(void)notationDecl:(PGSAXParser *)parser name:(nullable NSString *)name publicID:(nullable NSString *)publicId systemID:(nullable NSString *)systemId;

    -(void)attributeDecl:(PGSAXParser *)parser elem:(nullable NSString *)elem fullname:(nullable NSString *)fullname type:(int)type def:(int)def defaultValue:(nullable NSString *)defaultValue tree:(NSArray *)tree;

    -(void)elementDecl:(PGSAXParser *)parser name:(nullable NSString *)name type:(int)type content:(nullable PGSAXElementDecl *)content;

    -(void)unparsedEntityDecl:(PGSAXParser *)parser name:(nullable NSString *)name publicID:(nullable NSString *)publicId systemID:(nullable NSString *)systemId notationName:(nullable NSString *)notationName;

    -(void)setDocumentLocator:(PGSAXParser *)parser location:(nullable PGSAXLocator *)location;

    -(void)startDocument:(PGSAXParser *)parser;

    -(void)endDocument:(PGSAXParser *)parser;

    -(void)startElement:(PGSAXParser *)parser name:(nullable NSString *)name attributes:(NSArray<PGSAXAttribute *> *)attributes;

    -(void)endElement:(PGSAXParser *)parser name:(nullable NSString *)name;

    -(void)reference:(PGSAXParser *)parser name:(nullable NSString *)name;

    -(void)characters:(PGSAXParser *)parser value:(nullable NSString *)value;

    -(void)ignorableWhitespace:(PGSAXParser *)parser value:(nullable NSString *)value;

    -(void)processingInstruction:(PGSAXParser *)parser target:(nullable NSString *)target data:(nullable NSString *)data;

    -(void)comment:(PGSAXParser *)parser value:(nullable NSString *)value;

    -(void)cdataBlock:(PGSAXParser *)parser value:(nullable NSString *)value;

    -(void)startElementNS:(PGSAXParser *)parser localname:(nullable NSString *)localname prefix:(nullable NSString *)prefix URI:(nullable NSString *)URI namespaces:(NSArray<PGSAXNamespace *> *)namespaces attributes:(NSArray<PGSAXAttribute *> *)attributes;

    -(void)endElementNS:(PGSAXParser *)parser localname:(nullable NSString *)localname prefix:(nullable NSString *)prefix URI:(nullable NSString *)URI;

    -(void)xmlStructuredError:(PGSAXParser *)parser msg:(nullable NSString *)msg;

    -(void)warning:(PGSAXParser *)parser msg:(nullable NSString *)msg;

    -(void)error:(PGSAXParser *)parser msg:(nullable NSString *)msg;

    -(void)fatalError:(PGSAXParser *)parser msg:(nullable NSString *)msg;

/* @f:1 */

@end

NS_ASSUME_NONNULL_END

#endif // __RUBICON_PGSAXDELEGATE_H__
