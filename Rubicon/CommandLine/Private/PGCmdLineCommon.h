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

#ifndef __PGCMDLINECOMMON_H__
#define __PGCMDLINECOMMON_H__

#import "PGInternal.h"

typedef BOOL (^PGFindCmdLineOptionInArrayBlock)(PGCmdLineOption *, NSUInteger, BOOL *);

FOUNDATION_EXPORT NSString *const PGCmdLineRegexPrefix;
FOUNDATION_EXPORT NSString *const PGCmdLineCleanOptionPattern;
FOUNDATION_EXPORT NSString *const PGCmdLineCleanNonOptionPattern;
FOUNDATION_EXPORT NSString *const PGCmdLineLongOptionParamMarkerPattern;
FOUNDATION_EXPORT NSString *const PGCmdLineLongOptionMarker;
FOUNDATION_EXPORT NSString *const PGCmdLineShortOptionMarker;
FOUNDATION_EXPORT NSString *const PGCmdLineCleanOptionTemplate;
FOUNDATION_EXPORT NSString *const PGCmdLineCleanNonOptionTemplate;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSStrArray PGConvertCommandLineItems(NSUInteger argc, const char **argv, NSStringEncoding encoding, NSError **error);

FOUNDATION_EXPORT NSArray<PGCmdLineOption *> *PGCreateOptionsList(NSArray<PGCmdLineOption *> *options);

@interface PGCmdLine()

    @property(readonly) /**/ BOOL parseOptionDisallowNonOptions;
    @property(readonly) /**/ BOOL parseOptionDisallowMixingOptionsAndNonOptions;
    @property(readonly) /**/ BOOL parseOptionDisallowDuplicates;
    @property(readonly) /**/ BOOL parseOptionDuplicatesKeepFirst;
    @property(readonly) /**/ BOOL parseOptionDisallowUknownOptions;

    -(PGCmdLineOption *)optionAtIndex:(NSUInteger)idx;

    -(PGCmdLineOption *)findOptionPassingTest:(PGFindCmdLineOptionInArrayBlock)predicate;

    -(PGCmdLineOption *)findOptionByShortName:(NSString *)name;

    -(PGCmdLineOption *)findOptionByLongName:(NSString *)name;

@end

@interface PGCmdLineOption()

    @property(nonatomic) /*           */ BOOL     wasFound;
    @property(nullable, copy, nonatomic) NSString *argument;
    @property(nullable, readonly) /*  */ NSString *regexPattern;
    @property(readonly, nonatomic) /* */ NSLock   *lock;

    -(instancetype)initWithShortName:(NSString *)shortName
                            longName:(NSString *)longName
                          isRequired:(BOOL)isRequired
                       argumentState:(PGCmdLineOptionArgument)argumentState
                        argumentType:(PGCmdLineArgumentType)argumentType
                        regexPattern:(NSString *)regexPattern;

    -(NSComparisonResult)compare:(nullable PGCmdLineOption *)other;

@end

NS_INLINE BOOL isOption(NSString *item) {
    return ((item.length > PGCmdLineShortOptionMarker.length) && [item hasPrefix:PGCmdLineShortOptionMarker]);
}

NS_INLINE NSString *oquote(NSString *_Nullable string) {
    return (string ? PGFormat(@"@\"%@\"", string) : @"[NULL]");
}

NS_INLINE NSString *obool(BOOL b) {
    return (b ? @"YES" : @"NO");
}

NS_INLINE NSString *oargs(PGCmdLineOptionArgument a) {
    switch(a) {
        case PGCmdLineArgRequired: return @"Required";
        default: return @"None";
    }
}

NS_INLINE NSString *otypes(PGCmdLineArgumentType t) {
    switch(t) {
        case PGCmdLineArgTypeInteger: return @"integer";
        case PGCmdLineArgTypeFloat: return @"floating point";
        case PGCmdLineArgTypeDate: return @"date";
        case PGCmdLineArgTypeTime: return @"time";
        case PGCmdLineArgTypeRegex: return @"regular expression";
        case PGCmdLineArgTypeString: return @"string";
        case PGCmdLineArgTypeNone:
        default: return PGCmdLineLongOptionMarker;
    }
}

NS_ASSUME_NONNULL_END

#endif //__PGCMDLINECOMMON_H__
