/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGLogger.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/11/18
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

#import "PGLogger.h"
#import "pthread/pthread.h"
#import "NSString+PGString.h"

typedef NSInteger (*WriteFunc)(id, SEL, const uint8_t *, NSUInteger);

static SEL writeSelect;

NS_INLINE void writeCString(const char *str, NSOutputStream *ostream, WriteFunc writeFunc) {
    if(str) {
        const uint8_t *b = (const uint8_t *)str;
        size_t        l  = strlen(str);

        do {
            NSInteger r = (*writeFunc)(ostream, writeSelect, b, l);
            if(r <= 0) break;
            b += r;
            l -= r;
        }
        while(l);
    }
}

NS_INLINE BOOL statusOK(NSStream *s) {
    switch(s.streamStatus) {
        case NSStreamStatusNotOpen:
        case NSStreamStatusAtEnd:
        case NSStreamStatusClosed:
        case NSStreamStatusError:
            return NO;
        default:
            return YES;
    }
}

NS_INLINE void writeString(NSString *str, NSOutputStream *ostream, WriteFunc writeFunc) {
    if(str.notEmpty) {
        NSStreamStatus sstatus = ostream.streamStatus;
        if(sstatus == NSStreamStatusNotOpen) {
            [ostream open];
            do { sstatus = ostream.streamStatus; }
            while(sstatus == NSStreamStatusOpening);
        }
        if(statusOK(ostream)) writeCString(str.UTF8String, ostream, writeFunc);
    }
}

@interface PGLogger()

    @property(readonly) NSProcessInfo   *pinfo;
    @property(readonly) NSDateFormatter *dtfmt;
    @property(readonly) uint64_t        currentThreadID;

    -(void)logAtLevel:(PGLogLevels)level format:(NSString *)fmt arguments:(va_list)args;

    -(NSString *)prefixWithLoggingLevel:(PGLogLevels)level;

    -(NSString *)getLogLevelName:(PGLogLevels)level;

@end

@implementation PGLogger {
        dispatch_once_t _lckonce;
        NSRecursiveLock *_lck;
        NSProcessInfo   *_pinfo;
        NSDateFormatter *_dtfmt;
        NSString        *_domain;
        WriteFunc       _outFunc;
        WriteFunc       _errFunc;
    }

    @synthesize out = _out;
    @synthesize err = _err;
    @synthesize logLevel = _logLevel;

    -(instancetype)init {
        return (self = [self initWithDomain:nil loggingLevel:PG_LOG_LEVEL_DEBUG outputStream:nil errorStream:nil]);
    }

    -(instancetype)initWithLoggingLevel:(PGLogLevels)level {
        return (self = [self initWithDomain:nil loggingLevel:level outputStream:nil errorStream:nil]);
    }

    -(instancetype)initWithLoggingLevel:(PGLogLevels)level outputStream:(NSOutputStream *)out errorStream:(NSOutputStream *)err {
        return (self = [self initWithDomain:nil loggingLevel:level outputStream:out errorStream:err]);
    }

    -(instancetype)initWithClass:(Class)cls {
        return (self = [self initWithDomain:(cls ? NSStringFromClass(cls) : nil) loggingLevel:PG_LOG_LEVEL_DEBUG outputStream:nil errorStream:nil]);
    }

    -(instancetype)initWithClass:(Class)cls loggingLevel:(PGLogLevels)level {
        return (self = [self initWithDomain:(cls ? NSStringFromClass(cls) : nil) loggingLevel:level outputStream:nil errorStream:nil]);
    }

    -(instancetype)initWithClass:(Class)cls loggingLevel:(PGLogLevels)level outputStream:(NSOutputStream *)out errorStream:(NSOutputStream *)err {
        return (self = [self initWithDomain:(cls ? NSStringFromClass(cls) : nil) loggingLevel:level outputStream:out errorStream:err]);
    }

    -(instancetype)initWithDomain:(NSString *)domain {
        return (self = [self initWithDomain:domain loggingLevel:PG_LOG_LEVEL_DEBUG outputStream:nil errorStream:nil]);
    }

    -(instancetype)initWithDomain:(NSString *)domain loggingLevel:(PGLogLevels)level {
        return (self = [self initWithDomain:domain loggingLevel:level outputStream:nil errorStream:nil]);
    }

    -(instancetype)initWithDomain:(NSString *)domain loggingLevel:(PGLogLevels)level outputStream:(NSOutputStream *)out errorStream:(NSOutputStream *)err {
        self = [super init];

        if(self) {
            _lckonce  = 0;
            _out      = (out ?: [NSOutputStream outputStreamToFileAtPath:@"/dev/stdout" append:YES]);
            _err      = (err ?: (out ?: [NSOutputStream outputStreamToFileAtPath:@"/dev/stderr" append:YES]));
            _logLevel = level;
            _domain   = domain.copy;
            _outFunc  = (WriteFunc)[_out methodForSelector:writeSelect];
            _errFunc  = (WriteFunc)[_err methodForSelector:writeSelect];
        }

        return self;
    }

    +(instancetype)loggerWithLoggingLevel:(PGLogLevels)level outputStream:(NSOutputStream *)out errorStream:(NSOutputStream *)err {
        return [[self alloc] initWithLoggingLevel:level outputStream:out errorStream:err];
    }

    +(instancetype)loggerWithLoggingLevel:(PGLogLevels)level {
        return [[self alloc] initWithLoggingLevel:level];
    }

    +(instancetype)logger {
        return [[self alloc] init];
    }

    -(void)dealloc {
        [self.out close];
        [self.err close];
    }

    -(NSString *)domain {
        if(_domain == nil) { @synchronized(self) { if(_domain == nil) _domain = self.pinfo.arguments.firstObject.lastPathComponent; }}
        return _domain;
    }

    -(void)setDomain:(NSString *)domain {
        @synchronized(self) {
            _domain = domain.copy;
        }
    }

    -(NSProcessInfo *)pinfo {
        if(_pinfo == nil) { @synchronized(self) { if(_pinfo == nil) _pinfo = NSProcessInfo.processInfo; }}
        return _pinfo;
    }

    -(NSDateFormatter *)dtfmt {
        if(_dtfmt == nil) {
            @synchronized(self) {
                if(_dtfmt == nil) {
                    _dtfmt = [[NSDateFormatter alloc] init];
                    _dtfmt.locale     = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
                    _dtfmt.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";
                    _dtfmt.timeZone   = NSTimeZone.systemTimeZone;
                }
            }
        }
        return _dtfmt;
    }

    -(void)lock {
        dispatch_once(&_lckonce, ^{ self->_lck = [NSRecursiveLock new]; });
        [_lck lock];
    }

    -(void)unlock {
        [_lck unlock];
    }

    +(instancetype)sharedInstance {
        return [self sharedInstanceWithDomain:nil];
    }

    +(instancetype)sharedInstanceWithClass:(Class)cls {
        return [self sharedInstanceWithDomain:NSStringFromClass(cls)];
    }

    +(instancetype)sharedInstanceWithDomain:(nullable NSString *)domain {
        static NSRecursiveLock     *_ll       = nil;
        static dispatch_once_t     _llo       = 0;
        static NSMutableDictionary *_instDict = nil;
        PGLogger                   *_instance = nil;

        dispatch_once(&_llo, ^{ _ll = [NSRecursiveLock new]; });
        [_ll lock];
        @try {
            NSString *key = PGFormat(@"%@:%@", (domain ?: @""), NSStringFromClass(self.class));

            if(_instDict == nil) _instDict = [NSMutableDictionary new];
            else _instance = _instDict[key];

            if(_instance == nil) {
                _instance = [(PGLogger *)[self.class alloc] initWithDomain:domain];
                if(_instance) _instDict[key] = _instance;
            }
        }
        @finally { [_ll unlock]; }

        return _instance;
    }

    -(void)logAtLevel:(PGLogLevels)level format:(NSString *)fmt arguments:(va_list)args {
        [self log:[[NSString alloc] initWithFormat:fmt arguments:args] atLevel:level];
    }

    -(void)debug:(NSString *)fmt, ... {
        va_list args;
        va_start(args, fmt);
        [self logAtLevel:PG_LOG_LEVEL_DEBUG format:fmt arguments:args];
        va_end(args);
    }

    -(void)trace:(NSString *)fmt, ... {
        va_list args;
        va_start(args, fmt);
        [self logAtLevel:PG_LOG_LEVEL_TRACE format:fmt arguments:args];
        va_end(args);
    }

    -(void)info:(NSString *)fmt, ... {
        va_list args;
        va_start(args, fmt);
        [self logAtLevel:PG_LOG_LEVEL_INFO format:fmt arguments:args];
        va_end(args);
    }

    -(void)warn:(NSString *)fmt, ... {
        va_list args;
        va_start(args, fmt);
        [self logAtLevel:PG_LOG_LEVEL_WARN format:fmt arguments:args];
        va_end(args);
    }

    -(void)error:(NSString *)fmt, ... {
        va_list args;
        va_start(args, fmt);
        [self logAtLevel:PG_LOG_LEVEL_ERROR format:fmt arguments:args];
        va_end(args);
    }

    -(NSString *)prefixWithLoggingLevel:(PGLogLevels)level {
        return [NSString stringWithFormat:@"[%@][%@@%@][%d:%llu][%@][%@] %%@\n",
                                          [self.dtfmt stringFromDate:[NSDate date]],
                                          self.pinfo.userName,
                                          self.pinfo.hostName,
                                          self.pinfo.processIdentifier,
                                          self.currentThreadID,
                                          [self getLogLevelName:level],
                                          self.domain];
    }

    -(uint64_t)currentThreadID {
        uint64_t tid = 0;
        if(pthread_is_threaded_np()) { if(pthread_threadid_np(NULL, &tid)) tid = (uint64_t)self.pinfo.processIdentifier; }
        return tid;
    }

    -(NSString *)getLogLevelName:(PGLogLevels)level {
        switch(level) {
            case PG_LOG_LEVEL_ERROR:
                return @"ERROR";
            case PG_LOG_LEVEL_WARN:
                return @"WARN ";
            case PG_LOG_LEVEL_DEBUG:
                return @"DEBUG";
            case PG_LOG_LEVEL_TRACE:
                return @"TRACE";
            default:
                return @"INFO ";
        }
    }

    -(void)log:(NSString *)str atLevel:(PGLogLevels)level {
        [self lock];
        @try {
            if(str && (level >= self.logLevel)) {
                NSString *finalString = PGFormat([self prefixWithLoggingLevel:level], str);

                switch(level) {
                    case PG_LOG_LEVEL_ERROR:
                    case PG_LOG_LEVEL_WARN:
                        writeString(finalString, self.err, _errFunc);
                        if(self.err == self.out) break;
                    case PG_LOG_LEVEL_DEBUG:
                    case PG_LOG_LEVEL_TRACE:
                    default:
                        writeString(finalString, self.out, _outFunc);
                        break;
                }
            }
        }
        @finally { [self unlock]; }
    }

    +(void)initialize {
        static dispatch_once_t _once = 0;
        dispatch_once(&_once, ^{ writeSelect = @selector(write:maxLength:); });
    }

@end
