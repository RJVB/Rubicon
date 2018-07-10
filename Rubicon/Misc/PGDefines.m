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

#import "PGXMLParser.h"

NSString *const PGErrorDomain          = @"com.projectgalen.Rubicon";
NSString *const PGXMLParserErrorDomain = @"com.projectgalen.Rubicon.PGXMLParser";

NSExceptionName const PGTimedWorkerException   = @"PGTimedWorkerException";
NSExceptionName const PGSemaphoreException     = @"PGSemaphoreException";
NSExceptionName const PGReadWriteLockException = @"PGReadWriteLockException";
NSExceptionName const PGOSErrorException       = @"PGOSErrorException";

NSString *const PGDefaultSemaphoreNamePrefix = @"/sem";

const NSInteger PGErrorCodeUnknownError       = 1;
const NSInteger PGErrorCodeExceptionAsError   = 100;
const NSInteger PGErrorCodeCmdLineParseError  = 101;
const NSInteger PGErrorCodeRegexPatternIsNULL = 102;
const NSInteger PGErrorCodeNoDelegate         = 103;

const NSInteger PGErrorCodeIOError                 = 200;
const NSInteger PGErrorCodeNoInputStream           = 201;
const NSInteger PGErrorCodeUnknownInputStreamError = 202;
const NSInteger PGErrorCodeInputStreamClosed       = 203;
const NSInteger PGErrorCodeUnexpectedEndOfInput    = 204;

const NSInteger PGErrorCodeXMLParserWarning     = 300;
const NSInteger PGErrorCodeXMLParserAlreadyRun  = 301;
const NSInteger PGErrorCodeXMLParserError       = 302;
const NSInteger PGErrorCodeXMLParserFatalError  = 303;
const NSInteger PGErrorCodeXMLParserStructError = 304;

NSString *const PGUnderlyingExceptionKey = @"PGUnderlyingExceptionKey";

NSString *const PGErrorMsgBadRegexPattern         = @"Invalid regular expression pattern";
NSString *const PGErrorMsgRegexPatternIsNULL      = @"Regex pattern is NULL.";
NSString *const PGErrorMsgUnknowError             = @"Unknown Error.";
NSString *const PGErrorMsgInvalidConstructor      = @"Do not use this constructor.";
NSString *const PGErrorMsgInputStreamClosed       = @"Input stream closed.";
NSString *const PGErrorMsgUnknownInputStreamError = @"Unknown input stream error.";
NSString *const PGErrorMsgNoInputStream         = @"No input stream.";
NSString *const PGErrorMsgUnexpectedEndOfInput  = @"Unexpected end of input.";
NSString *const PGErrorMsgNoDelegate            = @"No delegate set.";
NSString *const PGErrorMsgXMLParserAlreadyRun   = @"XML Parser has already run.";
NSString *const PGErrorMsgCannotRotateNode      = @"Cannot rotate node to the %@ because there is no child node to the %@";
NSString *const PGErrorMsgNoDirectCreation      = @"You cannot directly create and instance of this class.";
NSString *const PGErrorMsgIndexOutOfBounds      = @"Index out of bounds.";
NSString *const PGErrorMsgNoModificationAllowed = @"No modification allowed.";
