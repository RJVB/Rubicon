/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGXMLParser.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 5/26/18
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

#ifndef RUBICON_PGXMLPARSER_H
#define RUBICON_PGXMLPARSER_H

#import <Rubicon/PGTools.h>
#import <Rubicon/PGXMLParserDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGXMLParser : NSObject

    @property(assign, nullable) /*   */ id<PGXMLParserDelegate> delegate;
    @property(readonly) /*           */ NSUInteger              lineNumber;
    @property(readonly) /*           */ NSUInteger              columnNumber;
    @property(readonly, nullable) /* */ NSError                 *parserError;
    @property(readonly, copy, nullable) NSString                *publicId;
    @property(readonly, copy, nullable) NSString                *systemId;

    -(instancetype)initWithInputStream:(NSInputStream *)stream NS_DESIGNATED_INITIALIZER;

    -(instancetype)initWithFilePath:(NSString *)filepath;

    -(instancetype)initWithURL:(NSURL *)url;

    -(BOOL)parse;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGXMLPARSER_H
