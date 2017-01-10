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

#import <Rubicon/PGTime.h>

/*
 * Definitions for standard 32-bit RGBA color model.
 */
#define PGBitsPerField   (8)
#define PGFieldsPerPixel (4)

/**************************************************************************************************//**
 * Creates and returns a bitmap image compatible with PNG file formats.  This allows you
 * to create off-screen images and then save them to a PNG file.
 *
 * @param width the width of the image.
 * @param height the height of the image.
 * @return a bitmap image for off-screen drawing.
 ******************************************************************************************************/
NSBitmapImageRep *PGCreateARGBImage(CGFloat width, CGFloat height);

/**************************************************************************************************//**
 * Takes an off-screen image and saves it as a PNG file.
 *
 * @param image the off-screen bitmap image.
 * @param filename the filename to write the image to.
 * @param error a pointer to an error object field that will receive an error object if an error
 *              occurs.
 ******************************************************************************************************/
BOOL PGSaveImageAsPNG(NSBitmapImageRep *image, NSString *filename, NSError **error);



#endif //__Rubicon_PGTools_H_

