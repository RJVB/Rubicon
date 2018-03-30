/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGFilterInputStream.m
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

@interface PGFilterInputStream()

    @property(readonly) NSInputStream *inputStream;

@end

@implementation PGFilterInputStream {
    }

    @synthesize inputStream = _inputStream;

    -(instancetype)initWithInputStream:(NSInputStream *)inputStream {
        self = [super init];

        if(self) {
            if(!inputStream) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"inputStream is NULL."];
            _inputStream = inputStream;
        }

        return self;
    }

    -(NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len {
        return [self.inputStream read:buffer maxLength:len];
    }

    -(BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len {
        return [self.inputStream getBuffer:buffer length:len];
    }

    -(BOOL)hasBytesAvailable {
        return self.inputStream.hasBytesAvailable;
    }

    -(void)open {
        [self.inputStream open];
    }

    -(void)close {
        [self.inputStream close];
    }

    -(id<NSStreamDelegate>)delegate {
        return self.inputStream.delegate;
    }

    -(void)setDelegate:(id<NSStreamDelegate>)delegate {
        self.inputStream.delegate = delegate;
    }

    -(id)propertyForKey:(NSStreamPropertyKey)key {
        return [self.inputStream propertyForKey:key];
    }

    -(BOOL)setProperty:(id)property forKey:(NSStreamPropertyKey)key {
        return [self.inputStream setProperty:property forKey:key];
    }

    -(NSStreamStatus)streamStatus {
        return self.inputStream.streamStatus;
    }

    -(NSError *)streamError {
        return self.inputStream.streamError;
    }

@end

@implementation NSInputStream(PGFilterInputStream)

    +(PGFilterInputStream *)inputStreamThatFiltersInputStream:(NSInputStream *)inputStream {
        return [[PGFilterInputStream alloc] initWithInputStream:inputStream];
    }

@end

@implementation NSStream(PGStream)

    -(BOOL)shouldClose {
        switch(self.streamStatus) {
            // case NSStreamStatusError: // Might still be good to close even if the connection was severed just to free up any resources.
            case NSStreamStatusNotOpen:
            case NSStreamStatusClosed: return NO;
            default: return YES;
        }
    }

@end
