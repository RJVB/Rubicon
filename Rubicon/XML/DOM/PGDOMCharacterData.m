/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGCharacterData.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 2/8/17 7:23 PM
 * DESCRIPTION:
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

#import "PGDOMCharacterData.h"

@implementation PGDOMCharacterData {
	}

	@synthesize data = _data;

	-(NSUInteger)length {
		return self.data.length;
	}

	-(instancetype)init {
		self = [super init];

		if(self) {
			_data = @"";
		}

		return self;
	}

	-(NSString *)nodeValue {
		return self.data;
	}

	-(void)setNodeValue:(NSString *)nodeValue {
		self.data = nodeValue;
	}

	-(NSString *)textContent {
		return self.data;
	}

	-(void)setTextContent:(NSString *)textContent {
		self.data = textContent;
	}

	-(void)setData:(NSString *)data {
		_data = (data ? [data copy] : @"");
	}

	-(void)appendData:(NSString *)data {
		if(data.length) {
			_data = (self.data.length ? [self.data stringByAppendingString:data] : [data copy]);
		}
	}

	-(void)deleteDataAtOffset:(NSUInteger)offset length:(NSUInteger)len {
		NSString   *odata = self.data;
		NSUInteger x      = odata.length;

		if(offset > x) {
			@throw [NSException exceptionWithName:PGDOMException reason:@"Offset is out of bounds." userInfo:nil];
		}
		else if(len && x) {
			NSUInteger y  = (offset + len);
			NSString   *a = (offset ? ((offset < x) ? [odata substringToIndex:offset] : odata) : @"");
			NSString   *b = ((y < x) ? [odata substringFromIndex:y] : @"");
			_data = [a stringByAppendingString:b];
		}
	}

	-(void)insertData:(NSString *)data offset:(NSUInteger)offset {
		NSString   *odata = self.data;
		NSUInteger x      = odata.length;

		if(offset > x) {
			@throw [NSException exceptionWithName:PGDOMException reason:@"Offset is out of bounds." userInfo:nil];
		}
		else if(data.length) {
			if(x == 0) {
				_data = [data copy];
			}
			else if(offset == 0) {
				_data = [data stringByAppendingString:odata];
			}
			else if(offset == x) {
				_data = [odata stringByAppendingString:data];
			}
			else {
				_data = [[[odata substringToIndex:offset] stringByAppendingString:data] stringByAppendingString:[odata substringFromIndex:offset]];
			}
		}
	}

	-(void)replaceDataAtOffset:(NSUInteger)offset length:(NSUInteger)len withData:(NSString *)data {
		[self deleteDataAtOffset:offset length:len];
		[self insertData:data offset:offset];
	}

	-(NSString *)substringAtOffset:(NSUInteger)offset length:(NSUInteger)len {
		NSString   *odata = self.data;
		NSUInteger x      = odata.length;

		if(offset > x) {
			@throw [NSException exceptionWithName:PGDOMException reason:@"Offset is out of bounds." userInfo:nil];
		}
		else {
			return ((len && (offset < x)) ? [odata substringWithRange:NSMakeRange(offset, MIN(len, (x - offset)))] : @"");
		}
	}

@end
