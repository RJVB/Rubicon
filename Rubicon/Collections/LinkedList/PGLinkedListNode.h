/***************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGLinkedListNode.h
 *         IDE: AppCode
 *      AUTHOR:  Galen Rhodes
 *        DATE: 3/3/17 10:33 AM
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

#ifndef __Rubicon_PGLinkedListNode_H_
#define __Rubicon_PGLinkedListNode_H_

#import <Cocoa/Cocoa.h>

@interface PGLinkedListNode : NSObject

    @property(retain) PGLinkedListNode *nextNode;
    @property(retain) PGLinkedListNode *prevNode;
    @property(retain) id               value;
    @property(atomic) BOOL             isFirst;

    /**************************************************************************************************//**
	 * Creates a new node with the given value.
	 *
	 * @param value the value that this node will contain.
	 * @return the new first node.
	 ******************************************************************************************************/
    -(instancetype)initWithValue:(id)value;

    /**************************************************************************************************//**
     * @return The first node in the chain.
     ******************************************************************************************************/
    -(instancetype)firstNode;

    /**************************************************************************************************//**
	 * @return The last node in the chain.
	 ******************************************************************************************************/
    -(instancetype)lastNode;

    /**************************************************************************************************//**
	 * Creates and inserts a new node with the given value into the chain AFTER this node.
	 *
	 * @param value the value that the new node will contain.
	 * @return the new node that was created.
	 ******************************************************************************************************/
    -(instancetype)insertAfter:(id)value;

    /**************************************************************************************************//**
	 * Creates and inserts a new node with the given value into the chain BEFORE this new node.
	 *
	 * @param value the value that the new node will contain.
	 * @return the new node that was created.
	 ******************************************************************************************************/
    -(instancetype)insertBefore:(id)value;

    /**************************************************************************************************//**
	 * Removes this node from the chain.  If this node represented the FIRST node then the next chain will
	 * become the next node.
	 *
	 * @return The next node in the chain or nil if this was the only node left.
	 ******************************************************************************************************/
    -(instancetype)remove;

    /**************************************************************************************************//**
	 * Creates a new node with the given value.
	 *
	 * @param value the value that this node will contain.
	 * @return the new first node.
	 ******************************************************************************************************/
    +(instancetype)nodeWithValue:(id)value;

@end

#endif //__Rubicon_PGLinkedListNode_H_
