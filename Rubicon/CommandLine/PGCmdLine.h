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

#import <Rubicon/PGTools.h>

typedef NS_OPTIONS(uint8_t, PGCmdLineParseOptions) {
    PGCmdLineParseOptionDisallowLongOptionNames            = (uint8_t)(1u << 0),  // Allow long options. Default is NO.
    PGCmdLineParseOptionDisallowNonOptions                 = (uint8_t)(1u << 1),  // Do not allow non-options. Default is NO.
    PGCmdLineParseOptionDisallowMixingOptionsAndNonOptions = (uint8_t)(1u << 2),  // Do not allow mixing of options and non-options. Default is NO.
    PGCmdLineParseOptionDisallowDuplicates                 = (uint8_t)(1u << 3),  // Do not allow duplicate options. Default is NO.
    PGCmdLineParseOptionDuplicatesKeepFirst                = (uint8_t)(1u << 4),  // In case of duplicates, keep the first one found. Default is to keep the last one found.
    PGCmdLineParseOptionDisallowUnknownOptions             = (uint8_t)(1u << 5),  // Do not allow unknown options.  Default is NO.
};

typedef NS_OPTIONS(uint8_t, PGCmdLineItemType) {
    PGCmdLineItemTypeError              = (uint8_t)(1u << 0), // 00000001 - Error.
    PGCmdLineItemTypeNonOption          = (uint8_t)(1u << 1), // 00000010 - Non-option item.
    PGCmdLineItemTypeShortOption        = (uint8_t)(1u << 2), // 00000100 - Short Option.
    PGCmdLineItemTypeLongOption         = (uint8_t)(1u << 3), // 00001000 - Long Option.
    PGCmdLineItemTypeEndOfOptions       = (uint8_t)(1u << 4), // 00010000 - End of options marker.
    PGCmdLineItemTypeUnknownOption      = (uint8_t)(1u << 5), // 00100000 - Unknown option.
    PGCmdLineItemTypeOptionalParameter  = (uint8_t)(1u << 6), // 01000000 - Option has optional parameter.
    PGCmdLineItemTypeManditoryParameter = (uint8_t)(1u << 7), // 10000000 - Option has manditory parameter.
};

FOUNDATION_EXPORT NSString *const PGCmdLineErrorIndexKey;
FOUNDATION_EXPORT NSString *const PGCmdLineErrorItemKey;

FOUNDATION_EXPORT NSString *const PGErrorMsgCmdLineNonOptionItemsNotAllowed;
FOUNDATION_EXPORT NSString *const PGErrorMsgCmdLineCannotMixOptionsAndNonOptions;
FOUNDATION_EXPORT NSString *const PGErrorMsgCmdLineLongOptionsNotAllowed;

FOUNDATION_EXPORT NSString *const PGCmdLineParamSeparator;

NS_ASSUME_NONNULL_BEGIN

@interface PGCmdLine : NSObject

    @property(readonly, copy) NSString                     *executableName;
    @property(readonly) /* */ NSStringEncoding             encoding;
    @property(readonly) /* */ NSStrArray                   rawArguments;  // Raw command-line arguments as given.
    @property(readonly) /* */ NSStrArray                   arguments;     // Non-option arguments.
    @property(readonly) /* */ NSDictionary<NSString *, id> *options;      // Options.
    @property(readonly) /* */ BOOL                         parseOptionDisallowLongOptionNames;
    @property(readonly) /* */ BOOL                         parseOptionDisallowNonOptions;
    @property(readonly) /* */ BOOL                         parseOptionDisallowMixingOptionsAndNonOptions;
    @property(readonly) /* */ BOOL                         parseOptionDisallowDuplicates;
    @property(readonly) /* */ BOOL                         parseOptionDuplicatesKeepFirst;
    @property(readonly) /* */ BOOL                         parseOptionDisallowUknownOptions;

    -(instancetype)initWithArguments:(const char **)argv
                              length:(NSUInteger)argc
                            encoding:(NSStringEncoding)encoding
                        parseOptions:(PGCmdLineParseOptions)parseOptions
                               error:(NSError **)error;

    -(instancetype)initWithArguments:(const char **)argv length:(NSUInteger)argc parseOptions:(PGCmdLineParseOptions)parseOptions error:(NSError **)error;

    -(PGCmdLineItemType)validateOption:(NSString *)option item:(NSString *)item index:(NSUInteger)idx error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGCMDLINE_H
