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
#import "PGCmdLineCommon.h"

NSString *const PGCmdLineLongOptionParamMarkerPattern = @"\\s*=";

@implementation PGCmdLine {
    }

    @synthesize rawArguments = _rawArguments;
    @synthesize parseOptions = _parseOptions;
    @synthesize encoding = _encoding;
    @synthesize nonOptionArguments = _nonOptionArguments;
    @synthesize options = _options;
    @synthesize executableName = _executableName;
    @synthesize nonOptionCleaningRegex = _nonOptionCleaningRegex;
    @synthesize optionCleaningRegex = _optionCleaningRegex;
    @synthesize unknownOptions = _unknownOptions;

    -(instancetype)initWithArguments:(const char **)argv
                              length:(NSUInteger)argc
                        parseOptions:(PGCmdLineParseOptions)parseOptions
                             options:(NSArray<PGCmdLineOption *> *)options
                               error:(NSError **)error {
        return (self = [self initWithArguments:argv length:argc encoding:NSUTF8StringEncoding parseOptions:parseOptions options:options error:error]);
    }

    -(instancetype)initWithArguments:(const char **)argv
                              length:(NSUInteger)argc
                            encoding:(NSStringEncoding)encoding
                        parseOptions:(PGCmdLineParseOptions)parseOptions options:(NSArray<PGCmdLineOption *> *)options
                               error:(NSError **)error {
        self = [super init];

        if(self) {
            if((argc == 0) || (argv == NULL) || ((*argv) == NULL)) {
                NSDictionary *dict = @{ NSLocalizedDescriptionKey: PGErrorMsgCmdLineInvalidCommandLine };
                PGSetReference(error, [NSError errorWithDomain:PGErrorDomain code:PGErrorCodeCmdLineParseError userInfo:dict]);
                return nil;
            }

            _encoding     = encoding;
            _rawArguments = PGConvertCommandLineItems((argc - 1), (argv + 1), _encoding, error);

            if(_rawArguments == nil) return nil;

            _executableName     = [NSString stringWithCString:(*argv) encoding:_encoding];
            _options            = PGCreateOptionsList(options);
            _parseOptions       = parseOptions;
            _nonOptionArguments = @[];
            _unknownOptions     = @[];

            if([self parseCommandLine:_rawArguments error:error]) return nil;

            NSUInteger      nfc  = 0;
            NSMutableString *nfs = [NSMutableString stringWithFormat:@"%@", @"The following options were not found: "];

            for(PGCmdLineOption *opt in _options) {
                if(opt.isRequired && !opt.wasFound) {
                    if(nfc++) [nfs appendString:@", "];
                    [nfs appendString:opt.nameDescription];
                }
            }

            if(nfc) {
                PGSetReference(error, [NSError errorWithDomain:PGErrorDomain code:PGErrorCodeCmdLineParseError userInfo:@{ NSLocalizedDescriptionKey: nfs }]);
                return nil;
            }
        }

        return self;
    }

    /**
     * Parse the command-line elements for options and non-options (arguments).
     * Generally speaking we are following the guidelines that documented here: http://www.gnu.org/software/libc/manual/html_node/Argument-Syntax.html#Argument-Syntax
     *
     * @param error returns any error messages.
     * @return YES if errors where encountered.
     */
    -(BOOL)parseCommandLine:(NSStrArray)cmdLine error:(NSError **)error {
        NSMutableStrArray nonOptionArgs  = [NSMutableArray new];
        NSMutableStrArray unknownOptions = [NSMutableArray new];

        @try {
            NSError *err      = nil;
            BOOL    softStop  = NO;
            BOOL    noMixing  = self.parseOptionDisallowMixingOptionsAndNonOptions;
            BOOL    noNonOpts = self.parseOptionDisallowNonOptions;

            for(NSUInteger idx = 0, length = cmdLine.count; ((idx < length) && (!err)); idx++) {
                NSString *item = [self cleanOption:cmdLine[idx]];

                if([item isEqualToString:@"--"]) {
                    idx = [self handleRemainingArguments:cmdLine index:(idx + 1) nonOptionArguments:nonOptionArgs error:&err];
                }
                else if([item hasPrefix:@"--"]) {
                    if([self testForError:(softStop && noMixing) item:item index:idx reason:PGErrorMsgCmdLineCannotMixOptionsAndNonOptions error:&err]) {
                        [self processLongOption:[item substringFromIndex:2] idx:idx unknownOptions:unknownOptions error:&err];
                    }
                }
                else if((item.length > 1) && [item hasPrefix:@"-"]) {
                    if([self testForError:(softStop && noMixing) item:item index:idx reason:PGErrorMsgCmdLineCannotMixOptionsAndNonOptions error:&err]) {
                        idx = [self processShortOptions:[item substringFromIndex:1] cmdLine:cmdLine index:idx unknownOptions:unknownOptions error:&err];
                    }
                }
                else if([self testForError:noNonOpts item:item index:idx reason:PGErrorMsgCmdLineNonOptionItemsNotAllowed error:&err]) {
                    if(noMixing && !softStop) softStop = YES;
                    [nonOptionArgs addObject:[self cleanNonOption:item]];
                }
            }

            PGSetReference(error, err);
            return (err != nil);
        }
        @catch(NSException *exception) {
            PGSetReference(error, [exception makeError]);
            return YES;
        }
        @finally {
            if(nonOptionArgs.count) _nonOptionArguments = nonOptionArgs;
            if(unknownOptions.count) _unknownOptions    = unknownOptions;
        }
    }

    /**
     * If non-option arguments are allowed then copy the remaining command-line items to the arguments array.
     *
     * @param cmdLine the command-line items.
     * @param idx the index of the first of the remaining items in the command-line.
     * @param nonOptionArgs the array to receive the arguments.
     * @param error pointer to a variable of NSError that will recieve an error if non-option arguments are not allowed.
     * @return the updated index value.
     */
    -(NSUInteger)handleRemainingArguments:(NSStrArray)cmdLine index:(NSUInteger)idx nonOptionArguments:(NSMutableStrArray)nonOptionArgs error:(NSError **)error {
        NSUInteger len = cmdLine.count;
        PGSetReference(error, nil);

        if((idx < len) && [self testForError:self.parseOptionDisallowNonOptions item:cmdLine[idx] index:idx reason:PGErrorMsgCmdLineNonOptionItemsNotAllowed error:error]) {
            do { [nonOptionArgs addObject:[self cleanNonOption:cmdLine[idx++]]]; } while(idx < len);
        }

        return (idx ? (idx - 1) : idx);
    }

    /**
     * Process long options.  Long options are option that begin with two hyphen characters ("--") such as "--foo" where "foo" is the option name. Additionally long options
     * can have parameters that are separated by a single equals sign ("=") such as "--foo=bar" where "foo" is the option name and "bar" is the parameter.
     *
     * @param item the command-line item.
     * @param idx the index in the command-line where this option occurred.
     * @param unknownOptions an array of unknown options that this option will be added to if it is not known.
     * @param error if the option is unknown and unknown options are not allowed then this write-back parameter will be populated with an error.
     * @return YES if an error occurred.
     */
    -(BOOL)processLongOption:(NSString *)item idx:(NSUInteger)idx unknownOptions:(NSMutableStrArray)unknownOptions error:(NSError **)error {
        NSStrArray ar = [item componentsSeparatedByPattern:PGCmdLineLongOptionParamMarkerPattern limit:2];
        return [self processOption:[self findOptionByLongName:ar[0]] param:((ar.count > 1) ? ar[1] : nil) item:item index:idx unknownOptions:unknownOptions error:error];
    }

    /**
     * Process sort options. Short options are options that begin with one hyphen character ("-") followed by one or more single character options. Examples are
     * "-O" or "-abc". The latter being equivilant to "-a -b -c". If any option requires a parameter then any characters following it are considered the parameter, otherwise
     * the next command-line item is used if it is not itself another option. Examples of this are "-ofoobar" and "-o foobar" in which case the option name is "o" and the
     * parameter is "foobar". If an option requires a parameter and there are no more characters following it and the next command-line item is another option then an error
     * will be generated. For example, "-o -b" will generated an error if "o" requires a parameter.
     *
     * @param item the command-line item.
     * @param cmdLine the command-line.
     * @param idx the index in the command-line where this item exists.
     * @param unknownOptions an array of unknown options that these options will be added to if they are not known.
     * @param error if any of these options are unknown and unknown options are not allowed then this write-back parameter will be populated with an error.
     * @return the updated index.
     */
    -(NSUInteger)processShortOptions:(NSString *)item cmdLine:(NSStrArray)cmdLine index:(NSUInteger)idx unknownOptions:(NSMutableStrArray)unknownOptions error:(NSError **)error {
        __block NSError    *err = nil;
        __block NSUInteger i    = idx;

        PGCharEnumBlock blk = ^BOOL(unichar c, unichar *dc, NSRange range, BOOL composed, NSString *before, NSString *after) {
            NSString        *name   = [NSString stringWithCharacters:dc length:range.length];
            PGCmdLineOption *option = [self findOptionByShortName:name];

            if(option.argumentState == PGCmdLineArgRequired) {
                if(after.length > 0) {
                    [self processOption:option param:[after copy] item:name index:i unknownOptions:unknownOptions error:&err];
                    return YES;
                }
                else if((i + 1) < cmdLine.count) {
                    NSString *cln = [self cleanNonOption:cmdLine[(i + 1)]];

                    if(!isOption(cln)) {
                        [self processOption:option param:cln item:name index:i++ unknownOptions:unknownOptions error:&err];
                        return YES;
                    }
                }
            }

            return [self processOption:option param:nil item:name index:idx unknownOptions:unknownOptions error:&err];
        };

        [item enumerateOverCharactersWithBlock:blk];
        PGSetReference(error, err);
        return i;
    }

    /**
     * Process the option...
     *
     * @param option the option
     * @param param the parameter if any.
     * @param item the command-line item.
     * @param idx the index of the command-line item.
     * @param unknownOptions the array of unknown options found so far.
     * @param error if an error occurs it will be stored in this write-back variable.
     * @return YES if an error occurred.
     */
    -(BOOL)processOption:(PGCmdLineOption *)option param:(NSString *)param
                    item:(NSString *)item
                   index:(NSUInteger)idx unknownOptions:(NSMutableStrArray)unknownOptions
                   error:(NSError **)error {
        NSError *err = nil;

        if(option) {
            if(param && (option.argumentState == PGCmdLineArgNone)) {
                // If we have a parameter but this option does not take one...
                err = [self createError:PGErrorMsgCmdLineUnexpectedParameter index:idx item:item];
            }
            else if(!param && (option.argumentState == PGCmdLineArgRequired)) {
                // If the option requires a parameter but doesn't have one...
                err = [self createError:PGErrorMsgCmdLineParameterExpected index:idx item:item];
            }
            else if(option.wasFound && self.parseOptionDisallowDuplicates) {
                // If there was a duplicate option but duplicates are not allowed.
                err = [self createError:PGErrorMsgCmdLineDuplicateFound index:idx item:item];
            }
            else if(!(option.wasFound && self.parseOptionDuplicatesKeepFirst)) {
                // Normal case...
                if(param) param = [self validateItemParameter:param option:option item:item index:idx error:&err];

                if(!err) {
                    option.wasFound = YES;
                    option.argument = param;
                }
            }
        }
        else if([self testForError:self.parseOptionDisallowUknownOptions item:item index:idx reason:PGErrorMsgCmdLineUnknownOption error:&err]) {
            [unknownOptions addObject:item];
        }

        PGSetReference(error, err);
        return (err != nil);
    }

    /**
     * Validate a given parameter for an option based on it's specified type.
     *
     * @param param the parameter.
     * @param option the option.
     * @param item the command-line item.
     * @param idx the index of the command-line item.
     * @param error write-back parameter to receive any errors.
     * @return the parameter which may or may not have been "cleaned".
     */
    -(NSString *)validateItemParameter:(NSString *)param option:(PGCmdLineOption *)option item:(NSString *)item index:(NSUInteger)idx error:(NSError **)error {
        NSError  *err    = nil;
        NSString *errmsg = PGFormat(PGErrorMsgCmdLineParamNotValidType, otypes(option.argumentType));

        switch(option.argumentType) {
            case PGCmdLineArgTypeInteger: {
                NSScanner *sc = [NSScanner localizedScannerWithString:param];
                NSInteger si  = 0;
                if([self testForError:![sc scanInteger:&si] item:item index:idx reason:errmsg error:&err]) {
                    param = [@(si) stringValue];
                }
                break;
            }
            case PGCmdLineArgTypeFloat: {
                NSScanner *sc = [NSScanner localizedScannerWithString:param];
                double    sd  = 0.0;
                if([self testForError:![sc scanDouble:&sd] item:item index:idx reason:errmsg error:&err]) {
                    param = [@(sd) stringValue];
                }
                break;
            }
            case PGCmdLineArgTypeDate: {
                NSString *s = PGValidateDate(param);
                if([self testForError:(s == nil) item:item index:idx reason:errmsg error:&err]) {
                    param = s;
                }
                break;
            }
            case PGCmdLineArgTypeTime: {
                NSString *s = PGValidateTime(param);
                if([self testForError:(s == nil) item:item index:idx reason:errmsg error:&err]) {
                    param = s;
                }
                break;
            }
            case PGCmdLineArgTypeRegex: {
                NSRegularExpression *r = option.regex;
                if(r) {
                    @synchronized(r) {
                        if(![r matches:param]) err = [self createError:PGErrorMsgCmdLineParamNotValidRegex index:idx item:item];
                    }
                }
                break;
            }
            default: break;
        }

        PGSetReference(error, err);
        return param;
    }

    /**
     * Simple helper method that sets the error variable if the predicate is YES.
     *
     * @param predicate if YES then an error occurred and the error field will be set.
     * @param item the command-line item.
     * @param idx the index of the command-line item the error occurred with.
     * @param reason the description of the error.
     * @param error a pointer to an NSError variable.
     * @return NO if an error occurred or YES if there was no error.
     */
    -(BOOL)testForError:(BOOL)predicate item:(NSString *)item index:(NSUInteger)idx reason:(NSString *)reason error:(NSError **)error {
        if(predicate) PGSetReference(error, [self createError:reason index:idx item:item]);
        return !predicate;
    }

    -(PGCmdLineOption *)optionAtIndex:(NSUInteger)idx {
        PGCmdLineOptionSet opts = self.options;
        return (((idx == NSNotFound) || (idx >= opts.count)) ? nil : opts[idx]);
    }

    -(PGCmdLineOption *)findOptionPassingTest:(PGFindCmdLineOptionInArrayBlock)predicate {
        return [self optionAtIndex:[self.options indexOfObjectPassingTest:predicate]];
    }

    -(PGCmdLineOption *)findOptionByShortName:(NSString *)name {
        return [self findOptionPassingTest:^BOOL(PGCmdLineOption *option, NSUInteger i, BOOL *stop) { return PGStringsEqual(name, option.shortName); }];
    }

    -(PGCmdLineOption *)findOptionByLongName:(NSString *)name {
        return [self findOptionPassingTest:^BOOL(PGCmdLineOption *option, NSUInteger i, BOOL *stop) { return PGStringsEqual(name, option.longName); }];
    }

    -(NSString *)cleanOption:(NSString *)option {
        NSRegularExpression *regex = self.optionCleaningRegex;

        if(regex == nil) {
            @synchronized(self) {
                if((regex = self.optionCleaningRegex) == nil) {
                    NSError *error = nil;
                    self.optionCleaningRegex = regex = [NSRegularExpression cachedRegex:PGCmdLineCleanOptionPattern prefix:PGCmdLineRegexPrefix error:&error];
                    if(error) @throw [error makeException];
                }
            }
        }

        if(regex) {
            @synchronized(regex) {
                option = [regex stringByReplacingMatchesInString:option options:0 range:option.range withTemplate:@"$1"];
            }
        }

        return option;
    }

    -(NSString *)cleanNonOption:(NSString *)nonOption {
        NSRegularExpression *regex = self.nonOptionCleaningRegex;

        if(regex == nil) {
            @synchronized(self) {
                if((regex = self.nonOptionCleaningRegex) == nil) {
                    NSError *error = nil;
                    self.nonOptionCleaningRegex = regex = [NSRegularExpression cachedRegex:PGCmdLineCleanNonOptionPattern prefix:PGCmdLineRegexPrefix error:&error];
                    if(error) @throw [error makeException];
                }
            }
        }

        if(regex) {
            @synchronized(regex) {
                nonOption = [regex stringByReplacingMatchesInString:nonOption options:0 range:nonOption.range withTemplate:@"$1$2"];
            }
        }

        return nonOption;
    }

    -(NSError *)createError:(NSString *)msg index:(NSUInteger)idx item:(NSString *)item {
        /* @f:0 */ NSDictionary *dict = @{ NSLocalizedDescriptionKey: msg, PGCmdLineErrorIndexKey: @(idx), PGCmdLineErrorItemKey: item }; /* @f:1 */
        return [NSError errorWithDomain:PGErrorDomain code:PGErrorCodeCmdLineParseError userInfo:dict];
    }

    -(BOOL)parseOptionDisallowNonOptions {
        return ((self.parseOptions & PGCmdLineParseOptionDisallowNonOptions) == PGCmdLineParseOptionDisallowNonOptions);
    }

    -(BOOL)parseOptionDisallowMixingOptionsAndNonOptions {
        return ((self.parseOptions & PGCmdLineParseOptionDisallowMixingOptionsAndNonOptions) == PGCmdLineParseOptionDisallowMixingOptionsAndNonOptions);
    }

    -(BOOL)parseOptionDisallowDuplicates {
        return ((self.parseOptions & PGCmdLineParseOptionDisallowDuplicates) == PGCmdLineParseOptionDisallowDuplicates);
    }

    -(BOOL)parseOptionDuplicatesKeepFirst {
        return ((self.parseOptions & PGCmdLineParseOptionDuplicatesKeepFirst) == PGCmdLineParseOptionDuplicatesKeepFirst);
    }

    -(BOOL)parseOptionDisallowUknownOptions {
        return ((self.parseOptions & PGCmdLineParseOptionDisallowUnknownOptions) == PGCmdLineParseOptionDisallowUnknownOptions);
    }

    -(NSString *)description {
        NSMutableString *description = [NSMutableString stringWithFormat:@"<%@:\n", NSStringFromClass([self class])];
        [description appendFormat:@"         executable: \"%@\"\n", self.executableName];
        [description appendFormat:@"            options: %lu\n", self.options.count];
        for(PGCmdLineOption *opt in self.options) {
            [description appendFormat:@"                   : %@\n", opt.description];
        }
        [description appendFormat:@"    unknown options: %lu\n", self.unknownOptions.count];
        for(NSString *str in self.unknownOptions) {
            [description appendFormat:@"                   : %@\n", str];
        }
        [description appendFormat:@"          arguments: %lu\n", self.nonOptionArguments.count];
        for(NSString *str in self.nonOptionArguments) {
            [description appendFormat:@"                   : %@\n", str];
        }
        [description appendString:@">"];
        return description;
    }

    -(id)copyWithZone:(nullable NSZone *)zone {
        return self; // PGCmdLine is immutable...
    }

@end

