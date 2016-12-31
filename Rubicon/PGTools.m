/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGTools.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/30/16 11:03 AM
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

#import "PGTools.h"

NSBitmapImageRep *PGCreateARGBImage(CGFloat width, CGFloat height) {
	NSInteger iWidth  = (NSInteger)ceil(width);
	NSInteger iHeight = (NSInteger)ceil(height);

	return [[NSBitmapImageRep alloc]
							  initWithBitmapDataPlanes:NULL
											pixelsWide:iWidth
											pixelsHigh:iHeight
										 bitsPerSample:PGBitsPerField
									   samplesPerPixel:PGFieldsPerPixel
											  hasAlpha:YES
											  isPlanar:NO
										colorSpaceName:NSDeviceRGBColorSpace
										  bitmapFormat:NSAlphaFirstBitmapFormat
										   bytesPerRow:(iWidth * PGFieldsPerPixel)
										  bitsPerPixel:(PGBitsPerField * PGFieldsPerPixel)];
}

BOOL PGSaveImageAsPNG(NSBitmapImageRep *image, NSString *filename, NSError **error) {
	NSData *pngData = [image representationUsingType:NSPNGFileType properties:@{}];
	return [pngData writeToFile:filename options:0 error:error];
}
