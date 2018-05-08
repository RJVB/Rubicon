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

#import "PGInternal.h"

const NSUInteger PGDynByteQueueDefaultInitialSize = ((NSUInteger)(64 * 1024));

#define NSUIntegerSize sizeof(NSUInteger)

typedef union {
    NSByte     bytes[NSUIntegerSize];
    NSUInteger hash;
}                PGByteWord;

typedef struct {
    NSUInteger qsize;
    NSUInteger qhead;
    NSUInteger qtail;
    NSBytePtr  qbuffer;
}                PGByteQueue;

NSUInteger calculateQueueContentsHash(const NSByte *qbuffer, NSUInteger qhead, NSUInteger qtail, NSUInteger qsize, NSUInteger hash);

#define ADDPTR(p, a, s) ((p)=(((p)+(a))%(s)))
#define INCPTR(p, s)    (ADDPTR((p),(1),(s)))
#define DECPTR(p, s)    ((p)=(((p)?:(s))-(1)))
#define CHASH(a, b)     (((a)*(31u))+(b))
#define QCOUNT(h, t, s) (((h)<(t))?((t)-(h)):(((s)-(h))+(t)))

NS_INLINE NSUInteger umin(NSUInteger ui1, NSUInteger ui2) {
    return ((ui1 <= ui2) ? ui1 : ui2);
}

NS_INLINE NSUInteger umax(NSUInteger ui1, NSUInteger ui2) {
    return ((ui2 > ui1) ? ui2 : ui1);
}

NS_INLINE PGByteQueue *createQueue(NSUInteger initialSize) {
    PGByteQueue *q = PGRealloc(NULL, sizeof(PGByteQueue));
    q->qsize   = (initialSize ? umax(initialSize, 5) : PGDynByteQueueDefaultInitialSize);
    q->qbuffer = PGRealloc(NULL, q->qsize);
    q->qhead   = 0;
    q->qtail   = 0;
    return q;
}

NS_INLINE PGByteQueue *makeExactCopy(const PGByteQueue *src) {
    PGByteQueue *copy = createQueue(src->qsize);
    copy->qtail = src->qtail;
    copy->qhead = src->qhead;

    if(src->qhead != src->qtail) {
        BOOL sad = (src->qhead > src->qtail);
        memcpy((copy->qbuffer + copy->qhead), (src->qbuffer + src->qhead), ((sad ? src->qsize : src->qtail) - src->qhead));
        if(sad && src->qtail) memcpy(copy->qbuffer, src->qbuffer, src->qtail);
    }

    return copy;
}

NS_INLINE NSUInteger queueCount(const PGByteQueue *q) {
    return QCOUNT(q->qhead, q->qtail, q->qsize);
}

NS_INLINE NSByte dequeue(PGByteQueue *q) {
    NSByte b = q->qbuffer[q->qhead];
    INCPTR(q->qhead, q->qsize);
    return b;
}

NS_INLINE NSByte unqueue(PGByteQueue *q) {
    return q->qbuffer[DECPTR(q->qtail, q->qsize)];
}

NS_INLINE void queue(PGByteQueue *q, NSByte b) {
    q->qbuffer[q->qtail] = b;
    INCPTR(q->qtail, q->qsize);
}

NS_INLINE void requeue(PGByteQueue *q, NSByte b) {
    q->qbuffer[DECPTR(q->qhead, q->qsize)] = b;
}

NS_INLINE NSUInteger calculateQueueHash(const PGByteQueue *q) {
    return calculateQueueContentsHash(q->qbuffer, q->qhead, q->qtail, q->qsize, CHASH(1, queueCount(q)));
}

@interface PGDynamicByteQueue()

    @property(readonly) PGByteQueue *queue;

    -(instancetype)initWithByteQueue:(PGDynamicByteQueue *)queue NS_DESIGNATED_INITIALIZER;

    -(void)ensureRoomFor:(NSUInteger)delta;

@end

@implementation PGDynamicByteQueue {
        NSRecursiveLock *_lock;
        dispatch_once_t _lockOnce;
        NSUInteger      _hash;
        BOOL            _rehash;
    }

    -(instancetype)init {
        self = [super init];
        if(self) [self createBuffer:PGDynByteQueueDefaultInitialSize];
        return self;
    }

    -(instancetype)initWithInitialSize:(NSUInteger)initialSize {
        self = [super init];
        if(self) [self createBuffer:initialSize];
        return self;
    }

    -(instancetype)initWithByteQueue:(PGDynamicByteQueue *)queue {
        [queue lock];
        @try {
            self = [super init];
            if(self) _queue = makeExactCopy(queue.queue);
            return self;
        }
        @finally { [queue unlock]; }
        return self;
    }

    -(void)dealloc {
        if(_queue) {
            free(_queue->qbuffer);
            free(_queue);
        }
    }

    -(void)createBuffer:(NSUInteger)initialSize {
        _queue  = createQueue(initialSize);
        _rehash = YES;
    }

    -(void)lock {
        dispatch_once(&_lockOnce, ^{ self->_lock = [NSRecursiveLock new]; });
        [_lock lock];
    }

    -(void)unlock {
        [_lock unlock];
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        return [(PGDynamicByteQueue *)[[self class] allocWithZone:zone] initWithByteQueue:self];
    }

    -(NSUInteger)count {
        [self lock];
        @try { return queueCount(_queue); } @finally { [self unlock]; }
    }

    -(BOOL)isEmpty {
        [self lock];
        @try { return (_queue->qhead == _queue->qtail); } @finally { [self unlock]; }
    }

    -(void)growBufferTo:(NSUInteger)newSize {
        _queue->qbuffer = PGRealloc(_queue->qbuffer, newSize);

        if(_queue->qtail < _queue->qhead) {
            if(_queue->qtail) memmove((_queue->qbuffer + _queue->qsize), _queue->qbuffer, _queue->qtail);
            _queue->qtail += _queue->qsize;
        }

        _queue->qsize = newSize;
    }

    -(NSUInteger)getSizeForAdditionalBytes:(NSUInteger)delta {
        NSUInteger ncount = (queueCount(_queue) + delta);
        NSUInteger nsize  = _queue->qsize;
        while(ncount >= nsize) nsize *= 2;
        return nsize;
    }

    -(void)ensureRoomFor:(NSUInteger)delta {
        if((queueCount(_queue) + delta) >= _queue->qsize) [self growBufferTo:[self getSizeForAdditionalBytes:delta]];
    }

    -(BOOL)isEqual:(id)other {
        return (other && ((other == self) || ([other isKindOfClass:[self class]] && [self _isEqualToQueue:other])));
    }

    -(BOOL)isEqualToQueue:(PGDynamicByteQueue *)queue {
        return (queue && ((queue == self) || [self _isEqualToQueue:queue]));
    }

    -(BOOL)_isEqualToQueue:(PGDynamicByteQueue *)queue {
        [self lock];

        @try {
            PGByteQueue *oqueue = queue.queue;
            NSUInteger  c1      = queueCount(_queue);

            if(c1 == queueCount(oqueue)) {
                if(c1) {
                    NSUInteger h1 = _queue->qhead;
                    NSUInteger h2 = oqueue->qhead;

                    for(NSUInteger i = 0; i < c1; i++) {
                        if(_queue->qbuffer[h1] != oqueue->qbuffer[h2]) return NO;
                        INCPTR(h1, _queue->qsize);
                        INCPTR(h2, oqueue->qsize);
                    }
                }

                return YES;
            }

            return NO;
        }
        @finally {
            [self unlock];
        }
    }

    -(NSUInteger)hash {
        /*
         * Because hashing could possibly be a very expensive operation
         * we will simply store the hash value and then recalculate
         * only when the queue changes. That way we won't waste
         * time calculating the hash when it hasn't changed.
         */
        [self lock];

        @try {
            if(_rehash) {
                _hash   = calculateQueueHash(_queue);
                _rehash = NO;
            }

            return _hash;
        }
        @finally { [self unlock]; }
    }

    -(void)queue:(NSByte)byte {
        [self lock];
        @try {
            [self ensureRoomFor:1];
            queue(_queue, byte);
            _rehash = YES;
        }
        @finally { [self unlock]; }
    }

    -(void)queue:(const NSBytePtr)buffer offset:(NSUInteger)offset length:(NSUInteger)length {
        if(buffer && length) [self queue:(buffer + offset) length:length];
    }

    -(void)queue:(const NSBytePtr)buffer length:(NSUInteger)length {
        [self lock];
        @try {
            if(buffer && length) {
                [self ensureRoomFor:length];
                for(NSUInteger i = 0; i < length; i++) queue(_queue, buffer[i]);
                _rehash = YES;
            }
        }
        @finally { [self unlock]; }
    }

    -(void)requeue:(NSByte)byte {
        [self lock];
        @try {
            [self ensureRoomFor:1];
            requeue(_queue, byte);
            _rehash = YES;
        }
        @finally { [self unlock]; }
    }

    -(void)requeue:(const NSBytePtr)buffer offset:(NSUInteger)offset length:(NSUInteger)length {
        if(buffer && length) [self requeue:(buffer + offset) length:length];
    }

    -(void)requeue:(const NSBytePtr)buffer length:(NSUInteger)length {
        [self lock];
        @try {
            if(buffer && length) {
                [self ensureRoomFor:length];
                while(length) requeue(_queue, buffer[--length]);
                _rehash = YES;
            }
        }
        @finally { [self unlock]; }
    }

    -(NSInteger)dequeue {
        [self lock];
        @try {
            if(queueCount(_queue)) {
                NSByte b = dequeue(_queue);
                _rehash = YES;
                return b;
            }
            else {
                return EOF;
            }
        }
        @finally { [self unlock]; }
    }

    -(NSInteger)dequeue:(NSBytePtr)buffer maxLength:(NSUInteger)length {
        if(buffer && length) {
            [self lock];
            @try {
                NSUInteger     cc = umin(queueCount(_queue), length);
                for(NSUInteger i  = 0; i < cc; i++) buffer[i] = dequeue(_queue);
                _rehash = YES;
                return cc;
            }
            @finally { [self unlock]; }
        }
        else if(buffer) return 0;
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL pointer."];
    }

    -(NSInteger)unqueue {
        [self lock];
        @try {
            if(queueCount(_queue)) {
                NSByte b = unqueue(_queue);
                _rehash = YES;
                return b;
            }
            else {
                return EOF;
            }
        }
        @finally { [self unlock]; }
    }

    -(NSInteger)unqueue:(NSBytePtr)buffer maxLength:(NSUInteger)length {
        if(buffer && length) {
            [self lock];
            @try {
                NSUInteger cc = umin(queueCount(_queue), length), i = cc;
                while(i) buffer[--i] = unqueue(_queue);
            }
            @finally { [self unlock]; }
        }
        else if(buffer) return 0;
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL pointer."];
    }

    -(void)normalize {
        if(_queue->qhead) {
            if(_queue->qtail == _queue->qhead) {
                _queue->qhead = _queue->qtail = 0;
            }
            else if(_queue->qhead) {
                NSUInteger sz = _queue->qsize;

                if(_queue->qtail < _queue->qhead) {
                    if(_queue->qtail == 0) _queue->qtail = sz; else [self growBufferTo:(sz * 2)];
                }

                _queue->qtail = (_queue->qtail - _queue->qhead);
                memmove(_queue->qbuffer, (_queue->qbuffer + _queue->qhead), _queue->qtail);
                _queue->qhead = 0;

                if(sz < _queue->qsize) {
                    NSUInteger nsz = umax(sz, (_queue->qtail + 1));
                    _queue->qbuffer = PGRealloc(_queue->qbuffer, nsz);
                    _queue->qsize   = nsz;
                }
            }
        }
    }

    -(NSInteger)performOperation:(PGDynamicByteBufferOpBlock)opBlock restoreOnExceptionOrError:(BOOL)restoreFlag error:(NSError **)error {
        NSInteger retvalue = 0;

        if(opBlock) {
            [self lock];

            @try {
                NSError *err = nil;

                PGByteQueue *q = _queue;
                if(restoreFlag) {
                    PGByteQueue *backup = makeExactCopy(q);

                    @try {
                        retvalue = opBlock(backup->qbuffer, backup->qsize, &backup->qhead, &backup->qtail, &err);
                        if(!err) PGSwapPtr((void **)&backup, (void **)&_queue);
                    }
                    @finally {
                        free(backup->qbuffer);
                        free(backup);
                    }
                }
                else {
                    retvalue = opBlock(q->qbuffer, q->qsize, &q->qhead, &q->qtail, &err);
                }

                PGSetReference(error, err);
            }
            @finally {
                /*
                 * We have no way of honestly knowing if the queue was changed or not so we'll just
                 * rehash just in case.
                 */
                _rehash = YES;
                [self unlock];
            }
        }

        return retvalue;
    }

@end

NSUInteger calculateQueueContentsHash(const NSByte *qbuffer, NSUInteger qhead, NSUInteger qtail, NSUInteger qsize, NSUInteger hash) {
    PGByteWord x = { .hash = 0 };

    while(qhead != qtail) {
        if(QCOUNT(qhead, qtail, qsize) < NSUIntegerSize) {
            x.hash = 0;
            for(NSUInteger i = 0; (qhead != qtail); INCPTR(qhead, qsize)) x.bytes[i++] = qbuffer[qhead];
        }
        else {
            memcpy(x.bytes, (qbuffer + qhead), NSUIntegerSize);
            ADDPTR(qhead, NSUIntegerSize, qsize);
        }

        hash = CHASH(hash, x.hash);
    }

    return hash;
}
