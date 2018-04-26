/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGCmdLineOption.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 4/24/18
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

#ifndef RUBICON_PGCMDLINEOPTION_H
#define RUBICON_PGCMDLINEOPTION_H

#import <Rubicon/PGCmdLineDefines.h>

@class PGCmdLineOption;

typedef NSArray<PGCmdLineOption *> *PGCmdLineOptionSet;

NS_ASSUME_NONNULL_BEGIN

@interface PGCmdLineOption : NSObject<NSCopying>

    @property(readonly, nullable) NSString                *shortName;
    @property(readonly, nullable) NSString                *longName;
    @property(readonly) /*     */ BOOL                    isRequired;
    @property(readonly) /*     */ BOOL                    wasFound;
    @property(readonly) /*     */ PGCmdLineOptionArgument argumentState;
    @property(readonly) /*     */ PGCmdLineArgumentType   argumentType;
    @property(readonly, nullable) NSRegularExpression     *regex;
    @property(readonly, nullable) NSString                *argument;

    -(NSString *)nameDescription;

    -(id)copyWithZone:(nullable NSZone *)zone;
@end

FOUNDATION_EXPORT PGCmdLineOption *PGMakeCmdLineOpt(NSString *__nullable shortName,
                                                    NSString *__nullable longName,
                                                    BOOL isRequired,
                                                    PGCmdLineOptionArgument argument,
                                                    PGCmdLineArgumentType argType,
                                                    NSString *__nullable regexPattern);

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGCMDLINEOPTION_H
