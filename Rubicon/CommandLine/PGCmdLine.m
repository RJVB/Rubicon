/*******************************************************************************************************************************************************************************//**
 *     PROJECT: Rubicon
 *    FILENAME: PGCmdLine.m
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: 4/14/18
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

NSString *const PGCmdLineErrorIndexKey = @"PGCmdLineErrorIndexKey";
NSString *const PGCmdLineErrorItemKey  = @"PGCmdLineErrorItemKey";

NSString *const PGErrorMsgCmdLineNonOptionItemsNotAllowed      = @"Non-option items not allowed.";
NSString *const PGErrorMsgCmdLineCannotMixOptionsAndNonOptions = @"Options and non-options cannot be mixed together.";
NSString *const PGErrorMsgCmdLineLongOptionsNotAllowed         = @"Long options not allowed.";

NSString *const PGCmdLineParamSeparator = @"=";

typedef BOOL (^AlreadyExistsBlk)(NSString *);

#define OptionInError(v)       (((v) & PGCmdLineItemTypeError) == PGCmdLineItemTypeError)
#define OptionNoParam(v)       (((v) & (PGCmdLineItemTypeOptionalParameter | PGCmdLineItemTypeManditoryParameter)) == 0)
#define OptionMustHaveParam(v) (((v) & PGCmdLineItemTypeManditoryParameter) == PGCmdLineItemTypeManditoryParameter)
#define OptionCanHaveParam(v)  (((v) & PGCmdLineItemTypeOptionalParameter) == PGCmdLineItemTypeOptionalParameter)

@interface PGCmdLine()

    @property(readonly) PGCmdLineParseOptions parseOptions;

@end

@implementation PGCmdLine {
    }

    @synthesize rawArguments = _rawArguments;
    @synthesize parseOptions = _parseOptions;
    @synthesize encoding = _encoding;
    @synthesize arguments = _arguments;
    @synthesize options = _options;
    @synthesize executableName = _executableName;

    -(instancetype)initWithArguments:(const char **)argv
                              length:(NSUInteger)argc
                            encoding:(NSStringEncoding)encoding
                        parseOptions:(PGCmdLineParseOptions)parseOptions
                               error:(NSError **)error {
        self = [super init];

        if(self) {
            NSMutableArray *args = [NSMutableArray arrayWithCapacity:argc];

            _parseOptions   = parseOptions;
            _rawArguments   = args;
            _encoding       = encoding;
            _executableName = @"";

            for(NSUInteger i = 0; i < argc; i++) {
                const char *cstr = argv[i];
                // check for a NULL just in case...
                [args addObject:(cstr ? [NSString stringWithCString:cstr encoding:_encoding] : @"")];
            }

            [self parseCommandLine:args error:error];
        }

        return self;
    }

    -(instancetype)initWithArguments:(const char **)argv length:(NSUInteger)argc parseOptions:(PGCmdLineParseOptions)parseOptions error:(NSError **)error {
        return (self = [self initWithArguments:argv length:argc encoding:NSUTF8StringEncoding parseOptions:parseOptions error:error]);
    }

    -(BOOL)parseCommandLine:(NSStrArray)cmdLine error:(NSError **)error {
        NSMutableStrArray                   nonOptions  = [NSMutableArray new];
        NSMutableDictionary<NSString *, id> *argOptions = [NSMutableDictionary new];

        @try {
            NSUInteger      clcnt = cmdLine.count;
            __block NSError *err  = nil;

            if(clcnt) {
                /*
                 * This regex pattern and block will remove any whitespace around the option markers '-' and '--' but
                 * leave any internal or trailing whitespace. It will also leave non-option arguments untouched.
                 */
                NSString           *cleanRegex = @"^(?:\\s*(\\-\\-)\\s*(?:([^\\s]+)\\s*(\\=)?)?|\\s*(\\-)\\s*)";
                PGRegexFilterBlock cleanBlock  = ^NSString *(NSString *str, NSString *sub, NSUInteger num, NSTextCheckingResult *res, NSString *last, BOOL *stop) {
                    NSMutableString *mstr = [NSMutableString new];
                    for(NSUInteger  i     = 1, j = res.numberOfRanges; i < j; i++) {
                        NSRange r = [res rangeAtIndex:i];
                        if(r.location != NSNotFound) [mstr appendString:[str substringWithRange:r]];
                    }
                    return mstr;
                };

                /*
                 * A "soft" end-of-options occurs when parseOptionAllowMixedOptionsAndNonOptions
                 * returns NO and we encounter a non-option item in the command line. Any further
                 * options encountered will result in an error.
                 */
                BOOL               softEndOfOptions = NO;
                __block NSUInteger idx              = 0;

                _executableName = cmdLine[idx++];

                while((err == nil) && (idx < clcnt)) {
                    NSString *rawItem = cmdLine[idx++];
                    NSString *item    = [rawItem stringByFilteringWithRegexPattern:cleanRegex regexOptions:0 matchOptions:0 replacementBlock:cleanBlock error:&err];

                    if([item isEqualToString:@"--"]) {
                        /*
                         * We've reached the end of options marker. So if more arguments exist
                         * and non-options are allowed then consume the rest of the arguments
                         * into the non-options array, otherwise indicate an error.
                         */
                        if(idx < clcnt) {
                            if(self.parseOptionDisallowNonOptions) {
                                err = [self createError:PGErrorMsgCmdLineNonOptionItemsNotAllowed index:idx item:cmdLine[idx]];
                            }
                            else {
                                do { [nonOptions addObject:cmdLine[idx++]]; } while(idx < clcnt);
                            }
                        }
                    }
                    else if([item hasPrefix:@"--"]) {
                        if(softEndOfOptions && !self.parseOptionAllowMixedOptionsAndNonOptions) {
                            err = [self createError:PGErrorMsgCmdLineCannotMixOptionsAndNonOptions index:(idx - 1) item:item];
                        }
                        else {
                            NSString *option = [item substringFromIndex:2];
                            NSString *param  = nil;

                            /*
                             * If there is a parameter then it will be after an equal sign (=).
                             */
                            NSStrArray ar = [option componentsSeparatedByString:@"=" limit:2];

                            if(ar.count > 1) {
                                option = ar[0];
                                param  = ar[1];
                            }

                            if(self.parseOptionDisallowLongOptionNames) {
                                err = [self createError:PGErrorMsgCmdLineLongOptionsNotAllowed index:(idx - 1) item:item];
                            }
                            else {
                                PGCmdLineItemType vald = [self validateOption:option item:item index:idx error:&err];

                                if(OptionInError(vald)) {
                                    if(err == nil) err = [self createError:@"Unknown error." index:(idx - 1) item:item];
                                }
                                else {
                                    [self processOption:option parameter:param validation:vald item:item options:argOptions index:idx error:&err];
                                }
                            }
                        }
                    }
                    else if((item.length > 1) && [item hasPrefix:@"-"]) {
                        if(softEndOfOptions && !self.parseOptionAllowMixedOptionsAndNonOptions) {
                            err = [self createError:PGErrorMsgCmdLineCannotMixOptionsAndNonOptions index:(idx - 1) item:item];
                        }
                        else {
                            [self cmdLineItem:item clcnt:clcnt cmdLine:cmdLine idx:&idx options:argOptions error:&err];
                        }
                    }
                    else if(self.parseOptionDisallowNonOptions) {
                        err = [self createError:PGErrorMsgCmdLineNonOptionItemsNotAllowed index:idx item:rawItem];
                    }
                    else {
                        if(!(softEndOfOptions || self.parseOptionAllowMixedOptionsAndNonOptions)) softEndOfOptions = YES;
                        [nonOptions addObject:rawItem];
                    }
                }
            }
            else {
                err = [NSError errorWithDomain:PGErrorDomain code:PGErrorCodeCmdLineParseError userInfo:@{ NSLocalizedDescriptionKey: @"No command-line items." }];
            }

            PGSetReference(error, err);
            return (err == nil);
        }
        @catch(NSException *exception) {
            if(error) *error = [exception makeError];
            return NO;
        }
        @finally {
        }
    }

    -(NSUInteger)cmdLineItem:(NSString *)item
                       clcnt:(NSUInteger)clcnt
                     cmdLine:(NSStrArray)cmdLine
                         idx:(NSUInteger)idx
                     options:(NSMutableDictionary *)options
                       error:(NSError **)error {

        __block NSUInteger tidx = idx;

        /*
         * Go through the characters one at a time, validate (to find out if it takes parameters) and then send
         * for processing.
         */
        PGCharEnumBlock enumBlock = ^BOOL(unichar c, unichar *dc, NSRange range, BOOL composed, NSString *before, NSString *after) {
            NSString          *option        = [NSString stringWithCharacters:dc length:range.length];
            NSString          *param         = nil;
            BOOL              stop           = NO;
            BOOL              nextMayBeParam = ((idx < clcnt) && ![self isOptionStyle:cmdLine[idx]]);
            PGCmdLineItemType vald           = [self validateOption:option item:item index:idx error:error];

            if(OptionInError(vald)) {
                if((*error) == nil) (*error) = [self createError:@"Unknown error." index:(idx - 1) item:item];
                stop = YES;
            }
            else if(after == nil) {
                /*
                 * If there are no more characters after this one (after is NULL) and
                 * this option _might_ take a parameter then look to see if the next
                 * command-line item is a non-option (doesn't start with '-') and then
                 * make that the parameter.
                 */
                if(nextMayBeParam && !OptionNoParam(vald)) param = cmdLine[tidx++];
            }
            else if(OptionMustHaveParam(vald)) {
                /*
                 * If this options requires a parameter and there are more characters
                 * left (after is _not_ NULL) then those characters will become the
                 * parameter and we are done.
                 */
                param = after;
                stop  = YES;
            }

            BOOL res = [self processOption:option parameter:param validation:vald item:item options:options index:idx error:error];
            return (stop || res);
        };

        NSString *q = [item substringFromIndex:1];
        [q enumerateOverCharactersWithBlock:enumBlock range:NSMakeRange(0, q.length)];
        return tidx;
    }

    -(BOOL)processOption:(NSString *)option
               parameter:(NSString *)param
              validation:(PGCmdLineItemType)vld
                    item:(NSString *)item
                 options:(NSMutableDictionary *)options
                   index:(NSUInteger)idx
                   error:(NSError **)error {

        NSError *err   = nil;
        BOOL    exists = (options[option] != nil);

        if(exists && self.parseOptionErrorOnDuplicates) {
            err = [self createError:@"Option already exists." index:(idx - 1) item:item];
        }
        else if(param && OptionNoParam(vld)) {
            err = [self createError:@"Unexpected option parameter." index:(idx - 1) item:item];
        }
        else if((param == nil) && OptionMustHaveParam(vld)) {
            err = [self createError:@"Option parameter expected." index:(idx - 1) item:item];
        }
        else if(!(exists && self.parseOptionDuplicatesKeepFirst)) {
            options[option] = ((id)param ?: (id)[NSNull null]);
        }

        PGSetReference(error, err);
        return (err != nil);
    }

    -(PGCmdLineItemType)validateOption:(NSString *)option item:(NSString *)item index:(NSUInteger)idx error:(NSError **)error {
        if(option.length == 0) {
            PGSetReference(error, [self createError:@"Invalid Option" index:(idx - 1) item:@""]);
            return PGCmdLineItemTypeError;
        }

        PGSetReference(error, nil);
        return (PGCmdLineItemTypeUnknownOption | PGCmdLineItemTypeOptionalParameter | ((option.length == 1) ? PGCmdLineItemTypeShortOption : PGCmdLineItemTypeLongOption));
    }

    -(BOOL)isOptionStyle:(NSString *)item {
        return ([item isEqualToString:@"--"] || [item hasPrefix:@"--"] || ((item.length > 1) && [item hasPrefix:@"-"]));
    }

    -(NSError *)lookForMissingOptions {
        return nil;
    }

    -(NSError *)createError:(NSString *)msg index:(NSUInteger)idx item:(NSString *)item {
        NSDictionary *dict = @{
                NSLocalizedDescriptionKey: msg, PGCmdLineErrorIndexKey: @(idx), PGCmdLineErrorItemKey: item
        };
        return [NSError errorWithDomain:PGErrorDomain code:PGErrorCodeCmdLineParseError userInfo:dict];
    }

    -(BOOL)parseOptionDisallowLongOptionNames {
        return ((self.parseOptions & PGCmdLineParseOptionDisallowLongOptionNames) == PGCmdLineParseOptionDisallowLongOptionNames);
    }

    -(BOOL)parseOptionDisallowNonOptions {
        return ((self.parseOptions & PGCmdLineParseOptionDisallowNonOptions) == PGCmdLineParseOptionDisallowNonOptions);
    }

    -(BOOL)parseOptionAllowMixedOptionsAndNonOptions {
        return ((self.parseOptions & PGCmdLineParseOptionAllowMixingOptionsAndNonOptions) == PGCmdLineParseOptionAllowMixingOptionsAndNonOptions);
    }

    -(BOOL)parseOptionErrorOnDuplicates {
        return ((self.parseOptions & PGCmdLineParseOptionDisallowDuplicates) == PGCmdLineParseOptionDisallowDuplicates);
    }

    -(BOOL)parseOptionDuplicatesKeepFirst {
        return ((self.parseOptions & PGCmdLineParseOptionDuplicatesKeepFirst) == PGCmdLineParseOptionDuplicatesKeepFirst);
    }

    -(BOOL)parseOptionDisallowUknownOptions {
        return ((self.parseOptions & PGCmdLineParseOptionDisallowUnknownOptions) == PGCmdLineParseOptionDisallowUnknownOptions);
    }


@end
