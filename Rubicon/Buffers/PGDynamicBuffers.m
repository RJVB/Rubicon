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

#import "PGDynamicBufferTools.h"

const NSUInteger PGDynByteQueueMinSize            = ((NSUInteger)(5));
const NSUInteger PGDynByteQueueDefaultInitialSize = ((NSUInteger)(64 * 1024));

@implementation PGDynamicByteQueue {
        NSRecursiveLock *_lck;
    }

    @synthesize willShrink = _willShrink;
    @synthesize q = _q;
    @synthesize secure = _secure;

    -(instancetype)init {
        self = [super init];

        if(self) {
            _q = PGCreateByteQueue(PGDynByteQueueDefaultInitialSize);
        }

        return self;
    }

    -(instancetype)initWithInitialSize:(NSUInteger)initialSize {
        self = [super init];

        if(self) {
            _q = PGCreateByteQueue(initialSize);
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

#pragma mark Private Properties

    -(NSUInteger)roomRemaining {
        [self lock];
        NSUInteger c = PGQueueRoomRemaining(self.q);
        [self unlock];
        return c;
    }

#pragma mark Private Methods

    -(void)_deallocQueue {
        PGDestroyByteQueue(self.q, self.secure);
        if(self.secure) self.q = NULL;
    }

    -(void)_ensureRoomFor:(NSUInteger)delta {
        PGByteQueueEnsureRoom(self.q, delta);
    }

    -(void)_unwrapQueue:(NSUInteger)newSize {
        PGNormalizeByteQueue(self.q);
    }

    -(BOOL)_isEqualToQueue:(PGDynamicByteQueue *)other {
        if(other) {
            if(self == other) return YES;
        }
        return NO;
    }

#pragma mark Public Properties

    -(NSUInteger)count {
        [self lock];
        NSUInteger c = PGQueueByteCount(self.q);
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
    }

    -(void)queue:(const NSByte *)buffer length:(NSUInteger)length {
    }

    -(void)requeue:(NSByte)byte {
    }

    -(void)requeue:(const NSByte *)buffer length:(NSUInteger)length {
    }

    -(NSInteger)dequeue {
        return 0;
    }

    -(NSInteger)unqueue {
        return 0;
    }

    -(NSUInteger)dequeue:(NSByte *)buffer maxLength:(NSUInteger)length {
        return 0;
    }

    -(NSUInteger)unqueue:(NSByte *)buffer maxLength:(NSUInteger)length {
        return 0;
    }

    -(NSInteger)performOperation:(PGDynamicByteBufferOpBlock)opBlock restoreOnExceptionOrError:(BOOL)restoreFlag error:(NSError **)error {
        return 0;
    }

    -(NSData *)getNSData {
        return nil;
    }

    -(NSData *)getNSData:(NSUInteger)length {
        return nil;
    }

    -(NSString *)getNSString:(NSStringEncoding)encoding {
        return nil;
    }

    -(char *)getUTF8String:(NSUInteger)length {
        return NULL;
    }

    -(NSString *)getNSString:(NSUInteger)length encoding:(NSStringEncoding)encoding {
        return nil;
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        return nil;
    }

    -(void)lock {
        PGSETIFNIL(self, _lck, [NSRecursiveLock new]);
        [_lck lock];
    }

    -(void)unlock {
        [_lck unlock];
    }

@end
