/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMDTD.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 7/12/18
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

#ifndef RUBICON_PGDOMDTD_H
#define RUBICON_PGDOMDTD_H

#import <Rubicon/PGDOMNode.h>
#import <Rubicon/PGDOMDTDEntity.h>
#import <Rubicon/PGDOMDTDNotation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGDOMDTD : PGDOMNode

    @property(nonatomic, nullable, readonly, copy) NSString              *name;
    @property(nonatomic, nullable, readonly, copy) NSString              *publicID;
    @property(nonatomic, nullable, readonly, copy) NSString              *systemID;
    @property(nonatomic, nullable, readonly, copy) NSString              *internalSubset;
    @property(nonatomic, readonly) PGDOMNamedNodeMap<PGDOMDTDEntity *>   *entities;
    @property(nonatomic, readonly) PGDOMNamedNodeMap<PGDOMDTDNotation *> *notations;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGDOMDTD_H
