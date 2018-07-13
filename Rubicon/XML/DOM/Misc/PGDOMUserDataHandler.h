/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMUserDataHandler.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 7/13/18
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

#ifndef RUBICON_PGDOMUSERDATAHANDLER_H
#define RUBICON_PGDOMUSERDATAHANDLER_H

#import <Rubicon/PGDOMNode.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGDOMUserDataHandler : NSObject

    -(instancetype)init;

    -(void)handleOperation:(PGDOMUserDataOperations)operation key:(NSString *)key data:(nullable NSString *)data src:(nullable PGDOMNode *)src dest:(nullable PGDOMNode *)dest;

@end

NS_ASSUME_NONNULL_END

#endif //RUBICON_PGDOMUSERDATAHANDLER_H
