/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: NSObject(PGObject).h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 12/21/16 5:34 PM
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

#ifndef __Rubicon_NSObject_PGObject__H_
#define __Rubicon_NSObject_PGObject__H_

#import <Cocoa/Cocoa.h>

@interface NSObject(PGObject)

	/**************************************************************************************************//**
	 * This method returns the first superclass that this object has in common with the given object.
	 * For example, if you have two objects that are descendents of NSString but neither is a descendent
	 * of the other then calling this method on one of the objects and passing the other will return the
	 * NSString class. All objects should have, at the very least, NSObject in common but this method
	 * will return nil if it cannot find a common superclass.
	 *
	 * @param obj the other object.
	 * @return the first superclass that both this object and the given class have in common.
	 ******************************************************************************************************/
	-(Class)baseClassInCommonWith:(id)obj;

	/**************************************************************************************************//**
	 * Created because the definition of isKindOf:(Class) and isMemberOf:(Class) is hard for me to
	 * remember for some reason.
	 *
	 * @param clazz the class to compare to.
	 * @return YES if this object is an instance of clazz or one of it's subclasses.
	 ******************************************************************************************************/
	-(BOOL)isInstanceOf:(Class)clazz;

	/**************************************************************************************************//**
	 * Created because the definition of isKindOf:(Class) and isMemberOf:(Class) is hard for me to
	 * remember for some reason.
	 *
	 * @param clazz the class to compare to.
	 * @return YES if this object is an instance of clazz.
	 ******************************************************************************************************/
	-(BOOL)isExactInstanceOf:(Class)clazz;

	/**************************************************************************************************//**
	 * Returns a default generic comparator that will make a best attempt at comparing this object with
	 * another object.
	 ******************************************************************************************************/
	+(NSComparator)defaultComparator;

@end

#endif // __Rubicon_NSObject_PGObject__H_
