/************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDefines.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 1/10/17 1:04 PM
 *  VISIBILITY: Private
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

#ifndef __Rubicon_PGDefines_H_
#define __Rubicon_PGDefines_H_

#import <Rubicon/GNUstep.h>
#import <Rubicon/PGCString.h>

typedef const void                 *cvoidp;
typedef void                       *voidp;
typedef long long                  NSLong;
typedef uint8_t                    NSByte;
typedef NSArray<NSString *>        *NSStrArray;
typedef NSMutableArray<NSString *> *NSMutableStrArray;

#ifndef PGBLKOPEN
    #define PGBLKOPEN  do {
    #define PGBLKCLOSE } while(0)
#endif

#ifndef PGSWITCH
    #define PGSWITCH(v) PGBLKOPEN NSString *__pg_casev = [v copy]; BOOL __pg_casefall; { __pg_casefall = NO
    #define PGCASE(v)   } if(__pg_casefall || PGStringsEqual(__pg_casev, (v))) { __pg_casefall = YES;
    #define PGDEFAULT   } { __pg_casefall = YES;
    #define PGSWITCHEND } PGBLKCLOSE

    #define PGSWTTCHC(v) PGBLKOPEN PGCString *__pg_casevc = [PGCString stringWithCString:(v)]; BOOL __pg_casefall; { __pg_casefall = NO
    #define PGCASEC(v)   } if(__pg_casefall || [__pg_casevc isEqualToCString:(v)]) { __pg_casefall = YES;
    #define PGSWITCHCEND } PGBLKCLOSE
#endif

#if defined(CGFLOAT_IS_DOUBLE) && CGFLOAT_IS_DOUBLE
typedef CGFloat NSFloat;  // For the Sheldon Cooper in me.
#else
typedef double NSFloat;
#endif

static const NSUInteger NSUNotFound = NSUIntegerMax;

#if defined(__APPLE__)
    #define PGMaxSemaphoreNameLength 30
#else
    #define PGMaxSemaphoreNameLength 251
#endif

FOUNDATION_EXPORT NSString *const PGErrorDomain;
FOUNDATION_EXPORT NSString *const PGXMLParserErrorDomain;

FOUNDATION_EXPORT const NSInteger PGErrorCodeUnknownError;
FOUNDATION_EXPORT const NSInteger PGErrorCodeExceptionAsError;
FOUNDATION_EXPORT const NSInteger PGErrorCodeCmdLineParseError;
FOUNDATION_EXPORT const NSInteger PGErrorCodeIOError;
FOUNDATION_EXPORT const NSInteger PGErrorCodeRegexPatternIsNULL;

FOUNDATION_EXPORT const NSInteger PGErrorCodeUnknownInputStreamError;
FOUNDATION_EXPORT const NSInteger PGErrorCodeInputStreamClosed;
FOUNDATION_EXPORT const NSInteger PGErrorCodeUnexpectedEndOfInput;
FOUNDATION_EXPORT const NSInteger PGErrorCodeNoDelegate;
FOUNDATION_EXPORT const NSInteger PGErrorCodeNoInputStream;

FOUNDATION_EXPORT const NSInteger PGErrorCodeXMLParserAlreadyRun;
FOUNDATION_EXPORT const NSInteger PGErrorCodeXMLParserWarning;
FOUNDATION_EXPORT const NSInteger PGErrorCodeXMLParserError;
FOUNDATION_EXPORT const NSInteger PGErrorCodeXMLParserFatalError;
FOUNDATION_EXPORT const NSInteger PGErrorCodeXMLParserStructError;

FOUNDATION_EXPORT NSString *const PGUnderlyingExceptionKey;

FOUNDATION_EXPORT NSExceptionName const PGTimedWorkerException;
FOUNDATION_EXPORT NSExceptionName const PGSemaphoreException;
FOUNDATION_EXPORT NSExceptionName const PGReadWriteLockException;
FOUNDATION_EXPORT NSExceptionName const PGOSErrorException;

FOUNDATION_EXPORT NSString *const PGDefaultSemaphoreNamePrefix;

FOUNDATION_EXPORT NSString *const PGErrorMsgBadRegexPattern;
FOUNDATION_EXPORT NSString *const PGErrorMsgRegexPatternIsNULL;
FOUNDATION_EXPORT NSString *const PGErrorMsgUnknowError;
FOUNDATION_EXPORT NSString *const PGErrorMsgInvalidConstructor;
FOUNDATION_EXPORT NSString *const PGErrorMsgInputStreamClosed;
FOUNDATION_EXPORT NSString *const PGErrorMsgUnknownInputStreamError;
FOUNDATION_EXPORT NSString *const PGErrorMsgNoInputStream;
FOUNDATION_EXPORT NSString *const PGErrorMsgUnexpectedEndOfInput;
FOUNDATION_EXPORT NSString *const PGErrorMsgNoDelegate;
FOUNDATION_EXPORT NSString *const PGErrorMsgXMLParserAlreadyRun;
FOUNDATION_EXPORT NSString *const PGErrorMsgCannotRotateNode;
FOUNDATION_EXPORT NSString *const PGErrorMsgNoDirectCreation;
FOUNDATION_EXPORT NSString *const PGErrorMsgIndexOutOfBounds;
FOUNDATION_EXPORT NSString *const PGErrorMsgNoModificationAllowed;
FOUNDATION_EXPORT NSString *const PGErrorMsgAbstractClass;
FOUNDATION_EXPORT NSString *const PGErrorMsgAbstractMethod;
FOUNDATION_EXPORT NSString *const PGErrorMsgBadConstructor;
FOUNDATION_EXPORT NSString *const PGErrorMsgCannotCompare;
FOUNDATION_EXPORT NSString *const PGErrorMsgRangeOutOfBounds;

#if !defined(__PGExceptionTests__)
    #define __PGExceptionTests__    1
    #define PGClassTest(c)          ([self class]==[c class])
    #define PGThrow(e, r)           @throw [NSException exceptionWithName:e reason:r userInfo:nil]
    #define PGClassName(c)          NSStringFromClass([c class])
    #define PGSelName(s)            NSStringFromSelector(s)
    #define PGNoDirectCreationError PGBLKOPEN PGThrow(NSIllegalSelectorException,PGFormat(PGErrorMsgNoDirectCreation,PGClassName(self)));__builtin_unreachable(); PGBLKCLOSE
    #define PGAbstractClassError    PGBLKOPEN PGThrow(NSIllegalSelectorException,PGFormat(PGErrorMsgAbstractClass,PGClassName(self)));__builtin_unreachable(); PGBLKCLOSE
    #define PGBadConstructorError   PGBLKOPEN PGThrow(NSIllegalSelectorException,PGFormat(PGErrorMsgBadConstructor,PGSelName(_cmd),PGClassName(self)));__builtin_unreachable(); PGBLKCLOSE
    #define PGNotImplemented        PGBLKOPEN PGThrow(NSIllegalSelectorException,PGFormat(PGErrorMsgAbstractMethod, PGSelName(_cmd)));__builtin_unreachable(); PGBLKCLOSE
    #define PGAbstractClassTest(c)  PGBLKOPEN if(PGClassTest(c))PGAbstractClassError; PGBLKCLOSE
#endif //__PGExceptionTests__

#endif //__Rubicon_PGDefines_H_
