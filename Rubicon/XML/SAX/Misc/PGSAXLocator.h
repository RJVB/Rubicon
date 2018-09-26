/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGSAXLocator.h
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

#ifndef __RUBICON_PGSAXLOCATOR_H__
#define __RUBICON_PGSAXLOCATOR_H__

#import <Rubicon/PGTools.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGSAXLocator : NSObject

    @property(readonly) NSString   *publicId;
    @property(readonly) NSString   *systemId;
    @property(readonly) NSUInteger lineNumber;
    @property(readonly) NSUInteger columnNumber;

    -(instancetype)init;

@end

NS_ASSUME_NONNULL_END

#endif // __RUBICON_PGSAXLOCATOR_H__
