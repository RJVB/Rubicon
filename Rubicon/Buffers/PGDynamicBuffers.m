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

const NSUInteger PGDynByteQueueMinSize            = ((NSUInteger)(5));
const NSUInteger PGDynByteQueueDefaultInitialSize = ((NSUInteger)(64 * 1024));

@interface PGDynamicByteQueue()

    @property(readonly) NSUInteger     roomRemaining;
    @property(nullable) PGByteQueuePtr q;

    -(instancetype)initWithByteQueue:(PGByteQueuePtr)q;
@end

@implementation PGDynamicByteQueue {
        NSRecursiveLock *_lck;
    }

    @synthesize willShrink = _willShrink;
    @synthesize q = _q;
    @synthesize secure = _secure;

    -(instancetype)init {
        self = [super init];

        if(self) {
            _q = PGByteQueueCreate(PGDynByteQueueDefaultInitialSize);
        }

        return self;
    }

    -(instancetype)initWithInitialSize:(NSUInteger)initialSize {
        self = [super init];

        if(self) {
            _q = PGByteQueueCreate(initialSize);
        }

        return self;
    }

    -(instancetype)initWithNSData:(NSData *)nsData {
        self = [self initWithInitialSize:MAX(PGDynByteQueueMinSize, nsData.length + 1)];

        if(self) {
            PGByteQueuePtr q = self.q;
            q->qtail = nsData.length;
            if(q->qtail) [nsData getBytes:q->qbuffer length:q->qtail];
        }

        return self;
    }

    -(instancetype)initWithBytes:(const NSByte *)bytes length:(NSUInteger)length {
        self = [self initWithInitialSize:MAX(PGDynByteQueueMinSize, length + 1)];

        if(self) {
            if(!bytes) PGThrowNullPointerException;
            if(length) {
                PGByteQueuePtr q = self.q;
                memcpy(q->qbuffer, bytes, length);
                q->qtail = length;
            }
        }

        return self;
    }

    -(instancetype)initWithByteQueue:(PGByteQueuePtr)q {
        self = [self initWithInitialSize:(q ? q->qsize : PGDynByteQueueMinSize)];

        if(self) {
            if(!q) PGThrowNullPointerException;
            PGByteQueueCopy(self.q, q);
        }

        return self;
    }

    -(instancetype)initWithQueue:(PGDynamicByteQueue *)q {
        return (self = [self initWithByteQueue:q.q]);
    }

#pragma mark Private Properties

    -(NSUInteger)roomRemaining {
        [self lock];
        NSUInteger c = PGByteQueueRoomRemaining(self.q);
        [self unlock];
        return c;
    }

#pragma mark Private Methods

    -(void)_deallocQueue {
        PGByteQueueDestroy(self.q, self.secure);
        if(self.secure) self.q = NULL;
    }

    -(void)_ensureRoomFor:(NSUInteger)delta {
        PGByteQueueEnsureRoom(self.q, delta);
    }

    -(void)_unwrapQueue:(NSUInteger)newSize {
        PGByteQueueNormalize(self.q);
    }

    -(BOOL)_isEqualToQueue:(PGDynamicByteQueue *)other {
        [self lock];
        [other lock];
        @try {
            return PGByteQueueCompare(self.q, other.q);
        }
        @finally {
            [other unlock];
            [self unlock];
        }
    }

#pragma mark Public Properties

    -(NSUInteger)count {
        [self lock];
        NSUInteger c = PGByteQueueCount(self.q);
        [self unlock];
        return c;
    }

    -(BOOL)isEmpty {
        [self lock];
        BOOL e = (self.q->qhead == self.q->qtail);
        [self unlock];
        return e;
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
        @try { PGByteQueueQueue(self.q, byte); } @finally { [self unlock]; }
    }

    -(void)queue:(const NSByte *)buffer length:(NSUInteger)length {
        [self lock];
        @try { PGByteQueueQueue(self.q, buffer, length); } @finally { [self unlock]; }
    }

    -(void)requeue:(NSByte)byte {
        [self lock];
        @try { PGByteQueueRequeue(self.q, byte); } @finally { [self unlock]; }
    }

    -(void)requeue:(const NSByte *)buffer length:(NSUInteger)length {
        [self lock];
        @try { PGByteQueueRequeue(self.q, buffer, length); } @finally { [self unlock]; }
    }

    -(NSInteger)dequeue {
        [self lock];
        @try { return PGByteQueueDequeue(self.q); } @finally { [self unlock]; }
    }

    -(NSUInteger)dequeue:(NSByte *)buffer maxLength:(NSUInteger)length {
        [self lock];
        @try { return PGByteQueueDequeue(self.q, buffer, length); } @finally { [self unlock]; }
    }

    -(NSInteger)pop {
        [self lock];
        @try { return PGByteQueuePop(self.q); } @finally { [self unlock]; }
    }

    -(NSUInteger)pop:(NSByte *)buffer maxLength:(NSUInteger)length {
        [self lock];
        @try { return PGByteQueuePop(self.q, buffer, length); } @finally { [self unlock]; }
    }

    -(NSInteger)performOperation:(PGDynamicByteBufferOpBlock)opBlock restoreOnExceptionOrError:(BOOL)restoreFlag error:(NSError **)error {
        return 0;
    }

    -(NSData *)getNSData {
        [self lock];
        @try { return PGByteQueueGetNSData(self.q); } @finally { [self unlock]; }
    }

    -(NSData *)getNSData:(NSUInteger)length {
        [self lock];
        @try { return PGByteQueueGetNSData(self.q, length); } @finally { [self unlock]; }
    }

    -(NSString *)getNSString {
        [self lock];
        @try { return PGByteQueueGetNSString(self.q, NSUTF8StringEncoding); } @finally { [self unlock]; }
    }

    -(NSString *)getNSStringOfLength:(NSUInteger)length {
        [self lock];
        @try { return PGByteQueueGetNSString(self.q, NSUTF8StringEncoding, length); } @finally { [self unlock]; }
    }

    -(NSString *)getNSString:(NSStringEncoding)encoding {
        [self lock];
        @try { return PGByteQueueGetNSString(self.q, encoding); } @finally { [self unlock]; }
    }

    -(NSString *)getNSString:(NSStringEncoding)encoding length:(NSUInteger)length {
        [self lock];
        @try { return PGByteQueueGetNSString(self.q, encoding, length); } @finally { [self unlock]; }
    }

    -(char *)getUTF8String {
        [self lock];
        @try { return strdup(PGByteQueueCount(self.q) ? PGByteQueueGetNSString(self.q, NSUTF8StringEncoding).UTF8String : ""); } @finally { [self unlock]; }
    }

    -(char *)getUTF8String:(NSUInteger)length {
        [self lock];
        @try { return strdup((length && PGByteQueueCount(self.q)) ? PGByteQueueGetNSString(self.q, NSUTF8StringEncoding, length).UTF8String : ""); } @finally { [self unlock]; }
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        [self lock];
        @try { return [(PGDynamicByteQueue *)[[self class] alloc] initWithByteQueue:self.q]; } @finally { [self unlock]; }
    }

    -(void)lock {
        PGSETIFNIL(self, _lck, [NSRecursiveLock new]);
        [_lck lock];
    }

    -(void)unlock {
        [_lck unlock];
    }

@end
