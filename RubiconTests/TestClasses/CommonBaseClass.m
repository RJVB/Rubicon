/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: CommonBaseClass.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/29/16 4:37 PM
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

#import "CommonBaseClass.h"

@implementation CommonBaseClass {
    }

    -(NSString *)description {
        NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];

        [description appendString:@">"];
        return description;
    }

@end

@implementation Subclass1A {
    }
@end

@implementation Subclass1B {
    }
@end

@implementation Subclass1C {
    }

    -(NSComparisonResult)compare:(id)obj {
        return NSOrderedSame;
    }

@end

@implementation Subclass1D {
    }
@end

@implementation Subclass2A {
    }
@end

@implementation Subclass2B {
    }
@end

@implementation Subclass2C {
    }

@end

