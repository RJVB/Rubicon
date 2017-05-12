/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGMacros.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 1/10/17 12:01 PM
 *  VISIBILITY: Private
 * DESCRIPTION:
 *
 * Copyright © 2017  Project Galen. All rights reserved.
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

#ifndef __Rubicon_PGMacros_H_
#define __Rubicon_PGMacros_H_

#import <Rubicon/PGTools.h>

/**************************************************************************************************//**
 * Default macro regex definition. This regex sees a macro as anything in the form of "${sometext}"
 * (not including the quotes) where "sometext" is the macro label.
 ******************************************************************************************************/
#define PGDefaultMacroRegex @"\\$\\{\\s*(\\w+)\\s*\\}"

/**************************************************************************************************//**
 * The block definition for a block that provides the replacement string for each macro in the string.
 *
 * @param label is the label of the macro. Using the default regex above the label for the macro
 *              "${sometext}" would be "sometext".
 * @param whole this is the entire string that is being searched for macros.
 * @param range this is the range within the whole string that this macro occupies.
 * @return the replacement string that will be substituted for this macro in the end result.
 ******************************************************************************************************/
typedef NSString *(^PGMacroHandler)(NSString *label, NSString *whole, NSRange range);

@interface PGMacros : NSObject

	@property(nonatomic, copy) PGMacroHandler macroHandler;
	@property(nonatomic, copy) NSString       *macroRegex;

	/**************************************************************************************************//**
	 * Initiialize the object with the given macro handler.
	 *
	 * @param macroHandler the macro handler.
	 * @return a initialized object.
	 */
	-(instancetype)initWithHandler:(PGMacroHandler)macroHandler;

	/**************************************************************************************************//**
	 * Initialize the object with the given regular expression and macro handler.
	 *
	 * @param macroRegex the regular expression to search for macro instances with.
	 * @param macroHandler the macro handler.
	 * @return an initialized object.
	 */
	-(instancetype)initWithRegex:(NSString *)macroRegex andHandler:(PGMacroHandler)macroHandler;

	-(NSString *)stringByProcessingMacrosIn:(NSString *)aString options:(NSRegularExpressionOptions)options error:(NSError **)error;

	-(NSString *)stringByProcessingMacrosIn:(NSString *)aString error:(NSError **)error;

	+(NSString *)stringByProcessingMacrosIn:(NSString *)aString
	                              withRegex:(NSString *)macroRegex
	                             andHandler:(PGMacroHandler)macroHandler
	                                options:(NSRegularExpressionOptions)options
	                                  error:(NSError **)error;

	+(NSString *)stringByProcessingMacrosIn:(NSString *)aString withHandler:(PGMacroHandler)macroHandler options:(NSRegularExpressionOptions)options error:(NSError **)error;

	+(NSString *)stringByProcessingMacrosIn:(NSString *)aString withHandler:(PGMacroHandler)macroHandler error:(NSError **)error;

	+(instancetype)macrosWithRegex:(NSString *)macroRegex andHandler:(PGMacroHandler)macroHandler;

	+(instancetype)macrosWithHandler:(PGMacroHandler)macroHandler;

@end

#endif //__Rubicon_PGMacros_H_
