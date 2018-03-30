/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGStreamTee.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 3/29/18
 *  DESCRIPTION: PGStreamTee is designed to be sort of an analog to the Unix 'tee' command.  It is an input filter stream that writes everthing read from it's
 *               enclosing stream to a file.
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

#ifndef RUBICON_PGSTREAMTEE_H
#define RUBICON_PGSTREAMTEE_H

#import <Rubicon/PGFilterInputStream.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGStreamTee : PGFilterInputStream

    @property(readonly) NSOutputStream *outputStream;

    -(instancetype)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream closeOutputWhenClosed:(BOOL)flag;

    +(instancetype)teeWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream closeOutputWhenClosed:(BOOL)flag;

    +(instancetype)teeWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;

    +(instancetype)teeWithInputStream:(NSInputStream *)inputStream outputURL:(NSURL *)outputURL append:(BOOL)append;

    +(instancetype)teeWithInputStream:(NSInputStream *)inputStream outputURL:(NSURL *)outputURL;

    +(instancetype)teeWithInputStream:(NSInputStream *)inputStream filePath:(NSString *)filePath append:(BOOL)append;

    +(instancetype)teeWithInputStream:(NSInputStream *)inputStream filePath:(NSString *)filePath;

    +(instancetype)teeWithInputStream:(NSInputStream *)inputStream temporaryFile:(NSURL *_Nonnull *_Nonnull)url;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGSTREAMTEE_H
