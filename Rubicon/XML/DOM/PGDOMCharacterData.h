/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGCharacterData.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 2/8/17 7:23 PM
 *  VISIBILITY: Private
 * DESCRIPTION:
 *
 * Copyright © 2017  Project Galen. All rights reserved.
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

#ifndef __Rubicon_PGCharacterData_H_
#define __Rubicon_PGCharacterData_H_

#import <Rubicon/PGDOMNode.h>

@interface PGDOMCharacterData : PGDOMChildNode

	@property(nonatomic, copy) NSString       *data;
	@property(nonatomic, readonly) NSUInteger length;

	-(instancetype)init;

	-(void)appendData:(NSString *)data;

	-(void)deleteDataAtOffset:(NSUInteger)offset length:(NSUInteger)len;

	-(void)insertData:(NSString *)data offset:(NSUInteger)offset;

	-(void)replaceDataAtOffset:(NSUInteger)offset length:(NSUInteger)len withData:(NSString *)data;

	-(NSString *)substringAtOffset:(NSUInteger)offset length:(NSUInteger)len;

@end

#endif //__Rubicon_PGCharacterData_H_
