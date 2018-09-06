/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDynamicBuffers.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 4/5/18
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

#import "PGDynamicBuffers.h"
#import "PGDynamicBufferTools.h"

#define __pg_dq_getq(q) ((q)?((q)->_q):(nil))

@interface PGDynamicByteQueue()

    -(void)_deallocQueue;

    -(BOOL)_isEqualToQueue:(PGDynamicByteQueue *)other;

    -(NSInteger)performOperation:(PGDynamicByteBufferOpBlock)opBlock byteQueue:(PGByteQueuePtr)byteQueue error:(NSError **)error;

@end

@implementation PGDynamicByteQueue {
        NSRecursiveLock *_lck;
        PGByteQueuePtr  _q;
    }

    -(instancetype)init {
        self = [super init];
        if(self) _q = PGByteQueueCreate(PGByteQueueDefaultInitialSize);
        return self;
    }

    -(instancetype)initWithInitialSize:(NSUInteger)initialSize {
        self = [super init];
        if(self) _q = PGByteQueueCreate(initialSize);
        return self;
    }

    -(instancetype)initWithNSData:(NSData *)nsData {
        self = [super init];
        if(self) _q = PGByteQueueCreate(nsData);
        return self;
    }

    -(instancetype)initWithBytes:(const void *)bytes length:(NSUInteger)length {
        self = [super init];
        if(self) _q = ((bytes && length) ? PGByteQueueCreate(bytes, length) : PGByteQueueCreate(PGByteQueueDefaultInitialSize));
        return self;
    }

    -(instancetype)initWithQueue:(PGDynamicByteQueue *)q {
        self = [super init];
        if(self) _q = ((q && q->_q && q->_q->qbuffer && q->_q->qsize) ? PGByteQueueCreate(q->_q) : PGByteQueueCreate(PGByteQueueDefaultInitialSize));
        return self;
    }

#pragma mark Private Properties

#pragma mark Private Methods

    -(void)_deallocQueue {
        PGByteQueueDestroy(_q);
        _q = NULL;
    }

    -(BOOL)_isEqualToQueue:(PGDynamicByteQueue *)other {
        [self lock];
        [other lock];
        @try {
            return PGByteQueueCompare(_q, __pg_dq_getq(other));
        }
        @finally {
            [other unlock];
            [self unlock];
        }
    }

#pragma mark Public Properties

    -(NSUInteger)count {
        [self lock];
        NSUInteger c = PGByteQueueCount(_q);
        [self unlock];
        return c;
    }

    -(BOOL)isEmpty {
        [self lock];
        BOOL e = (_q->qhead == _q->qtail);
        [self unlock];
        return e;
    }

    -(BOOL)secure {
        [self lock];
        BOOL s = (_q ? _q->secure : NO);
        [self unlock];
        return s;
    }

    -(void)setSecure:(BOOL)secure {
        [self lock];
        if(_q) _q->secure = secure;
        [self unlock];
    }

#pragma mark Public Methods

    -(void)dealloc {
        [self _deallocQueue];
    }

    -(BOOL)isEqual:(id)other {
        return (other && ((self == other) || ([other isKindOfClass:[self class]] && [self _isEqualToQueue:other])));
    }

    -(BOOL)isEqualToQueue:(PGDynamicByteQueue *)other {
        return (other && ((self == other) || [self _isEqualToQueue:other]));
    }

    -(NSUInteger)hash {
        return 0;
    }

    -(void)queue:(NSByte)byte {
        [self lock];
        @try { PGByteQueueQueue(_q, byte); } @finally { [self unlock]; }
    }

    -(void)queue:(const NSByte *)buffer length:(NSUInteger)length {
        [self lock];
        @try { PGByteQueueQueue(_q, buffer, length); } @finally { [self unlock]; }
    }

    -(void)requeue:(NSByte)byte {
        [self lock];
        @try { PGByteQueueRequeue(_q, byte); } @finally { [self unlock]; }
    }

    -(void)requeue:(const NSByte *)buffer length:(NSUInteger)length {
        [self lock];
        @try { PGByteQueueRequeue(_q, buffer, length); } @finally { [self unlock]; }
    }

    -(NSInteger)dequeue {
        [self lock];
        @try { return PGByteQueueDequeue(_q); } @finally { [self unlock]; }
    }

    -(NSUInteger)dequeue:(NSByte *)buffer maxLength:(NSUInteger)length {
        [self lock];
        @try { return PGByteQueueDequeue(_q, buffer, length); } @finally { [self unlock]; }
    }

    -(NSInteger)pop {
        [self lock];
        @try { return PGByteQueuePop(_q); } @finally { [self unlock]; }
    }

    -(NSUInteger)pop:(NSByte *)buffer maxLength:(NSUInteger)length {
        [self lock];
        @try { return PGByteQueuePop(_q, buffer, length); } @finally { [self unlock]; }
    }

    -(NSInteger)performOperation:(PGDynamicByteBufferOpBlock)opBlock byteQueue:(PGByteQueuePtr)byteQueue error:(NSError **)error {
        return opBlock(byteQueue->qbuffer, byteQueue->qsize, &byteQueue->qhead, &byteQueue->qtail, error);
    }

    -(NSInteger)performOperation:(PGDynamicByteBufferOpBlock)opBlock restoreOnExceptionOrError:(BOOL)restoreFlag error:(NSError **)error {
        NSError   *e = nil;
        NSInteger i  = 0;

        if(restoreFlag) {
            PGByteQueuePtr tq = PGByteQueueCreate(_q);

            @try {
                i = [self performOperation:opBlock byteQueue:_q error:&e];

                if(e) {
                    PGByteQueueDestroy(_q);
                    _q = tq;
                }
                else {
                    PGByteQueueDestroy(tq);
                }
            }
            @catch(NSException *ex) {
                PGByteQueueDestroy(_q);
                _q = tq;
                @throw ex;
            }
        }
        else {
            i = [self performOperation:opBlock byteQueue:_q error:&e];
        }

        if(error) *error = e;
        return i;
    }

    -(NSData *)getNSData {
        [self lock];
        @try { return PGByteQueueGetNSData(_q); } @finally { [self unlock]; }
    }

    -(NSData *)getNSData:(NSUInteger)length {
        [self lock];
        @try { return PGByteQueueGetNSData(_q, length); } @finally { [self unlock]; }
    }

    -(NSString *)getNSString {
        [self lock];
        @try { return PGByteQueueGetNSString(_q, NSUTF8StringEncoding); } @finally { [self unlock]; }
    }

    -(NSString *)getNSStringOfLength:(NSUInteger)length {
        [self lock];
        @try { return PGByteQueueGetNSString(_q, NSUTF8StringEncoding, length); } @finally { [self unlock]; }
    }

    -(NSString *)getNSString:(NSStringEncoding)encoding {
        [self lock];
        @try { return PGByteQueueGetNSString(_q, encoding); } @finally { [self unlock]; }
    }

    -(NSString *)getNSString:(NSStringEncoding)encoding length:(NSUInteger)length {
        [self lock];
        @try { return PGByteQueueGetNSString(_q, encoding, length); } @finally { [self unlock]; }
    }

    -(char *)getUTF8String {
        [self lock];
        @try { return strdup(PGByteQueueCount(_q) ? PGByteQueueGetNSString(_q, NSUTF8StringEncoding).UTF8String : ""); } @finally { [self unlock]; }
    }

    -(char *)getUTF8String:(NSUInteger)length {
        [self lock];
        @try { return strdup((length && PGByteQueueCount(_q)) ? PGByteQueueGetNSString(_q, NSUTF8StringEncoding, length).UTF8String : ""); } @finally { [self unlock]; }
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        return [(PGDynamicByteQueue *)[[self class] allocWithZone:zone] initWithQueue:self];
    }

    -(void)lock {
        PGSETIFNIL(self, _lck, [NSRecursiveLock new]);
        [_lck lock];
    }

    -(void)unlock {
        [_lck unlock];
    }

@end
