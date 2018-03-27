/******************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: NSData(PGData).m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 7/15/17 11:40 AM
 * DESCRIPTION:
 *
 * Copyright © 2017 Project Galen. All rights reserved.
 *
 * "It can hardly be a coincidence that no language on Earth has ever produced the expression 'As pretty as an airport.' Airports
 * are ugly. Some are very ugly. Some attain a degree of ugliness that can only be the result of special effort."
 * - Douglas Adams from "The Long Dark Tea-Time of the Soul"
 *
 * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided
 * that the above copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#import "PGInternal.h"

static const NSUInteger PGDataReadBufferSize = 8196;

@implementation NSData(PGData)

    +(NSData *)dataFromFileDescriptor:(int)fd closeOnFinish:(BOOL)willClose error:(NSError **)error {
        NSData *results = nil;

        if(fd >= 0) {
            NSMutableData *data = [NSMutableData dataWithCapacity:PGDataReadBufferSize];
            NSByte        buffer[PGDataReadBufferSize];
            ssize_t       ss    = read(fd, buffer, PGDataReadBufferSize);

            while(ss > 0) {
                [data appendBytes:buffer length:(NSUInteger)ss];
                ss = read(fd, buffer, PGDataReadBufferSize);
            }

            if(willClose) close(fd);

            if(ss == 0) {
                results = [NSData dataWithData:data];
                if(error) *error = nil;
            }
            else if(error) {
                *error = [NSError errorWithDomain:PGErrorDomain code:errno userInfo:@{ NSLocalizedDescriptionKey: PGStrError(errno) }];
            }
        }
        else if(error) {
            *error = [NSError errorWithDomain:PGErrorDomain code:1000 userInfo:@{ NSLocalizedDescriptionKey: @"Stream not open." }];
        }

        return results;
    }

@end
