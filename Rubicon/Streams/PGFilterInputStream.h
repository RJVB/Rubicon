/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGFilterInputStream.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 3/29/18
 *  VISIBILITY: Private
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

#ifndef RUBICON_PGFILTERINPUTSTREAM_H
#define RUBICON_PGFILTERINPUTSTREAM_H

#import <Rubicon/PGTools.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGFilterInputStream : NSInputStream

    -(instancetype)initWithInputStream:(NSInputStream *)inputStream;

@end

@interface NSInputStream(PGFilterInputStream)

    +(PGFilterInputStream *)inputStreamThatFiltersInputStream:(NSInputStream *)inputStream;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGFILTERINPUTSTREAM_H
