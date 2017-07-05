/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGEmptyEnumerator.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 3/14/17 2:47 PM
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

#import "PGEmptyEnumerator.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"

@implementation PGEmptyEnumerator {
    }

    -(id)nextObject {
        return nil;
    }

    -(NSArray *)allObjects {
        return [NSArray array];
    }

    -(instancetype)init {
        return (self = [super init]);
    }

    +(instancetype)emptyEnumerator {
        return [[self alloc] init];
    }

@end

#pragma clang diagnostic pop
