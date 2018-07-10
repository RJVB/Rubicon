/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMDefines.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/27/18
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

#import "PGDOMDefines.h"

NSExceptionName const PGDOMException = @"PGDOMException";

NSString *const PGDOMNodeNameCDataSection     = @"#cdata-section";
NSString *const PGDOMNodeNameComment          = @"#comment";
NSString *const PGDOMNodeNameDocument         = @"#document";
NSString *const PGDOMNodeNameDocumentFragment = @"#document-fragment";
NSString *const PGDOMNodeNameText             = @"#text";
NSString *const PGDOMNodeNameUnknown          = @"#";

NSString *const PGDOMNodeTypeDescAttribute             = @"attribute";
NSString *const PGDOMNodeTypeDescCData                 = @"CData section";
NSString *const PGDOMNodeTypeDescComment               = @"comment";
NSString *const PGDOMNodeTypeDescDocumentFragment      = @"document fragment";
NSString *const PGDOMNodeTypeDescDocument              = @"document";
NSString *const PGDOMNodeTypeDescDTD                   = @"document type";
NSString *const PGDOMNodeTypeDescElement               = @"element";
NSString *const PGDOMNodeTypeDescEntity                = @"entity";
NSString *const PGDOMNodeTypeDescEntityReference       = @"entity reference";
NSString *const PGDOMNodeTypeDescNotation              = @"notation";
NSString *const PGDOMNodeTypeDescProcessingInstruction = @"processing instruction";
NSString *const PGDOMNodeTypeDescText                  = @"text";

NSString *const PGDOMErrorMsgNodeNotChild          = @"The %@ node is not a child node.";
NSString *const PGDOMErrorMsgNodeNull              = @"The %@ node is NULL.";
NSString *const PGDOMErrorMsgHierarchy             = @"Hierarchy error.";
NSString *const PGDOMErrorMsgOwnerDocumentMismatch = @"Owner document mismatch.";
NSString *const PGDOMErrorMsgBadChildType          = @"A %@ node cannot be a child of a %@ node.";
NSString *const PGDOMErrorMsgLocalNameRequired     = @"Localname is Required.";
NSString *const PGDOMErrorMsgNamespaceError        = @"Namespace Error.";
NSString *const PGDOMErrorMsgInvalidCharacter      = @"Invalid Character Error";
NSString *const PGDOMErrorMsgValidationRegexError  = @"Error Creating Validation Regex: %@";
NSString *const PGDOMErrorMsgOwnerDocumentNull     = @"Owner document is NULL.";
NSString *const PGDOMErrorMsgNodeNameMissing       = @"Node name is missing.";

NSString *const PGDOMMsgOld                     = @"old";
NSString *const PGDOMMsgReference               = @"reference";
NSString *const PGDOMMsgCreatingValidationRegex = @"Creating Validation Regex with Pattern: \"%@\"";
NSString *const PGDOMMsgValidationRegexCreated  = @"Validation Regex Created.";

NSString *const PGDOMNodeListChangedNotification        = @"PGDOMNodeListChangedNotification";
NSString *const PGDOMCascadeNodeListChangedNotification = @"PGDOMCascadeNodeListChangedNotification";

NSString *const PGDOMNamespaceURI1 = @"http://www.w3.org/XML/1998/namespace";
NSString *const PGDOMNamespaceURI2 = @"http://www.w3.org/2000/xmlns";
NSString *const PGDOMXMLPrefix     = @"xml";
NSString *const PGDOMXMLNSPrefix   = @"xmlns";
