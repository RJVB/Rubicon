/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBase64OutputStream.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 3/8/17 11:13 AM
 *  VISIBILITY: Private
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

#ifndef __Rubicon_PGBase64OutputStream_H_
#define __Rubicon_PGBase64OutputStream_H_

#import <Rubicon/PGTools.h>
#import <Rubicon/PGFilterOutputStream.h>

NS_ASSUME_NONNULL_BEGIN

char *PGEncodeBase64(const NSByte *input, NSUInteger inlen, NSUInteger *outlen);

@interface PGBase64OutputStream : PGFilterOutputStream

    -(instancetype)initWithOutputStream:(NSOutputStream *)outputStream;

    -(instancetype)initWithOutputStream:(NSOutputStream *)outputStream chunk:(NSUInteger)chunk;

@end

NS_ASSUME_NONNULL_END

#endif //__Rubicon_PGBase64OutputStream_H_
