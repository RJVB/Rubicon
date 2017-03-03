/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: Rubicon.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/21/16 3:19 PM
 *  VISIBILITY: Public
 * DESCRIPTION:
 *
 * Copyright © 2016 Galen Rhodes All rights reserved.
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

#import <Cocoa/Cocoa.h>

//! Project version number for Rubicon.
FOUNDATION_EXPORT double RubiconVersionNumber;

//! Project version string for Rubicon.
FOUNDATION_EXPORT const unsigned char RubiconVersionString[];

#import <Rubicon/PGBinaryTreeDictionary.h>
#import <Rubicon/PGIPoint.h>
#import <Rubicon/PGISize.h>
#import <Rubicon/PGIRect.h>
#import <Rubicon/PGPoint.h>
#import <Rubicon/PGSize.h>
#import <Rubicon/PGRect.h>
#import <Rubicon/PGDivideRectResults.h>
#import <Rubicon/PGMacros.h>
#import <Rubicon/PGSemaphore.h>
#import <Rubicon/PGReadWriteLock.h>
#import <Rubicon/PGTimeSpec.h>
#import <Rubicon/PGTimedWait.h>
#import <Rubicon/PGBinaryTreeNode.h>
#import <Rubicon/NSObject+PGObject.h>
#import <Rubicon/NSString+PGString.h>
#import <Rubicon/NSMutableDictionary+PGBinaryTreeDictionary.h>
