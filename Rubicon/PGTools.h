/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGTools.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 12/30/16 11:03 AM
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

#ifndef __Rubicon_PGTools_H_
#define __Rubicon_PGTools_H_

#import <Cocoa/Cocoa.h>
#import <Rubicon/GNUstep.h>

#define PGBitsPerField   (8)
#define PGFieldsPerPixel (4)

NSBitmapImageRep *PGCreateARGBImage(CGFloat width, CGFloat height);

BOOL PGSaveImageAsPNG(NSBitmapImageRep *image, NSString *filename, NSError **error);

#endif //__Rubicon_PGTools_H_
