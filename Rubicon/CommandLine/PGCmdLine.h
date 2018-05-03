/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGCmdLine.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 4/14/18
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

#ifndef RUBICON_PGCMDLINE_H
#define RUBICON_PGCMDLINE_H

#import <Rubicon/PGCmdLineOption.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGCmdLine : NSObject<NSCopying>

    @property(readonly) NSString              *executableName;
    @property(readonly) NSStringEncoding      encoding;
    @property(readonly) NSStrArray            rawArguments;       // Raw command-line nonOptionArguments as given.
    @property(readonly) NSStrArray            nonOptionArguments; // Non-option nonOptionArguments.
    @property(readonly) NSStrArray            unknownOptions;     // Options not specified in the options set.
    @property(readonly) PGCmdLineOptionSet    options;            // Options.
    @property(readonly) PGCmdLineParseOptions parseOptions;

    -(instancetype)initWithArguments:(const char **)argv
                              length:(NSUInteger)argc
                            encoding:(NSStringEncoding)encoding
                        parseOptions:(PGCmdLineParseOptions)parseOptions
                             options:(NSArray<PGCmdLineOption *> *)options
                               error:(NSError **)error;

    +(instancetype)cmdLineWithArguments:(const char **)argv
                                 length:(NSUInteger)argc
                               encoding:(NSStringEncoding)encoding
                           parseOptions:(PGCmdLineParseOptions)parseOptions
                                options:(NSArray<PGCmdLineOption *> *)options
                                  error:(NSError **)error;

    +(instancetype)cmdLineWithArguments:(const char **)argv
                                 length:(NSUInteger)argc
                           parseOptions:(PGCmdLineParseOptions)parseOptions
                                options:(NSArray<PGCmdLineOption *> *)options
                                  error:(NSError **)error;

    +(instancetype)cmdLineWithArguments:(const char **)argv
                                 length:(NSUInteger)argc
                               encoding:(NSStringEncoding)encoding
                           parseOptions:(PGCmdLineParseOptions)parseOptions
                             optionList:(const PGCmdLineOptionStruct *)options
                                  error:(NSError **)error;

    +(instancetype)cmdLineWithArguments:(const char **)argv
                                 length:(NSUInteger)argc
                           parseOptions:(PGCmdLineParseOptions)parseOptions
                             optionList:(const PGCmdLineOptionStruct *)options
                                  error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGCMDLINE_H
