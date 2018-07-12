/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMAttr.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/29/18
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

#ifndef RUBICON_PGDOMATTR_H
#define RUBICON_PGDOMATTR_H

#import <Rubicon/PGDOMNamespaceAware.h>

@class PGDOMElement;

NS_ASSUME_NONNULL_BEGIN

@interface PGDOMAttr : PGDOMNamespaceAware

    @property(nonatomic, readonly, copy) /*    */ NSString     *name;
    @property(nonatomic, copy) /*              */ NSString     *value;
    @property(nonatomic, readonly) /*          */ BOOL         isSpecified;
    @property(nonatomic, readonly) /*          */ BOOL         isID;
    @property(nonatomic, readonly, nullable) /**/ PGDOMElement *ownerElement;

@end

@interface PGDOMNode()

    @property(nonatomic, readonly) PGDOMNamedNodeMap<PGDOMAttr *> *attributes;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGDOMATTR_H
