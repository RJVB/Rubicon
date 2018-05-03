/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGCmdLineDefines.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 4/24/18
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

#import "PGCmdLineDefines.h"

NSString *const PGCmdLineParamSeparator = @"=";

NSString *const PGCmdLineErrorIndexKey = @"PGCmdLineErrorIndexKey";
NSString *const PGCmdLineErrorItemKey  = @"PGCmdLineErrorItemKey";

NSString *const PGErrorMsgCmdLineNonOptionItemsNotAllowed      = @"Non-option items not allowed.";
NSString *const PGErrorMsgCmdLineCannotMixOptionsAndNonOptions = @"Options and non-options cannot be mixed together.";
NSString *const PGErrorMsgCmdLineInvalidCommandLine            = @"Invalid command line.";
NSString *const PGErrorMsgCmdLineParamNotValidType             = @"Option parameter is not a valid %@.";
NSString *const PGErrorMsgCmdLineParamNotValidRegex            = @"Option parameter is not valid: \"%@\" does not match regex \"%@\"";
NSString *const PGErrorMsgCmdLineLongShortNULL                 = @"Both short name and long name are NULL.";
NSString *const PGErrorMsgCmdLineShortOptionTooLong            = @"Short option name can only be one character.";
NSString *const PGErrorMsgCmdLineUnexpectedParameter           = @"Unexpected option parameter";
NSString *const PGErrorMsgCmdLineParameterExpected             = @"Option parameter expected.";
NSString *const PGErrorMsgCmdLineDuplicateFound                = @"Duplicate option found.";
NSString *const PGErrorMsgCmdLineUnknownOption                 = @"Unknown option.";
NSString *const PGErrorMsgCmdLineOptionsNotFound               = @"The following options were not found: %@";
