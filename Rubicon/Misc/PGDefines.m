/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDefines.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/10/17 1:04 PM
 * DESCRIPTION:
 *
 * Copyright © 2017 Galen Rhodes All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#import "PGDefines.h"

NSString *const PGErrorDomain = @"com.projectgalen.Rubicon";

NSExceptionName const PGTimedWorkerException   = @"PGTimedWorkerException";
NSExceptionName const PGSemaphoreException     = @"PGSemaphoreException";
NSExceptionName const PGReadWriteLockException = @"PGReadWriteLockException";
NSExceptionName const PGOSErrorException       = @"PGOSErrorException";

NSString *const PGDefaultSemaphoreNamePrefix = @"/sem";

const NSInteger PGErrorCodeUnknownError       = 1;
const NSInteger PGErrorCodeExceptionAsError   = 100;
const NSInteger PGErrorCodeCmdLineParseError  = 200;
const NSInteger PGErrorCodeRegexPatternIsNULL = 300;
const NSInteger PGErrorCodeIOError            = 1000;

NSString *const PGUnderlyingExceptionKey = @"PGUnderlyingExceptionKey";

NSString *const PGErrorMsgBadRegexPattern    = @"Invalid regular expression pattern";
NSString *const PGErrorMsgRegexPatternIsNULL = @"Regex pattern is NULL.";
NSString *const PGErrorMsgUnknowError        = @"Unknown Error.";

