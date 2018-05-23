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
        NSRecursiveLock *lck;
        NSUInteger      _hash;
        BOOL            _rehash;
        PGByteQueue     *q;
    }

    @synthesize willShrink = _willShrink;

    -(instancetype)init {
        self = [super init];

        if(self) {
            lck = [NSRecursiveLock new];
            [self _createBuffer:PGDynByteQueueDefaultInitialSize];
        }

        return self;
    }

    -(instancetype)initWithInitialSize:(NSUInteger)initialSize {
        self = [super init];

        if(self) {
            lck = [NSRecursiveLock new];
            [self _createBuffer:initialSize];
        }

        return self;
    }

    -(instancetype)initWithByteQueue:(const PGByteQueue *)byteQueue {
        self = [super init];

        if(self) {
            lck     = [NSRecursiveLock new];
            q       = qCreateNormalizedCopy(byteQueue);
            _rehash = YES;
        }

        return self;
    }

    -(instancetype)initWithNSData:(NSData *)nsData {
        self = [self initWithInitialSize:qNextSize(umax(nsData.length, PGDynByteQueueMinSize), 2)];
        if(self && nsData.length) [nsData getBytes:q->qbuffer length:(q->qtail = nsData.length)];
        return self;
    }

    -(instancetype)initWithBytes:(NSByte *)bytes length:(NSUInteger)length {
        self = [self initWithInitialSize:qNextSize(umax(length, PGDynByteQueueMinSize), 2)];
        if(self && length) {
            if(bytes) PGMemCopy(q->qbuffer, bytes, (q->qtail = length));
            else
                PGThrowNullPointerException;
        }
        return self;
    }

    -(void)dealloc {
        q = qDestroyQueue(q);
    }

    -(void)_createBuffer:(NSUInteger)initialSize {
        NSUInteger initSz = (initialSize ? ((initialSize < PGDynByteQueueMinSize) ? PGDynByteQueueMinSize : initialSize) : PGDynByteQueueDefaultInitialSize);
        q       = qCreateNewBuffer(initSz, initSz);
        _rehash = YES;
    }

    -(NSUInteger)count {
        [lck lock];
        @try { return QCOUNT(q); } @finally { [lck unlock]; }
    }

    -(BOOL)isEmpty {
        [lck lock];
        @try { return QEMPTY(q); } @finally { [lck unlock]; }
    }

    -(BOOL)isEqual:(id)other {
        return (other && ((other == self) || ([other isKindOfClass:[self class]] && [self _isEqualToQueue:other])));
    }

    -(BOOL)isEqualToQueue:(PGDynamicByteQueue *)other {
        return (other && ((other == self) || [self _isEqualToQueue:other]));
    }

    -(BOOL)_isEqualToQueue:(PGDynamicByteQueue *)other {
        [lck lock];
        @try {
            [other->lck lock];
            @try {
                PGByteQueue *oq = other->q;
                NSUInteger  qc  = QCOUNT(q);
                return (((q == NULL) && (oq == NULL)) || ((q && oq) && (qc == QCOUNT(oq)) && ((qc == 0) || qCompareQueues(q, oq))));
            }
            @finally { [other->lck unlock]; }
        }
        @finally { [lck unlock]; }
    }

    -(NSUInteger)hash {
        if(_rehash) {
            [lck lock];
            @try {
                if(_rehash) {
                    _hash   = qCalculateHash(q);
                    _rehash = NO;
                }
            }
            @finally { [lck unlock]; }
        }

        return _hash;
    }

    -(void)_ensureSize:(NSUInteger)length {
        qTryGrow(q, (QCOUNT(q) + length));
    }

    -(void)queue:(NSByte)byte {
        [self queue:&byte length:1];
    }

    -(void)queue:(NSByte *)buffer length:(NSUInteger)length {
        if(buffer && length) {
            [lck lock];
            @try {
                [self _ensureSize:length];

                NSUInteger lim = (QWRAPPED(q) ? length : umin(length, (q->qsize - q->qtail)));
                NSUInteger rem = (length - lim);

                PGMemCopy(qTailPostAddP(q, lim), buffer, lim);
                if(rem) PGMemCopy(qTailPostAddP(q, rem), (buffer + lim), rem);
                _rehash = YES;
            }
            @finally { [lck unlock]; }
        }
        else if(length) PGThrowNullPointerException;
    }

    -(void)requeue:(NSByte)byte {
        [self requeue:&byte length:1];
    }

    -(void)requeue:(NSByte *)buffer length:(NSUInteger)length {
        if(buffer && length) {
            [lck lock];
            @try {
                [self _ensureSize:length];

                NSUInteger lim = (QWRAPPED(q) ? length : umin(length, q->qhead));
                NSUInteger rem = (length - lim);

                PGMemCopy(qHeadPreSubP(q, lim), (buffer + rem), lim);
                if(rem) PGMemCopy(qHeadPreSubP(q, rem), buffer, rem);
                _rehash = YES;
            }
            @finally { [lck unlock]; }
        }
        else if(length) PGThrowNullPointerException;
    }

    -(NSInteger)dequeue {
        NSByte b = 0;
        return ([self dequeue:&b maxLength:1] ? b : EOF);
    }

    -(NSUInteger)dequeue:(NSByte *)buffer maxLength:(NSUInteger)length {
        NSUInteger copied = 0;

        if(buffer && length) {
            [lck lock];
            @try {
                copied = umin(length, QCOUNT(q));

                if(copied) {
                    NSUInteger lim = umin(length, ((QWRAPPED(q) ? q->qsize : q->qtail) - q->qhead));
                    NSUInteger rem = (length - lim);

                    PGMemCopy(buffer, qHeadPostAddP(q, lim), lim);
                    if(rem) PGMemCopy((buffer + lim), qHeadPostAddP(q, rem), rem);

                    [self _tryShrink];
                    _rehash = YES;
                }
            }
            @finally { [lck unlock]; }
        }
        else if(length) PGThrowNullPointerException;

        return copied;
    }

    -(NSInteger)unqueue {
        NSByte b = 0;
        return ([self unqueue:&b maxLength:1] ? b : EOF);
    }

    -(NSUInteger)unqueue:(NSByte *)buffer maxLength:(NSUInteger)length {
        NSUInteger copied = 0;

        if(buffer && length) {
            [lck lock];
            @try {
                copied = umin(length, QCOUNT(q));

                if(copied) {
                    NSUInteger lim = umin(copied, (QWRAPPED(q) ? (q->qtail) : QTLHD(q)));
                    NSUInteger rem = (copied - lim);

                    PGMemCopy((buffer + rem), qTailPreSubP(q, lim), lim);
                    if(rem) PGMemCopy(buffer, qTailPreSubP(q, rem), rem);

                    [self _tryShrink];
                    _rehash = YES;
                }
            }
            @finally { [lck unlock]; }
        }
        else if(length) PGThrowNullPointerException;

        return copied;
    }

    -(NSInteger)_performOperation:(PGDynamicByteBufferOpBlock)opBlock byteQueue:(PGByteQueue *)queue error:(NSError **)error {
        return opBlock(queue->qbuffer, queue->qsize, &queue->qhead, &queue->qtail, error);
    }

    -(NSInteger)_performOperation:(PGDynamicByteBufferOpBlock)opBlock error:(NSError **)error {
        NSInteger   rslt  = 0;
        PGByteQueue *copy = qCreateExactCopy(q), *temp = copy;

        @try {
            rslt = [self _performOperation:opBlock byteQueue:temp error:error];
            copy = q;
            q    = temp;
        }
        @finally {
            qDestroyQueue(copy);
        }

        return rslt;
    }

    -(NSInteger)performOperation:(PGDynamicByteBufferOpBlock)opBlock restoreOnExceptionOrError:(BOOL)restoreFlag error:(NSError **)error {
        [lck lock];
        @try {
            NSError   *err = nil;
            NSInteger rslt = (restoreFlag ? [self _performOperation:opBlock error:&err] : [self _performOperation:opBlock byteQueue:q error:&err]);
            [self _tryShrink];
            PGSetReference(error, err);
            return rslt;
        }
        @finally {
            _rehash = YES;
            [lck unlock];
        }
    }

    -(void)_tryShrink {
        if(self.willShrink) qTryShrink(q);
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        [lck lock];
        @try { return [(PGDynamicByteQueue *)[[self class] allocWithZone:zone] initWithByteQueue:q]; } @finally { [lck unlock]; }
    }

    -(NSByte *)_getBytes:(NSUInteger)len {
        BOOL       wpd  = QWRAPPED(q);
        NSUInteger qhd  = (q->qhead);
        NSUInteger lim  = ((wpd ? q->qsize : q->qtail) - q->qhead);
        NSUInteger rem  = (len - lim);
        NSByte     *buf = PGMalloc(len);

        PGMemCopy(buf, QPTR(q, qPostAdd(&qhd, lim, q->qsize)), lim);
        if(rem) PGMemCopy((buf + lim), QPTR(q, qhd), rem);
        return buf;
    }

    -(NSData *)getNSData:(NSUInteger)length {
        [lck lock];
        @try {
            if(QEMPTY(q)) return [NSData new];
            NSUInteger len = umin(length, QCOUNT(q));
            return [[NSData alloc] initWithBytesNoCopy:[self _getBytes:len] length:len freeWhenDone:YES];
        }
        @finally { [lck unlock]; }
    }

    -(NSString *)getNSString:(NSUInteger)length encoding:(NSStringEncoding)encoding {
        [lck lock];
        @try {
            if(QEMPTY(q)) return @"";
            NSUInteger len = umin(length, QCOUNT(q));
            return [[NSString alloc] initWithBytesNoCopy:[self _getBytes:len] length:len encoding:encoding freeWhenDone:YES];
        }
        @finally { [lck unlock]; }
    }

    -(NSData *)getNSData {
        return [self getNSData:QCOUNT(q)];
    }

    -(NSString *)getNSString:(NSStringEncoding)encoding {
        return [self getNSString:QCOUNT(q) encoding:encoding];
    }

    -(char *)getUTF8String:(NSUInteger)length {
        char *str = strdup([self getNSString:length encoding:NSUTF8StringEncoding].UTF8String);
        if(!str) PGThrowOutOfMemoryException;
        return str;
    }

@end
