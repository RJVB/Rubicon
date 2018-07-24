/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGDOMNamespaceAware.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 6/28/18
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

#import "PGDOMPrivate.h"
#import "PGDOMXMLValidationRegexPatterns.h"

@implementation PGDOMNamespaceAware {
        NSString *_localName;
        NSString *_prefix;
        NSString *_namespaceURI;
        NSString *_nodeName;
    }

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType
                      ownerDocument:(PGDOMDocument *)ownerDocument
                      qualifiedName:(NSString *)qualifiedName
                       namespaceURI:(NSString *)namespaceURI {
        self = [super initWithNodeType:nodeType ownerDocument:ownerDocument];

        if(self) {
            PGAbstractClassTest(PGDOMNamespaceAware);
            _nodeName     = qualifiedName.copy;
            _namespaceURI = namespaceURI.copy;
            _localName    = nil;
            _prefix       = nil;

            if(_nodeName) {
                NSArray<NSString *> *ar = [_nodeName componentsSeparatedByString:@":" limit:2];
                _localName = (ar.count == 2 ? ar[2] : _nodeName.copy);
                _prefix    = (ar.count == 2 ? ar[1] : nil);
            }

            [self validateNames];
        }

        return self;
    }

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType
                      ownerDocument:(PGDOMDocument *)ownerDocument
                          localName:(NSString *)localName
                             prefix:(NSString *)prefix
                       namespaceURI:(NSString *)namespaceURI {
        self = [super initWithNodeType:nodeType ownerDocument:ownerDocument];

        if(self) {
            PGAbstractClassTest(PGDOMNamespaceAware);
            _nodeName     = nil;
            _localName    = localName.copy;
            _prefix       = prefix.copy;
            _namespaceURI = namespaceURI.copy;

            [self validateNames];
        }

        return self;
    }

    -(instancetype)initWithNodeType:(PGDOMNodeTypes)nodeType ownerDocument:(PGDOMDocument *)ownerDocument nodeName:(NSString *)nodeName {
        self = [super initWithNodeType:nodeType ownerDocument:ownerDocument];

        if(self) {
            PGAbstractClassTest(PGDOMNamespaceAware);
            if(nodeName.length == 0) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGDOMErrorMsgNodeNameMissing];

            _nodeName     = nodeName.copy;
            _localName    = nodeName.copy;
            _prefix       = nil;
            _namespaceURI = nil;

            [self validateCharacters:_localName];
        }

        return self;
    }

    -(NSString *)nodeName {
        if(_nodeName == nil) _nodeName = (self.prefix.length ? PGFormat(@"%@:%@", self.prefix, self.localName) : self.localName.copy);
        return _nodeName;
    }

    -(NSString *)localName {
        return _localName;
    }

    -(NSString *)prefix {
        return _prefix;
    }

    -(void)setPrefix:(NSString *)prefix {
        [self validateLocalName:self.localName prefix:prefix namespaceURI:self.namespaceURI];
        _prefix   = prefix.copy;
        _nodeName = nil;
    }

    -(NSString *)namespaceURI {
        return _namespaceURI;
    }

    -(void)validateCharacters:(NSString *)name {
        NSRegularExpression *regex = [PGDOMNamespaceAware validationRegex];
        if(regex) {
            @synchronized(regex) {
                if(![regex matches:name]) @throw [self createInvArgException:PGDOMErrorMsgInvalidCharacter];
            }
        }
    }

    -(void)validateCharacters:(NSString *)localName prefix:(NSString *)prefix {
        NSRegularExpression *regex = [PGDOMNamespaceAware validationRegex];

        if(regex) {
            @synchronized(regex) {
                if(![regex matches:localName]) @throw [self createInvArgException:PGDOMErrorMsgInvalidCharacter];
                if(prefix.length && ![regex matches:prefix]) @throw [self createInvArgException:PGDOMErrorMsgInvalidCharacter];
            }
        }
    }

    -(void)validateNames {
        [self validateLocalName:self.localName prefix:self.prefix namespaceURI:self.namespaceURI];
    }

    -(void)validateLocalName:(NSString *)lnm prefix:(NSString *)pfx namespaceURI:(NSString *)uri {
        NSUInteger pfxlen = pfx.length;
        BOOL       noURI  = (uri.length == 0);

        if(lnm.length == 0) @throw [self createInvArgException:PGDOMErrorMsgLocalNameRequired];
        if(noURI) {
            if(pfxlen) @throw [self createInvArgException:PGDOMErrorMsgNamespaceError];
        }
        else {
            if([pfx isEqualToString:PGDOMXMLPrefix] && ![uri isEqualToString:PGDOMNamespaceURI1]) @throw [self createInvArgException:PGDOMErrorMsgNamespaceError];

            BOOL hasXMLNSPrefix = ([pfx isEqualToString:PGDOMXMLNSPrefix] || ((pfxlen == 0) && [lnm isEqualToString:PGDOMXMLNSPrefix]));
            BOOL hasXMLNSURI    = [uri isEqualToString:PGDOMNamespaceURI2];

            if((hasXMLNSPrefix && !hasXMLNSURI) || (hasXMLNSURI && !hasXMLNSPrefix)) @throw [self createInvArgException:PGDOMErrorMsgNamespaceError];
        }

        [self validateCharacters:lnm prefix:pfx];
    }

    +(NSRegularExpression *)validationRegex {
        static NSRegularExpression *_regex     = nil;
        static dispatch_once_t     _regex_pred = 0;

        dispatch_once(&_regex_pred, ^{
            PGLogger *logger   = [PGLogger sharedInstanceWithClass:[PGDOMNamespaceAware class]];
            NSError  *error    = nil;
            NSString *strRegex = [NSString stringWithUTF8String:PGXML_NCNAME];

            [logger debug:PGDOMMsgCreatingValidationRegex, strRegex];
            _regex = [NSRegularExpression regularExpressionWithPattern:strRegex options:0 error:&error];
            if(error) [logger error:PGDOMErrorMsgValidationRegexError, error.description];
            else [logger debug:@"%@", PGDOMMsgValidationRegexCreated];
        });

        return _regex;
    }

@end

@implementation NSString(PGDOMNamespaceAware)

    -(NSString *)namespaceLocalName {
        NSArray<NSString *> *ar = [self componentsSeparatedByString:@":" limit:2];
        return ((ar.count == 2) ? ar[1] : self.copy);
    }

    -(NSString *)namespacePrefix {
        NSArray<NSString *> *ar = [self componentsSeparatedByString:@":" limit:2];
        return ((ar.count == 2) ? ar[0] : nil);
    }

@end
