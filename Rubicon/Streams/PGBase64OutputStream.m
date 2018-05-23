/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBase64OutputStream.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 3/8/17 11:13 AM
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

#import "PGBase64OutputStream.h"

#define INPUT_BLOCK_SIZE  ((NSUInteger)(3))
#define OUTPUT_BLOCK_SIZE ((NSUInteger)(4))
#define MASK(n)           ((NSByte)((n) & (0x3f)))
#define FOOMULT(a)        (((NSUInteger)(a) * INPUT_BLOCK_SIZE) / OUTPUT_BLOCK_SIZE)
#define BAR(a)            (((NSUInteger)(a) / INPUT_BLOCK_SIZE) * OUTPUT_BLOCK_SIZE)
#define MULT(a, m)        (((NSUInteger)(a) / (NSUInteger)(m)) * (NSUInteger)(m))

NSByte *CODES = (NSByte *)"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

void PGEncodeBase64Final(const NSByte *input, NSByte *output, NSInteger remain);

NS_INLINE void PGBase64EncodeBlock(const NSByte *input, NSByte *output) {
    output[0] = CODES[input[0] >> 2];
    output[1] = CODES[MASK(input[0] << 4) | (input[1] >> 4)];
    output[2] = CODES[MASK(input[1] << 2) | (input[2] >> 6)];
    output[3] = CODES[MASK(input[2])];
}

NS_INLINE void PGBase64EncodeFull(const NSByte *input, NSByte *output, NSUInteger inlen, NSUInteger *inidx, NSUInteger *outidx) {
    while((*inidx) < inlen) {
        PGBase64EncodeBlock((input + (*inidx)), (output + (*outidx)));
        (*inidx) += INPUT_BLOCK_SIZE;
        (*outidx) += OUTPUT_BLOCK_SIZE;
    }
}

@implementation PGBase64OutputStream {
        NSByte     _rem[INPUT_BLOCK_SIZE];
        NSUInteger _remlen;
        NSError    *_error;
    }

    -(instancetype)initWithOutputStream:(NSOutputStream *)outputStream {
        self = [super initWithOutputStream:outputStream chunk:(16384 * 3)];

        if(self) {
            _remlen = 0;
            _error  = nil;
        }

        return self;
    }

    -(instancetype)initWithOutputStream:(NSOutputStream *)outputStream chunk:(NSUInteger)chunk {
        self = [super initWithOutputStream:outputStream chunk:chunk];

        if(self) {
            _remlen = 0;
            _error  = nil;
        }

        return self;
    }

    // . Now is the time for all good men
    // LiBO b3cg aXMg dGhl IHRp bWUg Zm9y IGFs bCBn b29k IG1l bg==

    /**
     * Try to fill the 'remainder' block with any bytes from the input buffer.
     *
     * @param s the 'self' pointer.
     * @param in the input buffer.
     * @param ilen the length of the input buffer.
     * @param idx the current pointer into the input buffer.
     * @param rlen the length of the 'remainder' buffer.
     * @return the updated pointer into the input buffer.
     */
    NS_INLINE NSUInteger fillRemainder(PGBase64OutputStream *s, const NSByte *in, NSUInteger ilen, NSUInteger idx, NSUInteger rlen) {
        while((s->_remlen < rlen) && (idx < ilen)) {
            s->_rem[s->_remlen++] = in[idx++];
        }
        return idx;
    }

    /**
     * Encode any remaining bytes from the previous invocation by filling out the input block with one or two bytes from this
     * invocation.
     *
     * @param s the 'self' pointer.
     * @param in the input buffer.
     * @param ilen the length of the input buffer.
     * @param out the output buffer.
     * @param idx the current pointer into the input buffer.
     * @param odx the current pointer into the output buffer.
     * @return 'YES' if we didn't have enough bytes in the input buffer to finish the block.
     */
    NS_INLINE BOOL writeRem(PGBase64OutputStream *s, const NSByte *in, NSUInteger ilen, NSByte *out, NSUInteger *idx, NSUInteger *odx) {
        if(s->_remlen) {
            if(s->_remlen < INPUT_BLOCK_SIZE) {
                *idx = fillRemainder(s, in, ilen, *idx, INPUT_BLOCK_SIZE);
                if(s->_remlen < INPUT_BLOCK_SIZE) return YES;
            }
            s->_remlen = 0;
            *odx = OUTPUT_BLOCK_SIZE;
            PGBase64EncodeBlock(s->_rem, out);
        }

        return NO;
    }

    -(NSInteger)writeFiltered:(const NSByte *)buffer maxLength:(NSUInteger)len {
        if(_remlen > INPUT_BLOCK_SIZE) {
            NSDictionary *dict = @{ NSLocalizedDescriptionKey: @"Internal Inconsistency Error!" };
            _error = [NSError errorWithDomain:PGErrorDomain code:PGErrorCodeIOError userInfo:dict];
            return -1;
        }

        NSUInteger remlen  = _remlen;
        NSUInteger outlen  = BAR(len + remlen);
        NSByte     *output = PGMalloc(outlen * sizeof(NSByte));

        @try {
            NSUInteger inidx  = 0;
            NSUInteger outidx = 0;

            if(writeRem(self, buffer, len, output, &inidx, &outidx)) return inidx;
            PGBase64EncodeFull(buffer, output, (MULT((len - inidx), INPUT_BLOCK_SIZE) + inidx), &inidx, &outidx);

            NSInteger count = [super writeFiltered:output maxLength:outidx];
            if(count <= 0) return count;
            /*
             * We subtract the original number of remaining bytes so that we don't include
             * those in the sent totals for this invocation.
             */
            if(count < outidx) return (FOOMULT(count) - remlen);
            return fillRemainder(self, buffer, len, inidx, (INPUT_BLOCK_SIZE - 1));
        }
        @finally { free(output); }
    }

    -(NSError *)streamError {
        NSError *lerror = nil;
        [self lock];

        @try {
            lerror = (_error ?: super.streamError);
            _error = nil;
        }
        @finally { [self unlock]; }

        return lerror;
    }

    -(NSInteger)flush {
        NSInteger written = 0;
        [self lock];

        @try {
            if(_remlen) {
                NSByte output[OUTPUT_BLOCK_SIZE];
                PGEncodeBase64Final(_rem, output, _remlen);
                _remlen = 0;
                NSInteger res = [super writeFiltered:output maxLength:OUTPUT_BLOCK_SIZE];
                written = ((res > 0) ? (NSInteger)FOOMULT(res) : res);
            }
        }
        @finally { [self unlock]; }

        return written;
    }

@end

void PGEncodeBase64Final(const NSByte *input, NSByte *output, NSInteger remain) {
    if(remain--) {
        /*
         * 'remain' is going to be equal to 0 or 1.
         */
        output[0] = CODES[input[0] >> 2];
        output[3] = '=';

        if(remain) {
            output[1] = CODES[MASK(input[0] << 4) | (input[1] >> 4)];
            output[2] = CODES[MASK(input[1] << 2)];
        }
        else {
            output[1] = CODES[MASK(input[0] << 4)];
            output[2] = '=';
        }
    }
}

char *PGEncodeBase64(const NSByte *input, NSUInteger inlen, NSUInteger *outlen) {
    NSByte *output = NULL;

    if(inlen) {
        /*
         * The size of a char should always be 1 but just in case...
         */
        *outlen = BAR(inlen + (OUTPUT_BLOCK_SIZE - 1));
        output = (NSByte *)PGMalloc((*outlen + 1) * sizeof(NSByte));

        if(output) {
            NSUInteger inidx  = 0;
            NSUInteger outidx = 0;

            PGBase64EncodeFull(input, output, MULT(inlen, INPUT_BLOCK_SIZE), &inidx, &outidx);
            if(inidx < inlen) PGEncodeBase64Final((input + inidx), (output + outidx), (inlen - inidx));
            output[*outlen] = 0;
        }
    }

    return (char *)output;
}
