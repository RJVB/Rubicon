/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBase64OutputStream.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 3/8/17 11:13 AM
 * DESCRIPTION:
 *     While the class NSData provides base64 encoding operations, these class
 *     require that the entire data set be held in memory before the encoding
 *     begins.  This class, which inherits from NSOutputStream, allows for the
 *     streaming of data to a file and have it encoded "on the fly" without
 *     having to retain the entire data set in memory.
 *
 * Copyright © 2017 Project Galen. All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *******************************************************************************/

#import "PGBase64OutputStream.h"

static const char      CODES[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
static const NSInteger XXX[]   = { 0, 0, 1, 2, 3 };

char *PGBase64Encode(uint8_t ra[3], char ar[4]) {
	// @formatter:off
	ar[0] = CODES[       (ra[0] >> 2)                               ];
	ar[1] = CODES[077 & ((ra[0] << 4) | (ra[1] >> 4))               ];
	ar[2] = CODES[077 &                ((ra[1] << 2) | (ra[2] >> 6))];
	ar[3] = CODES[077 &                                (ra[2])      ];
	// @formatter:on
	return ar;
}

@implementation PGBase64OutputStream {
		uint8_t _inputBuffer[3];
		char    _outputBuffer[4];
		int     _inputIndex;
	}

	/**************************************************************************************************//**
	 * Keeps writting until 4 bytes have been written, the output buffer cannot accept anymore data,
	 * or an error occurs.
	 *
	 * @param buffer the data buffer.
	 * @param results a pointer to an NSInteger that will receive the results.
	 * @return the number of bytes written or zero if an error occurs.
	 ******************************************************************************************************/
	-(NSInteger)write:(const uint8_t *)buffer results:(NSInteger *)results {
		NSUInteger written = 0;

		while(written < 4) {
			NSInteger cc = [super write:(buffer + written) maxLength:(4 - written)];

			if(cc <= 0) {
				if(results) {
					*results = cc;
				}
				return (cc < 0 ? 0 : XXX[written]);
			}

			written += cc;
		}

		if(results) {
			*results = written;
		}
		return XXX[written];
	}

	-(NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len {
		if(buffer && len) {
			@synchronized(self) {
				NSUInteger written = 0;
				NSInteger  results = 0;

				for(NSUInteger i = 0; i < len; i++) {
					_inputBuffer[_inputIndex++] = buffer[i];

					if(_inputIndex >= 3) {
						_inputIndex = 0;
						PGBase64Encode(_inputBuffer, _outputBuffer);
						written += [self write:(uint8_t const *)_outputBuffer results:&results];
						if(results <= 0) {
							return results;
						}
					}
				}

				return written;
			}
		}
		else {
			return [super write:buffer maxLength:len];
		}
	}

	-(void)close {
		[self flush];
		[super close];
	}

	-(void)flush {
		@synchronized(self) {
			if(_inputIndex) {
				for(int i = _inputIndex; i < 3; i++) {
					_inputBuffer[i] = 0;
				}
				PGBase64Encode(_inputBuffer, _outputBuffer);
				_outputBuffer[3] = CODES[64];
				if(_inputIndex == 1) {
					_outputBuffer[2] = CODES[64];
				}
				_inputIndex = 0;
				[self write:(uint8_t const *)_outputBuffer results:NULL];
			}
		}
	}

	-(BOOL)hasSpaceAvailable {
		return super.hasSpaceAvailable;
	}

	-(instancetype)initToMemory {
		self = [super initToMemory];

		if(self) {
			_inputIndex = 0;
		}

		return self;
	}

	-(instancetype)initToBuffer:(uint8_t *)buffer capacity:(NSUInteger)capacity {
		self = [super initToBuffer:buffer capacity:capacity];

		if(self) {
			_inputIndex = 0;
		}

		return self;
	}

	-(instancetype)initWithURL:(NSURL *)url append:(BOOL)shouldAppend {
		self = [super initWithURL:url append:shouldAppend];

		if(self) {
			_inputIndex = 0;
		}

		return self;
	}

	-(instancetype)initToFileAtPath:(NSString *)path append:(BOOL)shouldAppend {
		self = [super initToFileAtPath:path append:shouldAppend];

		if(self) {
			_inputIndex = 0;
		}

		return self;
	}

	+(instancetype)outputStreamToMemory {
		return [[self alloc] initToMemory];
	}

	+(instancetype)outputStreamToBuffer:(uint8_t *)buffer capacity:(NSUInteger)capacity {
		return [[self alloc] initToBuffer:buffer capacity:capacity];
	}

	+(instancetype)outputStreamToFileAtPath:(NSString *)path append:(BOOL)shouldAppend {
		return [[self alloc] initToFileAtPath:path append:shouldAppend];
	}

	+(instancetype)outputStreamWithURL:(NSURL *)url append:(BOOL)shouldAppend {
		return [[self alloc] initWithURL:url append:shouldAppend];
	}

@end
