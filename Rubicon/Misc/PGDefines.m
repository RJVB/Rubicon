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
 *//************************************************************************/
#import "PGDefines.h"

NSString *const PGErrorDomain          = @"com.projectgalen.Rubicon";
NSString *const PGXMLParserErrorDomain = @"com.projectgalen.Rubicon.PGXMLParser";

NSExceptionName const PGTimedWorkerException   = @"PGTimedWorkerException";
NSExceptionName const PGSemaphoreException     = @"PGSemaphoreException";
NSExceptionName const PGReadWriteLockException = @"PGReadWriteLockException";
NSExceptionName const PGOSErrorException       = @"PGOSErrorException";

NSNotificationName const PGSimpleBufferDataChangedNotification = @"PGSimpleBufferDataChangedNotification";
NSNotificationName const PGSimpleBufferDeallocNotification     = @"PGSimpleBufferDeallocNotification";

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

const NSInteger PGErrorCodeXMLParserWarning      = 300;
const NSInteger PGErrorCodeXMLParserAlreadyRun   = 301;
const NSInteger PGErrorCodeXMLParserError        = 302;
const NSInteger PGErrorCodeXMLParserFatalError   = 303;
const NSInteger PGErrorCodeXMLParserStructError  = 304;
const NSInteger PGErrorCodeXMLParserUnknownError = 305;

NSString *const PGErrorMsgXMLParserAlreadyRun   = @"XML Parser has already run.";
NSString *const PGErrorMsgXMLParserError        = @"PGErrorMsgXMLParserError";
NSString *const PGErrorMsgXMLParserFatalError   = @"PGErrorMsgXMLParserFatalError";
NSString *const PGErrorMsgXMLParserStructError  = @"PGErrorMsgXMLParserStructError";
NSString *const PGErrorMsgXMLParserUnknownError = @"Unknown parser error.";
NSString *const PGErrorMsgXMLParserWarning      = @"PGErrorMsgXMLParserWarning";

NSString *const PGUnderlyingExceptionKey = @"PGUnderlyingExceptionKey";

NSString *const PGErrorMsgAbstractClass           = @"Instances of abstract class \"%@\" cannot be created.";
NSString *const PGErrorMsgAbstractMethod          = @"The method \"%@\" is abstract.";
NSString *const PGErrorMsgBadConstructor          = @"The selector \"%@\" cannot be used to create instances of the class \"%@\".";
NSString *const PGErrorMsgBadRegexPattern         = @"Invalid regular expression pattern";
NSString *const PGErrorMsgCannotCompare           = @"Class %@ cannot be compared to class %@.";
NSString *const PGErrorMsgCannotRotateNode        = @"Cannot rotate node to the %@ because there is no child node to the %@";
NSString *const PGErrorMsgIndexOutOfBounds        = @"Index out of bounds.";
NSString *const PGErrorMsgIndexOutOfBoundsShow    = @"Index out of bounds: %@ > %@";
NSString *const PGErrorMsgInputStreamClosed       = @"Input stream closed.";
NSString *const PGErrorMsgInvalidConstructor      = @"Do not use this constructor.";
NSString *const PGErrorMsgNoData                  = @"No data to copy.";
NSString *const PGErrorMsgNoDelegate              = @"No delegate set.";
NSString *const PGErrorMsgNoDirectCreation        = @"You cannot directly create and instance of this class: %@";
NSString *const PGErrorMsgNoInputStream           = @"No input stream.";
NSString *const PGErrorMsgNoModificationAllowed   = @"No modification allowed.";
NSString *const PGErrorMsgRangeOutOfBounds        = @"Range {%lu, %lu} out of bounds; max length %lu";
NSString *const PGErrorMsgRegexPatternIsNULL      = @"Regex pattern is NULL.";
NSString *const PGErrorMsgRotateCountTooLarge     = @"Rotate count is greater than the length of the buffer.";
NSString *const PGErrorMsgUnexpectedEndOfInput    = @"Unexpected end of input.";
NSString *const PGErrorMsgUnknowError             = @"Unknown Error.";
NSString *const PGErrorMsgUnknownInputStreamError = @"Unknown input stream error.";
NSString *const PGErrorMsgZeroLengthBuffer        = @"Zero length buffer size.";
