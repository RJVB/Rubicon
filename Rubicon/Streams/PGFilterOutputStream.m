/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGFilterOutputStream.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 2/15/18 2:30 PM
 * DESCRIPTION:
 *     While the class NSData provides base64 encoding operations, these class require that the entire data set be held in memory before the encoding begins.  This class, which
 *     inherits from NSOutputStream, allows for the streaming of data to a file and have it encoded "on the fly" without having to retain the entire data set in memory.
 *
 * Copyright © 2017 Project Galen. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this
 * permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
 * AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#import "PGFilterOutputStream.h"
#import "NSException+PGException.h"
#import "PGInternal.h"

@interface PGFilterOutputStream()

    @property(atomic, retain) NSOutputStream  *out;
    @property(atomic, retain) NSRecursiveLock *rlock;
    @property(atomic) NSUInteger              chunkSize;


@end

@implementation PGFilterOutputStream {
        id<NSStreamDelegate> __weak _delegate;
        NSError                     *_error;
    }

    @synthesize out = _out;
    @synthesize rlock = _rlock;
    @synthesize chunkSize = _chunkSize;

    -(instancetype)initWithOutputStream:(NSOutputStream *)outputStream {
        return (self = [self initWithOutputStream:outputStream chunk:0]);
    }

    -(instancetype)initWithOutputStream:(NSOutputStream *)outputStream chunk:(NSUInteger)chunk {
        self = [super init];

        if(self) {
            if(outputStream) {
                self.rlock     = [NSRecursiveLock new];
                self.out       = outputStream;
                self.chunkSize = chunk;

                _error    = nil;
                _delegate = nil;
            }
            else {
                NSString *reason = NSLocalizedString(@"PGNullOutStream", @"");
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason];
            }
        }

        return self;
    }

    +(instancetype)streamWithOutputStream:(NSOutputStream *)outputStream {
        return [[self alloc] initWithOutputStream:outputStream];
    }

    +(instancetype)streamWithOutputStream:(NSOutputStream *)outputStream chunk:(NSUInteger)chunk {
        return [[self alloc] initWithOutputStream:outputStream chunk:chunk];
    }

    NS_INLINE NSUInteger pgMin(NSUInteger i1, NSUInteger i2) {
        return ((i1 < i2) ? i1 : i2);
    }

    -(NSInteger)write:(const NSByte *)buffer maxLength:(NSUInteger)len {
        [self lock];

        @try {
            _error = nil;

            if(buffer) {
                if(len) {
                    if((self.chunkSize > 0) && (self.chunkSize < len)) {
                        NSUInteger bidx = 0;
                        NSUInteger bcnt = pgMin(self.chunkSize, (len - bidx));

                        while(bidx < len) {
                            NSInteger r = [self writeFiltered:(buffer + bidx) maxLength:bcnt];
                            if(r < 0) return r;
                            if(r == 0) return bidx;
                            bidx += r;
                            bcnt        = pgMin(self.chunkSize, (len - bidx));
                        }

                        return bidx;
                    }

                    return [self writeFiltered:buffer maxLength:len];
                }

                NSDictionary *dict = @{ NSLocalizedDescriptionKey: @"Nothing to write. 'len' is zero." };
                _error = [NSError errorWithDomain:PGErrorDomain code:1002 userInfo:dict];
                return -1;
            }

            NSDictionary *dict = @{ NSLocalizedDescriptionKey: @"Nothing to write. 'buffer' is NULL." };
            _error = [NSError errorWithDomain:PGErrorDomain code:1001 userInfo:dict];
            return -1;
        }
        @finally { [self unlock]; }
    }

    -(NSInteger)writeFiltered:(const NSByte *)buffer maxLength:(NSUInteger)len {
        NSInteger written = 0;

        do {
            NSInteger results = [self.out write:(buffer + written) maxLength:(len - written)];
            if(results < 0) return results;
            if(results == 0) return written;
            written += results;
        }
        while(written < len);

        return written;
    }

    -(BOOL)hasSpaceAvailable {
        [self lock];
        @try { return self.out.hasSpaceAvailable; } @finally { [self unlock]; }
    }

    -(void)open {
        [self lock];
        @try { [self.out open]; } @finally { [self unlock]; }
    }

    -(NSInteger)flush {
        return 0;
    }

    -(void)close {
        [self lock];
        @try { [self _close]; } @finally { [self unlock]; }
    }

    -(void)_close {
        [self flush];
        [self.out close];
    }

    -(id<NSStreamDelegate>)delegate {
        [self lock];
        @try { return (_delegate ? _delegate : self); } @finally { [self unlock]; }
    }

    -(void)setDelegate:(id<NSStreamDelegate>)delegate {
        [self lock];
        @try { _delegate = delegate; } @finally { [self unlock]; }
    }

    -(NSStreamStatus)streamStatus {
        [self lock];
        @try { return self.out.streamStatus; } @finally { [self unlock]; }
    }

    -(NSError *)streamError {
        [self lock];
        @try {
            NSError *e = (_error ?: self.out.streamError);
            _error = nil;
            return e;
        }
        @finally { [self unlock]; }
    }

    -(nullable id)propertyForKey:(NSStreamPropertyKey)key {
        [self lock];
        @try { return [self.out propertyForKey:key]; } @finally { [self unlock]; }
    }

    -(BOOL)setProperty:(nullable id)property forKey:(NSStreamPropertyKey)key {
        [self lock];
        @try { return [self.out setProperty:property forKey:key]; } @finally { [self unlock]; }
    }

    -(void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSRunLoopMode)mode {
        [self lock];
        @try {
            /*
             * TODO: For now we're just going to forward this on to the underlying stream.
             */
            [self.out scheduleInRunLoop:aRunLoop forMode:mode];
        }
        @finally { [self unlock]; }
    }

    -(void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSRunLoopMode)mode {
        [self lock];
        @try {
            /*
             * TODO: For now we're just going to forward this on to the underlying stream.
             */
            [self.out removeFromRunLoop:aRunLoop forMode:mode];
        }
        @finally { [self unlock]; }
    }

    -(void)dealloc {
        [self _close];
        self.rlock = nil;
        self.out   = nil;
    }

    -(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
        /*
         * TODO: Implement?
         */
        if(self == aStream) {
            switch(eventCode) {
                case NSStreamEventOpenCompleted:break;
                case NSStreamEventHasBytesAvailable:break;
                case NSStreamEventHasSpaceAvailable:break;
                case NSStreamEventErrorOccurred:break;
                case NSStreamEventEndEncountered:break;
                case NSStreamEventNone:break;
                default:break;
            }
        }
    }

    -(void)lock {
        [self.rlock lock];
    }

    -(void)unlock {
        [self.rlock unlock];
    }

@end

