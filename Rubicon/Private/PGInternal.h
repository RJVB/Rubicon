/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGInternal.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 3/7/18
 *  VISIBILITY: Private
 * * Copyright © 2018 Project Galen. All rights reserved.
 * * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this
 * permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
 * AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 **********************************************************************************************************************************************************************************/

#ifndef RUBICON_PGINTERNAL_H
#define RUBICON_PGINTERNAL_H

#import "PGTools.h"

#define RubiconBundle [NSBundle bundleWithIdentifier:@"com.projectgalen.Rubicon"]

#ifdef NSLocalizedString
    #undef NSLocalizedString
    #define NSLocalizedString(key, comment) [RubiconBundle localizedStringForKey:(key) value:@"" table:nil]
#endif

#import "sem_timedwait.h"
#import "NSObject+PGObject.h"
#import "NSString+PGString.h"
#import "NSRegularExpression+PGRegularExpression.h"
#import "NSBitmapImageRep+PGBitmapImageRep.h"
#import "NSArray+PGArray.h"
#import "NSData+PGData.h"
#import "NSException+PGException.h"
#import "NSError+PGError.h"
#import "PGMacros.h"
#import "PGSemaphore.h"
#import "PGReadWriteLock.h"
#import "PGTimeSpec.h"
#import "PGTimedWait.h"
#import "PGFilterOutputStream.h"
#import "PGBase64OutputStream.h"
#import "PGLinkedListNode.h"
#import "PGStack.h"
#import "PGQueue.h"
#import "PGEmptyEnumerator.h"
#import "PGNestedEnumerator.h"
#import "PGMutableBinaryTreeDictionary.h"

#endif //RUBICON_PGINTERNAL_H
