/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGBinaryTreeKVNode.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/22/16 10:09 AM
 * DESCRIPTION:
 *
 * Copyright © 2016 Project Galen. All rights reserved.
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

#import "PGBinaryTreeKVNode.h"

@implementation PGBinaryTreeKVNode {
		id _value;
	}

	-(instancetype)initWithValue:(id)value forKey:(id<NSCopying>)key {
		return (self = [super initWithValue:value forKey:key]);
	}

	-(id)value {
		return _value;
	}

	-(void)setValue:(id)value {
		_value = value;
	}

@end
