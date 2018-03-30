/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGStreamTee.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 3/29/18
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

NS_INLINE BOOL badStatus(NSStreamStatus status) {
    switch(status) {
        case NSStreamStatusAtEnd:
        case NSStreamStatusClosed:
        case NSStreamStatusError: return YES;
        default: return NO;
    }
}

@interface PGStreamTee()

    @property(readonly) BOOL closeOutputWhenClosed;

    -(void)writeBytes:(uint8_t const *)buffer length:(NSUInteger)len;

@end

@implementation PGStreamTee {
    }

    @synthesize outputStream = _outputStream;
    @synthesize closeOutputWhenClosed = _closeOutputWhenClosed;

    -(instancetype)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream closeOutputWhenClosed:(BOOL)flag {
        self = [super initWithInputStream:inputStream];

        if(self) {
            if(!outputStream) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"outputStream is NULL."];
            _outputStream          = outputStream;
            _closeOutputWhenClosed = flag;
        }

        return self;
    }

    -(void)close {
        [super close];
        if(self.closeOutputWhenClosed && self.outputStream.shouldClose) [self.outputStream close];
    }

    -(void)dealloc {
        [self close];
    }

    -(NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len {
        NSInteger cc = [super read:buffer maxLength:len];
        if((len > 0) && (cc > 0)) [self writeBytes:buffer length:len];
        return cc;
    }

    -(BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len {
        uint8_t    *_buffer = NULL;
        NSUInteger _len     = 0;
        BOOL       results  = [super getBuffer:&_buffer length:&_len];

        if(buffer) *buffer = _buffer;
        if(len) *len       = _len;
        if(results) [self writeBytes:_buffer length:_len];
        return results;
    }

    -(void)writeBytes:(uint8_t const *)buffer length:(NSUInteger)len {
        if(len) {
            if(self.outputStream.streamStatus == NSStreamStatusNotOpen) [self.outputStream open];

            while(self.outputStream.streamStatus == NSStreamStatusOpening) /* Just a little spin lock. */;

            if(!badStatus(self.outputStream.streamStatus)) {
                NSInteger cc = 0;

                do {
                    NSInteger res = [self.outputStream write:(buffer + cc) maxLength:(len - cc)];
                    if(res <= 0) break;
                    cc += res;
                }
                while(cc < len);
            }
        }
    }

    +(instancetype)teeWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream closeOutputWhenClosed:(BOOL)flag {
        return [[self alloc] initWithInputStream:inputStream outputStream:outputStream closeOutputWhenClosed:flag];
    }

    +(instancetype)teeWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
        return [[self alloc] initWithInputStream:inputStream outputStream:outputStream closeOutputWhenClosed:YES];
    }

    +(instancetype)teeWithInputStream:(NSInputStream *)inputStream outputURL:(NSURL *)outputURL append:(BOOL)append {
        return [[self alloc] initWithInputStream:inputStream outputStream:[NSOutputStream outputStreamWithURL:outputURL append:append] closeOutputWhenClosed:YES];
    }

    +(instancetype)teeWithInputStream:(NSInputStream *)inputStream outputURL:(NSURL *)outputURL {
        return [[self alloc] initWithInputStream:inputStream outputStream:[NSOutputStream outputStreamWithURL:outputURL append:YES] closeOutputWhenClosed:YES];
    }

    +(instancetype)teeWithInputStream:(NSInputStream *)inputStream filePath:(NSString *)filePath append:(BOOL)append {
        return [[self alloc] initWithInputStream:inputStream outputStream:[NSOutputStream outputStreamToFileAtPath:filePath append:append] closeOutputWhenClosed:YES];
    }

    +(instancetype)teeWithInputStream:(NSInputStream *)inputStream filePath:(NSString *)filePath {
        return [[self alloc] initWithInputStream:inputStream outputStream:[NSOutputStream outputStreamToFileAtPath:filePath append:YES] closeOutputWhenClosed:YES];
    }

    +(instancetype)teeWithInputStream:(NSInputStream *)inputStream temporaryFile:(NSURL **)url {
        NSError *_error = nil;
        NSURL   *_url   = PGTemporaryFile(@"teefile.tmp", &_error);

        if(!_url) @throw (_error ? [_error makeException] : [NSException exceptionWithName:NSGenericException reason:@"Unable to create temporary file."]);
        if(url) *url = _url;

        return [[self alloc] initWithInputStream:inputStream outputStream:[NSOutputStream outputStreamWithURL:_url append:NO] closeOutputWhenClosed:YES];
    }

@end

