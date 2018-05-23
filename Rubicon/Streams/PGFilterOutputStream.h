/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGFilterOutputStream.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 2/15/18 2:30 PM
 *  VISIBILITY: Public
 * DESCRIPTION:
 *     While the class NSData provides base64 encoding operations, these class require that the entire data set be held in memory before the encoding begins.  This class, which
 *     inherits from NSOutputStream, allows for the streaming of data to a file and have it encoded "on the fly" without having to retain the entire data set in memory.
 *
 * Copyright © 2017 Project Galen. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this
 * permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
 * AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#ifndef __Rubicon_PGFilterOutputStream_H_
#define __Rubicon_PGFilterOutputStream_H_

#import <Rubicon/PGTools.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGFilterOutputStream : NSOutputStream<NSStreamDelegate, NSLocking>

    @property(atomic, retain, readonly) NSOutputStream *out;
    @property(atomic, readonly) NSUInteger             chunkSize;

    -(instancetype)initWithOutputStream:(NSOutputStream *)outputStream;

    -(instancetype)initWithOutputStream:(NSOutputStream *)outputStream chunk:(NSUInteger)chunk;

    -(NSInteger)writeFiltered:(const NSByte *)buffer maxLength:(NSUInteger)len;

    +(instancetype)streamWithOutputStream:(NSOutputStream *)outputStream;

    +(instancetype)streamWithOutputStream:(NSOutputStream *)outputStream chunk:(NSUInteger)chunk;

    -(NSInteger)flush;

@end

NS_ASSUME_NONNULL_END

#endif
