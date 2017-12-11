/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: NSObject(PGObject).m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 12/21/16 5:34 PM
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

#import "NSObject+PGObject.h"
#import <objc/runtime.h>

@implementation NSObject(PGObject)

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
    -(Class)superclassInCommonWith:(id)obj {
        return (obj ? PGCommonSuperclass([self class], [obj class]) : nil);
    }

    /**************************************************************************************************//**
	 * Created because the definition of isKindOf:(Class) and isMemberOf:(Class) is hard for me to
	 * remember for some reason.
	 *
	 * @param clazz the class to compare to.
	 * @return YES if this object is an instance of clazz or one of it's subclasses.
	 ******************************************************************************************************/
    -(BOOL)isInstanceOf:(Class)clazz {
        return [self isKindOfClass:clazz];
    }

    -(BOOL)isInstanceOfObject:(id)obj {
        return [self isInstanceOf:[obj class]];
    }

    /**************************************************************************************************//**
	 * Created because the definition of isKindOf:(Class) and isMemberOf:(Class) is hard for me to
	 * remember for some reason.
	 *
	 * @param clazz the class to compare to.
	 * @return YES if this object is an instance of clazz.
	 ******************************************************************************************************/
    -(BOOL)isExactInstanceOf:(Class)clazz {
        return [self isMemberOfClass:clazz];
    }

    -(BOOL)isExactInstanceOfObject:(id)obj {
        return [self isExactInstanceOf:[obj class]];
    }

    /**************************************************************************************************//**
	 * Returns a default generic comparator that will make a best attempt at comparing this object with
	 * another object.
	 ******************************************************************************************************/
    +(NSComparator)defaultComparator {
        return ^NSComparisonResult(id obj1, id obj2) {
            if(obj1 && obj2) {
                if(obj1 == obj2 || [obj1 isEqual:obj2]) {
                    return NSOrderedSame;
                }
                else if([[obj1 superclassInCommonWith:obj2] instancesRespondToSelector:@selector(compare:)]) {
                    return [obj1 compare:obj2];
                }
            }

            return ((obj1 < obj2) ? NSOrderedAscending : ((obj1 > obj2) ? NSOrderedDescending : NSOrderedSame));
        };
    }

@end

/**************************************************************************************************//**
 * The purpose of this function is to attempt to find a class that is the first common superclass of the two
 * provided classes.  If not common superclass can be found then Nil is returned.  Usually, all classes in
 * normal Objective-C programs share at least one superclass, the root class NSObject.  However, this
 * function makes the assumption that one or both of the provided classes may not ultimately inherit from
 * NSObject.  As such this function uses the Objective-C runtime function class_getSuperclass(Class) rather
 * than assuming that the NSObject class method superclass is available to use.
 *
 * @param c1 the first class.
 * @param c2 the second class.
 * @return the first common superclass or Nil if there isn't one.
 */
Class PGCommonSuperclass(Class c1, Class c2) {
    if(c1 && c2) {
        for(Class ca = c1; (ca != nil); ca = class_getSuperclass(ca)) {
            for(Class cb = c2; (cb != nil); cb = class_getSuperclass(cb)) {
                if(ca == cb) return cb;
            }
        }
    }

    return nil;
}

