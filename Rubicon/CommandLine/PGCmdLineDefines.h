/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGCmdLineDefines.h
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

#ifndef RUBICON_PGCMDLINEDEFINES_H
#define RUBICON_PGCMDLINEDEFINES_H

#import <Rubicon/PGTools.h>

typedef NS_OPTIONS(uint8_t, PGCmdLineParseOptions) {
    PGCmdLineParseOptionDisallowNonOptions                 = (uint8_t)(1u << 0),  // Do not allow non-options. Default is NO.
    PGCmdLineParseOptionDisallowMixingOptionsAndNonOptions = (uint8_t)(1u << 1),  // Do not allow mixing of options and non-options. Default is NO.
    PGCmdLineParseOptionDisallowDuplicates                 = (uint8_t)(1u << 2),  // Do not allow duplicate options. Default is NO.
    PGCmdLineParseOptionDuplicatesKeepFirst                = (uint8_t)(1u << 3),  // In case of duplicates, keep the first one found. Default is to keep the last one found.
    PGCmdLineParseOptionDisallowUnknownOptions             = (uint8_t)(1u << 4)   // Do not allow unknown options.  Default is NO.
};

typedef NS_ENUM(uint8_t, PGCmdLineOptionArgument) {
    PGCmdLineArgNone = 0, // DEFAULT - Option takes no nonOptionArguments.
    PGCmdLineArgRequired  // Option takes a mandatory argument.
};

typedef NS_ENUM(uint8_t, PGCmdLineArgumentType) {
    PGCmdLineArgTypeNone = 0, // No options parameters.
    PGCmdLineArgTypeString,   // DEFAULT - A simple string.
    PGCmdLineArgTypeInteger,  // An integer value.
    PGCmdLineArgTypeFloat,    // A floating point value.
    PGCmdLineArgTypeDate,     // A valid calendar date.
    PGCmdLineArgTypeTime,     // A valid time.
    PGCmdLineArgTypeRegex     // A string that matches a given regex pattern.
};

FOUNDATION_EXPORT NSString *const PGCmdLineParamSeparator;

FOUNDATION_EXPORT NSString *const PGCmdLineErrorIndexKey;
FOUNDATION_EXPORT NSString *const PGCmdLineErrorItemKey;

FOUNDATION_EXPORT NSString *const PGErrorMsgCmdLineNonOptionItemsNotAllowed;
FOUNDATION_EXPORT NSString *const PGErrorMsgCmdLineCannotMixOptionsAndNonOptions;
FOUNDATION_EXPORT NSString *const PGErrorMsgCmdLineInvalidCommandLine;
FOUNDATION_EXPORT NSString *const PGErrorMsgCmdLineParamNotValidType;
FOUNDATION_EXPORT NSString *const PGErrorMsgCmdLineParamNotValidRegex;
FOUNDATION_EXPORT NSString *const PGErrorMsgCmdLineLongShortNULL;
FOUNDATION_EXPORT NSString *const PGErrorMsgCmdLineShortOptionTooLong;
FOUNDATION_EXPORT NSString *const PGErrorMsgCmdLineUnexpectedParameter;
FOUNDATION_EXPORT NSString *const PGErrorMsgCmdLineParameterExpected;
FOUNDATION_EXPORT NSString *const PGErrorMsgCmdLineDuplicateFound;
FOUNDATION_EXPORT NSString *const PGErrorMsgCmdLineUnknownOption;

#endif //RUBICON_PGCMDLINEDEFINES_H
