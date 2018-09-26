/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSAXAttribute.h
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

#ifndef __RUBICON_PGSAXATTRIBUTE_H__
#define __RUBICON_PGSAXATTRIBUTE_H__

#import <Rubicon/PGSAXNamespace.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGSAXAttribute : PGSAXNamespace

    @property(readonly) NSString *name;
    @property(readonly) NSString *value;
    @property(readonly) BOOL     isDefaulted;

    -(instancetype)initWithName:(NSString *)name value:(NSString *)value;

    +(instancetype)attributeWithName:(NSString *)name value:(NSString *)value;

    -(instancetype)initWithLocalname:(NSString *)localname prefix:(nullable NSString *)prefix uri:(NSString *)uri value:(NSString *)value defaulted:(BOOL)defaulted;

    +(instancetype)attributeWithLocalname:(NSString *)localname prefix:(nullable NSString *)prefix uri:(NSString *)uri value:(NSString *)value defaulted:(BOOL)defaulted;

@end

NS_ASSUME_NONNULL_END

#endif // __RUBICON_PGSAXATTRIBUTE_H__
