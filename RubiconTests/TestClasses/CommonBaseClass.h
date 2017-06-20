/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: CommonBaseClass.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 12/29/16 4:37 PM
 *  VISIBILITY: Private
 * DESCRIPTION:
 *
 * Copyright © 2016  Project Galen. All rights reserved.
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

#ifndef __Rubicon_CommonBaseClass_H_
#define __Rubicon_CommonBaseClass_H_

#import <Cocoa/Cocoa.h>

@interface CommonBaseClass : NSObject

    -(NSString *)description;
@end

@interface Subclass1A : CommonBaseClass
@end

@interface Subclass1B : Subclass1A
@end

@interface Subclass1C : Subclass1B
@end

@interface Subclass1D : Subclass1C
@end

@interface Subclass2A : CommonBaseClass
@end

@interface Subclass2B : Subclass2A
@end

@interface Subclass2C : Subclass2B
@end

#endif //__Rubicon_CommonBaseClass_H_
