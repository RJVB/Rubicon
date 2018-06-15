/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGCmdLineOption.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 4/24/18
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

#import "PGInternal.h"
#import "PGCmdLineCommon.h"

@implementation PGCmdLineOption {
        NSLock              *_lock;
        NSString            *_description;
        NSRegularExpression *_regex;
        NSUInteger          _hash;
        dispatch_once_t     _hashOnce;
        dispatch_once_t     _lockOnce;
        dispatch_once_t     _regexOnce;
    }

    @synthesize shortName = _shortName;
    @synthesize longName = _longName;
    @synthesize isRequired = _isRequired;
    @synthesize wasFound = _wasFound;
    @synthesize argumentType = _argumentType;
    @synthesize argumentState = _argumentState;
    @synthesize argument = _argument;
    @synthesize regexPattern = _regexPattern;

    -(instancetype)initWithShortName:(NSString *)shortName
                            longName:(NSString *)longName
                          isRequired:(BOOL)isRequired
                       argumentState:(PGCmdLineOptionArgument)argumentState
                        argumentType:(PGCmdLineArgumentType)argumentType
                        regexPattern:(NSString *)regexPattern {
        self = [super init];

        if(self) {
            [self testShortName:shortName longName:longName];
            [self testPattern:regexPattern];

            _shortName     = [shortName copy];
            _longName      = [longName copy];
            _isRequired    = isRequired;
            _argumentState = argumentState;
            _argumentType  = (((argumentState != PGCmdLineArgNone) && (argumentType == PGCmdLineArgTypeNone)) ? PGCmdLineArgTypeString : argumentType);
            _regexPattern  = [regexPattern copy];
            _description   = nil;
        }

        return self;
    }

    -(void)testShortName:(NSString *)shortName longName:(NSString *)longName {
        if((shortName.length == 0) && (longName.length == 0)) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGErrorMsgCmdLineLongShortNULL];
        }

        if(shortName.length) {
            NSRange r = [shortName rangeOfComposedCharacterSequenceAtIndex:0];

            if(!((r.location == 0) && (r.length == shortName.length))) {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:PGErrorMsgCmdLineShortOptionTooLong];
            }
        }
    }

    -(void)testPattern:(NSString *)regexPattern {
        if(regexPattern) {
            /*
             * Test the regular expression pattern for correct syntax but don't keep the regex.
             * We don't want to keep the memory used if the regex is never used again.
             */
            NSError             *er = nil;
            NSRegularExpression *rx = [NSRegularExpression regularExpressionWithPattern:regexPattern options:0 error:&er];
            if(rx == nil) @throw (er ? [er makeException] : [NSException exceptionWithName:NSInvalidArgumentException reason:PGErrorMsgBadRegexPattern]);
        }
    }

    -(NSRegularExpression *)regex {
        dispatch_once(&_regexOnce, ^{
            if(self->_regexPattern) {
                NSError *err = nil;
                self->_regex = [NSRegularExpression cachedRegex:self->_regexPattern prefix:PGCmdLineRegexPrefix error:&err];

                if(!self->_regex) {
                    if(!err) err = [NSError errorWithDomain:PGErrorDomain code:PGErrorCodeUnknownError userInfo:@{ NSLocalizedDescriptionKey: PGErrorMsgUnknowError }];
                    [[PGLogger sharedInstanceWithClass:self.class] debug:@"ERROR: Invalid Regex Pattern: %@", err];
                }
            }
        });
        return _regex;
    }

    -(NSComparisonResult)compare:(PGCmdLineOption *)other {
        if(other) {
            if(other == self) return NSOrderedSame;
            NSComparisonResult r = PGStrCompare(self.shortName, other.shortName);
            return ((r == NSOrderedSame) ? PGStrCompare(self.longName, other.longName) : r);
        }

        return NSOrderedDescending;
    }

    -(NSString *)description {
        [self.lock lock];

        @try {
            if(_description == nil) {
                NSMutableString *str = [NSMutableString stringWithFormat:@"<%@:", NSStringFromClass([self class])];

                if(self.shortName) [str appendFormat:@" shortName: \"%@\";", self.shortName];
                if(self.longName) [str appendFormat:@" longName: \"%@\";", self.longName];

                [str appendFormat:@" isRequired: %@; parameters: %@;", obool(self.isRequired), oargs(self.argumentState)];

                if(self.argumentState != PGCmdLineArgNone) [str appendFormat:@" parameterType: %@;", otypes(self.argumentType)];
                if(self.regex) [str appendFormat:@" regex: \"%@\";", self.regex.pattern];

                [str appendFormat:@" wasFound: %@;", obool(self.wasFound)];

                if(self.argument) [str appendFormat:@" parameter: \"%@\";", self.argument];

                [str appendString:@">"];
                _description = str;
            }
        }
        @finally {
            [self.lock unlock];
        }

        return _description;
    }

    -(NSString *)nameDescription {
        NSString *s = self.shortName;
        NSString *l = self.longName;

        return ((s && l) ? PGFormat(@"%@|%@", s, l) : (s ?: (l ?: @"<NO-NAME>")));
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        PGCmdLineOption *copy = [((PGCmdLineOption *)[[self class] allocWithZone:zone]) init];

        if(copy != nil) {
            copy->_regexPattern  = _regexPattern;
            copy->_shortName     = _shortName;
            copy->_longName      = _longName;
            copy->_isRequired    = _isRequired;
            copy->_argumentType  = _argumentType;
            copy->_argumentState = _argumentState;
        }

        return copy;
    }

    -(BOOL)isEqual:(id)other {
        return (other && ((other == self) || ([other isKindOfClass:[self class]] && [self _isEqualToOption:other])));
    }

    -(BOOL)isEqualToOption:(PGCmdLineOption *)option {
        return (option && ((option == self) || [self _isEqualToOption:option]));
    }

    -(BOOL)_isEqualToOption:(PGCmdLineOption *)option {
        return (PGStringsEqual(_regexPattern, option->_regexPattern) &&
                PGStringsEqual(_shortName, option.shortName) &&
                PGStringsEqual(_longName, option.longName) &&
                (_isRequired == option.isRequired) &&
                (_argumentState == option.argumentState) &&
                (_argumentType == option.argumentType));
    }

    -(NSUInteger)hash {
        dispatch_once(&_hashOnce, ^{
            self->_hash = (((((((((([self->_regexPattern hash] * 31u) + [self->_shortName hash]) * 31u) + [self->_longName hash]) * 31u) + self->_isRequired) * 31u) +
                             (NSUInteger)self->_argumentType) * 31u) + (NSUInteger)self->_argumentState);
        });
        return _hash;
    }

    -(void)setWasFound:(BOOL)wasFound {
        [self.lock lock];
        @try {
            if(_wasFound != wasFound) {
                _description = nil;
                _wasFound    = wasFound;
            }
        }
        @finally { [self.lock unlock]; }
    }

    -(void)setArgument:(NSString *)argument {
        [self.lock lock];
        @try {
            if(!PGStringsEqual(_argument, argument)) {
                _description = nil;
                _argument    = argument;
            }
        }
        @finally { [self.lock unlock]; }
    }

    -(NSLock *)lock {
        dispatch_once(&_lockOnce, ^{ self->_lock = [NSLock new]; });
        return _lock;
    }

@end

PGCmdLineOption *PGMakeCmdLineOpt(NSString *shortName,
                                  NSString *longName,
                                  BOOL isRequired,
                                  PGCmdLineOptionArgument argument,
                                  PGCmdLineArgumentType argType,
                                  NSString *regexPattern) {
    return [[PGCmdLineOption alloc] initWithShortName:shortName longName:longName isRequired:isRequired argumentState:argument argumentType:argType regexPattern:regexPattern];
}

