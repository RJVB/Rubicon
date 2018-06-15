/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGLogger.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/11/18
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

#ifndef RUBICON_PGLOGGER_H
#define RUBICON_PGLOGGER_H

#import <Rubicon/PGTools.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(uint8_t, PGLogLevels) {
    PG_LOG_LEVEL_TRACE = 0, // TRACE
    PG_LOG_LEVEL_INFO,      // INFO
    PG_LOG_LEVEL_DEBUG,     // DEBUG
    PG_LOG_LEVEL_WARN,      // WARNING
    PG_LOG_LEVEL_ERROR      // ERROR
};

@interface PGLogger : NSObject<NSLocking>

    @property /*     */ PGLogLevels    logLevel;
    @property(readonly) NSOutputStream *out;
    @property(readonly) NSOutputStream *err;
    @property(copy)/**/ NSString       *domain;

    -(instancetype)init;

    -(instancetype)initWithLoggingLevel:(PGLogLevels)level;

    -(instancetype)initWithLoggingLevel:(PGLogLevels)level outputStream:(nullable NSOutputStream *)out errorStream:(nullable NSOutputStream *)err;

    -(instancetype)initWithClass:(Class)cls;

    -(instancetype)initWithClass:(Class)cls loggingLevel:(PGLogLevels)level;

    -(instancetype)initWithClass:(Class)cls loggingLevel:(PGLogLevels)level outputStream:(NSOutputStream *)out errorStream:(NSOutputStream *)err;

    -(instancetype)initWithDomain:(NSString *)domain;

    -(instancetype)initWithDomain:(NSString *)domain loggingLevel:(PGLogLevels)level;

    -(instancetype)initWithDomain:(nullable NSString *)domain
                     loggingLevel:(PGLogLevels)level
                     outputStream:(nullable NSOutputStream *)out
                      errorStream:(nullable NSOutputStream *)err NS_DESIGNATED_INITIALIZER;

    -(void)trace:(NSString *)fmt, ...;

    -(void)info:(NSString *)fmt, ...;

    -(void)debug:(NSString *)fmt, ...;

    -(void)warn:(NSString *)fmt, ...;

    -(void)error:(NSString *)fmt, ...;

    -(void)log:(NSString *)str atLevel:(PGLogLevels)level;

    +(instancetype)logger;

    +(instancetype)loggerWithLoggingLevel:(PGLogLevels)level;

    +(instancetype)loggerWithLoggingLevel:(PGLogLevels)level outputStream:(nullable NSOutputStream *)out errorStream:(nullable NSOutputStream *)err;

    +(instancetype)sharedInstance;

    +(instancetype)sharedInstanceWithClass:(Class)cls;

    +(instancetype)sharedInstanceWithDomain:(nullable NSString *)domain;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGLOGGER_H
