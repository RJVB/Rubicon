/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMNodeContainer.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 7/3/18
 *  VISIBILITY: Private
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

#ifndef RUBICON_PGDOMNODECONTAINER_H
#define RUBICON_PGDOMNODECONTAINER_H

#import <Rubicon/PGDOMNotifiedContainer.h>

@class PGDOMNode;

NS_ASSUME_NONNULL_BEGIN

@interface PGDOMNodeContainer<T:PGDOMNode *> : PGDOMNotifiedContainer<NSFastEnumeration>

    @property(nonatomic, readonly) NSUInteger count;

    -(nullable T)item:(NSUInteger)idx;

    -(NSUInteger)indexOfNode:(PGDOMNode *)node;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGDOMNODECONTAINER_H
