/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMDefines.h
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/27/18
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

#ifndef RUBICON_PGDOMDEFINES_H
#define RUBICON_PGDOMDEFINES_H

#import <Rubicon/PGTools.h>

typedef NS_ENUM(NSUInteger, PGDOMNodeTypes) {
    PGDOMNodeTypeDTD, PGDOMNodeTypeDTDEntity, PGDOMNodeTypeDTDNotation,
    PGDOMNodeTypeAttribute,
    PGDOMNodeTypeCDataSection, PGDOMNodeTypeComment,
    PGDOMNodeTypeDocument, PGDOMNodeTypeDocumentFragment,
    PGDOMNodeTypeElement,
    PGDOMNodeTypeEntityReference,
    PGDOMNodeTypeProcessingInstruction,
    PGDOMNodeTypeText
};

FOUNDATION_EXPORT NSExceptionName const PGDOMException;

FOUNDATION_EXPORT NSString *const PGDOMNodeNameCDataSection;
FOUNDATION_EXPORT NSString *const PGDOMNodeNameComment;
FOUNDATION_EXPORT NSString *const PGDOMNodeNameDocument;
FOUNDATION_EXPORT NSString *const PGDOMNodeNameDocumentFragment;
FOUNDATION_EXPORT NSString *const PGDOMNodeNameText;
FOUNDATION_EXPORT NSString *const PGDOMNodeNameUnknown;

FOUNDATION_EXPORT NSString *const PGDOMNodeTypeDescAttribute;
FOUNDATION_EXPORT NSString *const PGDOMNodeTypeDescCData;
FOUNDATION_EXPORT NSString *const PGDOMNodeTypeDescComment;
FOUNDATION_EXPORT NSString *const PGDOMNodeTypeDescDocumentFragment;
FOUNDATION_EXPORT NSString *const PGDOMNodeTypeDescDocument;
FOUNDATION_EXPORT NSString *const PGDOMNodeTypeDescDTD;
FOUNDATION_EXPORT NSString *const PGDOMNodeTypeDescElement;
FOUNDATION_EXPORT NSString *const PGDOMNodeTypeDescEntity;
FOUNDATION_EXPORT NSString *const PGDOMNodeTypeDescEntityReference;
FOUNDATION_EXPORT NSString *const PGDOMNodeTypeDescNotation;
FOUNDATION_EXPORT NSString *const PGDOMNodeTypeDescProcessingInstruction;
FOUNDATION_EXPORT NSString *const PGDOMNodeTypeDescText;

FOUNDATION_EXPORT NSString *const PGDOMErrorMsgNodeNotChild;
FOUNDATION_EXPORT NSString *const PGDOMErrorMsgNodeNull;
FOUNDATION_EXPORT NSString *const PGDOMErrorMsgHierarchy;
FOUNDATION_EXPORT NSString *const PGDOMErrorMsgOwnerDocumentMismatch;
FOUNDATION_EXPORT NSString *const PGDOMErrorMsgBadChildType;
FOUNDATION_EXPORT NSString *const PGDOMErrorMsgLocalNameRequired;
FOUNDATION_EXPORT NSString *const PGDOMErrorMsgNamespaceError;
FOUNDATION_EXPORT NSString *const PGDOMErrorMsgInvalidCharacter;
FOUNDATION_EXPORT NSString *const PGDOMErrorMsgValidationRegexError;
FOUNDATION_EXPORT NSString *const PGDOMErrorMsgOwnerDocumentNull;
FOUNDATION_EXPORT NSString *const PGDOMErrorMsgNodeNameMissing;
FOUNDATION_EXPORT NSString *const PGDOMErrorMsgNotTextNode;

FOUNDATION_EXPORT NSString *const PGDOMMsgOld;
FOUNDATION_EXPORT NSString *const PGDOMMsgReference;
FOUNDATION_EXPORT NSString *const PGDOMMsgCreatingValidationRegex;
FOUNDATION_EXPORT NSString *const PGDOMMsgValidationRegexCreated;

FOUNDATION_EXPORT NSString *const PGDOMNodeListChangedNotification;
FOUNDATION_EXPORT NSString *const PGDOMCascadeNodeListChangedNotification;

FOUNDATION_EXPORT NSString *const PGDOMNamespaceURI1;
FOUNDATION_EXPORT NSString *const PGDOMNamespaceURI2;
FOUNDATION_EXPORT NSString *const PGDOMXMLPrefix;
FOUNDATION_EXPORT NSString *const PGDOMXMLNSPrefix;

#endif //RUBICON_PGDOMDEFINES_H
