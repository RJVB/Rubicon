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

NS_INLINE NSString *convertString(const char *cstr, NSStringEncoding encoding) {
    return (cstr ? [NSString stringWithCString:cstr encoding:encoding] : nil);
}

@implementation PGCmdLine {
        NSString        *_description;
        NSUInteger      _hash;
        dispatch_once_t _descOnce;
        dispatch_once_t _hashOnce;
        BOOL            _initDone;
    }

    @synthesize rawArguments = _rawArguments;
    @synthesize parseOptions = _parseOptions;
    @synthesize encoding = _encoding;
    @synthesize nonOptionArguments = _nonOptionArguments;
    @synthesize options = _options;
    @synthesize executableName = _executableName;
    @synthesize unknownOptions = _unknownOptions;

    -(instancetype)initWithArguments:(const char **)argv
                              length:(NSUInteger)argc encoding:(NSStringEncoding)encoding
                        parseOptions:(PGCmdLineParseOptions)parseOptions
                             options:(NSArray<PGCmdLineOption *> *)options
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

            _executableName     = convertString(*argv, _encoding);
            _options            = PGCreateOptionsList(options);
            _parseOptions       = parseOptions;
            _nonOptionArguments = @[];
            _unknownOptions     = @[];

            if([self parseCommandLine:_rawArguments error:error] || [self checkRequiredOptions:_options error:error]) return nil;
            _initDone = YES;
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
        @try {
            NSError *err      = nil;
            BOOL    softStop  = NO;
            BOOL    noMixing  = self.parseOptionDisallowMixingOptionsAndNonOptions;
            BOOL    noNonOpts = self.parseOptionDisallowNonOptions;

            NSMutableStrArray   nonOptionArgs        = [NSMutableArray new];
            NSMutableStrArray   unknownOptions       = [NSMutableArray new];
            NSRegularExpression *cleanOptionRegex    = [NSRegularExpression regularExpressionWithPattern:PGCmdLineCleanOptionPattern options:0 error:&err];
            NSRegularExpression *cleanNonOptionRegex = (err ? nil : [NSRegularExpression regularExpressionWithPattern:PGCmdLineCleanNonOptionPattern options:0 error:&err]);

            for(NSUInteger idx = 0, length = cmdLine.count; ((idx < length) && (!err)); idx++) {
                NSString *item = [cleanOptionRegex stringByReplacingMatchesInString:cmdLine[idx] withTemplate:PGCmdLineCleanOptionTemplate];

                if([item isEqualToString:PGCmdLineLongOptionMarker]) {
                    idx = [self handleRemainingArguments:cmdLine index:(idx + 1) cleanRegex:cleanNonOptionRegex nonOptionArguments:nonOptionArgs error:&err];
                }
                else if([item hasPrefix:PGCmdLineLongOptionMarker]) {
                    if([self test:(softStop && noMixing) item:item index:idx reason:PGErrorMsgCmdLineCannotMixOptionsAndNonOptions error:&err]) {
                        NSString *stripped = [item substringFromIndex:PGCmdLineLongOptionMarker.length];
                        [self processLongOption:stripped index:idx unknownOptions:unknownOptions error:&err];
                    }
                }
                else if((item.length > PGCmdLineShortOptionMarker.length) && [item hasPrefix:PGCmdLineShortOptionMarker]) {
                    if([self test:(softStop && noMixing) item:item index:idx reason:PGErrorMsgCmdLineCannotMixOptionsAndNonOptions error:&err]) {
                        idx = [self processShortOptions:[item substringFromIndex:PGCmdLineShortOptionMarker.length]
                                                cmdLine:cmdLine
                                                  index:idx
                                       cleanOptionRegex:cleanOptionRegex
                                    cleanNonOptionRegex:cleanNonOptionRegex
                                         unknownOptions:unknownOptions
                                                  error:&err];
                    }
                }
                else if([self test:noNonOpts item:item index:idx reason:PGErrorMsgCmdLineNonOptionItemsNotAllowed error:&err]) {
                    if(noMixing && !softStop) softStop = YES;
                    [nonOptionArgs addObject:[cleanNonOptionRegex stringByReplacingMatchesInString:item withTemplate:PGCmdLineCleanNonOptionTemplate]];
                }
            }

            PGSetReference(error, err);
            if(nonOptionArgs.count) _nonOptionArguments = nonOptionArgs;
            if(unknownOptions.count) _unknownOptions    = unknownOptions;
            return ((err != nil) || [self checkRequiredOptions:self.options error:error]);
        }
        @catch(NSException *exception) {
            PGSetReference(error, [exception makeError]);
            return YES;
        }
    }

    /**
     * Check for any required options that weren't found in the command-line and produce an error if any are found.
     *
     * @param options the list of options.
     * @param error write-back parameter to receive the error if any.
     * @return YES if there were required options that weren't found in the command-line.
     */
    -(BOOL)checkRequiredOptions:(NSArray<PGCmdLineOption *> *)options error:(NSError **)error {
        if(options.count) {
            NSMutableString *nfs = nil;

            for(PGCmdLineOption *opt in options) {
                if(opt.isRequired && !opt.wasFound) {
                    if(nfs) [nfs appendFormat:@", %@", opt.nameDescription];
                    else nfs = [NSMutableString stringWithFormat:PGErrorMsgCmdLineOptionsNotFound, opt.nameDescription];
                }
            }

            if(nfs) {
                PGSetReference(error, [NSError errorWithDomain:PGErrorDomain code:PGErrorCodeCmdLineParseError userInfo:@{ NSLocalizedDescriptionKey: nfs }]);
                return YES;
            }
        }

        PGSetReference(error, nil);
        return NO;
    }

    /**
     * If non-option arguments are allowed then copy the remaining command-line items to the arguments array.
     *
     * @param cmdLine the command-line items.
     * @param idx the index of the first of the remaining items in the command-line.
     * @param regex the regular expression to use to clean the option.
     * @param nonOptionArgs the array to receive the arguments.
     * @param error pointer to a variable of NSError that will recieve an error if non-option arguments are not allowed.
     * @return the updated index value.
     */
    -(NSUInteger)handleRemainingArguments:(NSStrArray)cmdLine
                                    index:(NSUInteger)idx
                               cleanRegex:(NSRegularExpression *)regex
                       nonOptionArguments:(NSMutableStrArray)nonOptionArgs
                                    error:(NSError **)error {
        NSUInteger len = cmdLine.count;
        PGSetReference(error, nil);

        if((idx < len) && [self test:self.parseOptionDisallowNonOptions item:cmdLine[idx] index:idx reason:PGErrorMsgCmdLineNonOptionItemsNotAllowed error:error]) {
            do {
                NSString *clItem = cmdLine[idx++];
                NSString *arg    = [regex stringByReplacingMatchesInString:clItem withTemplate:PGCmdLineCleanNonOptionTemplate];
                [nonOptionArgs addObject:arg];
            }
            while(idx < len);
        }

        return (idx ? (idx - 1) : idx);
    }

    /**
     * Process long options.  Long options are option that begin with two hyphen characters ("--") such as "--foo" where "foo" is the option name. Additionally long options
     * can have parameters that are separated by a single equals sign ("=") such as "--foo=bar" where "foo" is the option name and "bar" is the parameter.
     *
     * @param item the command-line item.
     * @param idx the index in the command-line where this option occurred.
     * @param uo an array of unknown options that this option will be added to if it is not known.
     * @param error if the option is unknown and unknown options are not allowed then this write-back parameter will be populated with an error.
     * @return YES if an error occurred.
     */
    -(BOOL)processLongOption:(NSString *)item index:(NSUInteger)idx unknownOptions:(NSMutableStrArray)uo error:(NSError **)error {
        NSStrArray      ar      = [item componentsSeparatedByPattern:PGCmdLineLongOptionParamMarkerPattern limit:2];
        PGCmdLineOption *option = [self findOptionByLongName:ar[0]];
        NSString        *param  = ((ar.count > 1) ? ar[1] : nil);

        return (option ? [self processOption:option param:param item:item index:idx error:error] : [self processUnknownOption:item idx:idx unknownOptions:uo error:error]);
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
    -(NSUInteger)processShortOptions:(NSString *)item
                             cmdLine:(NSStrArray)cmdLine
                               index:(NSUInteger)idx
                    cleanOptionRegex:(NSRegularExpression *)optRegex
                 cleanNonOptionRegex:(NSRegularExpression *)nonOptRegex
                      unknownOptions:(NSMutableStrArray)unknownOptions
                               error:(NSError **)error {
        __block NSError    *err = nil;
        __block NSUInteger i    = idx;

        PGCharEnumBlock blk = ^BOOL(unichar c, unichar *dc, NSRange range, BOOL composed, NSString *before, NSString *after) {
            return [self processShortOptionsBlock:[NSString stringWithCharacters:dc length:range.length]
                                        remaining:after
                                         nextItem:(((i + 1) < cmdLine.count) ? cmdLine[i + 1] : nil)
                                            index:&i
                                   unknownOptions:unknownOptions
                                         optRegex:optRegex
                                      nonOptRegex:nonOptRegex
                                            error:&err];
        };

        [item enumerateOverCharactersWithBlock:blk];
        PGSetReference(error, err);
        return i;
    }

    -(BOOL)processShortOptionsBlock:(NSString *)name
                          remaining:(NSString *)remaining
                           nextItem:(NSString *)nitem
                              index:(NSUInteger *)idx
                     unknownOptions:(NSMutableStrArray)unknownOptions
                           optRegex:(NSRegularExpression *)optRegex
                        nonOptRegex:(NSRegularExpression *)nonOptRegex
                              error:(NSError **)error {
        PGCmdLineOption *option = [self findOptionByShortName:name];

        if(option) {
            if(option.argumentState != PGCmdLineArgNone) {
                if(remaining.length > 0) {
                    [self processOption:option param:remaining item:name index:(*idx) error:error];
                    return YES;
                }
                else if(nitem) {
                    NSString *cln = [optRegex stringByReplacingMatchesInString:nitem withTemplate:PGCmdLineCleanOptionTemplate];

                    if(!isOption(cln)) {
                        NSString *nopt = [nonOptRegex stringByReplacingMatchesInString:nitem withTemplate:PGCmdLineCleanNonOptionTemplate];
                        [self processOption:option param:nopt item:name index:(*idx)++ error:error];
                        return YES;
                    }
                }
            }

            return [self processOption:option param:nil item:name index:(*idx) error:error];
        }

        return [self processUnknownOption:name idx:(*idx) unknownOptions:unknownOptions error:error];
    }

    -(BOOL)processUnknownOption:(NSString *)item idx:(NSUInteger)idx unknownOptions:(NSMutableStrArray)unknownOptions error:(NSError **)error {
        if(self.parseOptionDisallowUknownOptions) {
            [self createError:PGErrorMsgCmdLineUnknownOption index:idx item:item error:error];
            return YES;
        }
        else if(![unknownOptions containsObject:item]) {
            [unknownOptions addObject:item];
        }

        return NO;
    }

    /**
     * Process the option...
     *
     * @param option the option
     * @param param the parameter if any.
     * @param item the command-line item.
     * @param idx the index of the command-line item.
     * @param error if an error occurs it will be stored in this write-back variable.
     * @return YES if an error occurred.
     */
    -(BOOL)processOption:(PGCmdLineOption *)option param:(NSString *)param item:(NSString *)item index:(NSUInteger)idx error:(NSError **)error {
        PGCmdLineOptionArgument argState = option.argumentState;
        BOOL                    wasFound = option.wasFound;

        if(param && (argState == PGCmdLineArgNone)) {
            // If we have a parameter but this option does not take one...
            [self createError:PGErrorMsgCmdLineUnexpectedParameter index:idx item:item error:error];
            return YES;
        }
        else if(!param && (argState == PGCmdLineArgRequired)) {
            // If the option requires a parameter but doesn't have one...
            [self createError:PGErrorMsgCmdLineParameterExpected index:idx item:item error:error];
            return YES;
        }
        else if(wasFound && self.parseOptionDisallowDuplicates) {
            // If there was a duplicate option but duplicates are not allowed.
            [self createError:PGErrorMsgCmdLineDuplicateFound index:idx item:item error:error];
            return YES;
        }
        else if(!(wasFound && self.parseOptionDuplicatesKeepFirst)) {
            // Normal case...
            if(param) { if((param = [self validateItemParameter:param option:option item:item index:idx error:error]) == nil) return YES; }
            option.wasFound = YES;
            option.argument = param;
        }

        if(error) *error = nil;
        return NO;
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
                if([self test:![sc scanInteger:&si] item:item index:idx reason:errmsg error:&err]) { param = [@(si) stringValue]; }
                break;
            }
            case PGCmdLineArgTypeFloat: {
                NSScanner *sc = [NSScanner localizedScannerWithString:param];
                double    sd  = 0.0;
                if([self test:![sc scanDouble:&sd] item:item index:idx reason:errmsg error:&err]) { param = [@(sd) stringValue]; }
                break;
            }
            case PGCmdLineArgTypeDate: {
                NSString *s = PGValidateDate(param);
                if([self test:(s == nil) item:item index:idx reason:errmsg error:&err]) { param = s; }
                break;
            }
            case PGCmdLineArgTypeTime: {
                NSString *s = PGValidateTime(param);
                if([self test:(s == nil) item:item index:idx reason:errmsg error:&err]) { param = s; }
                break;
            }
            case PGCmdLineArgTypeRegex: {
                NSRegularExpression *r = option.regex;
                if(r) {
                    @synchronized(r) {
                        if(![r matches:param]) {
                            NSRegularExpression *r1     = [NSRegularExpression regularExpressionWithPattern:@"(\"|\\\\)" options:0 error:nil];
                            NSString            *rx     = [r1 stringByReplacingMatchesInString:r.pattern withTemplate:@"\\\\$1"];
                            NSString            *pm     = [r1 stringByReplacingMatchesInString:param withTemplate:@"\\\\$1"];
                            NSString            *reason = PGFormat(PGErrorMsgCmdLineParamNotValidRegex, pm, rx);

                            [self createError:reason index:idx item:item error:&err];
                        }
                    }
                }
                else {
                    [self createError:PGErrorMsgBadRegexPattern index:idx item:item error:&err];
                }
                break;
            }
            default: break;
        }

        PGSetReference(error, err);
        return (err ? nil : param);
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
    -(BOOL)test:(BOOL)predicate item:(NSString *)item index:(NSUInteger)idx reason:(NSString *)reason error:(NSError **)error {
        if(predicate) [self createError:reason index:idx item:item error:error];
        return !predicate;
    }

    /**
     * Returns the option at the given index in the list.
     *
     * @param idx the index for the option.
     * @return the option at the given index or NULL if the index is greater than the number of options.
     */
    -(PGCmdLineOption *)optionAtIndex:(NSUInteger)idx {
        PGCmdLineOptionSet opts = self.options;
        return (((idx == NSNotFound) || (idx >= opts.count)) ? nil : opts[idx]);
    }

    /**
     * Find the option that passes the given test. The test is performed by the block passed in "predicate".
     *
     * @param predicate the test.
     * @return the option that passed the test or NULL if no options passed the test.
     */
    -(PGCmdLineOption *)findOptionPassingTest:(PGFindCmdLineOptionInArrayBlock)predicate {
        return [self optionAtIndex:[self.options indexOfObjectPassingTest:predicate]];
    }

    /**
     * Find the option with the given short name.
     *
     * @param name the short name.
     * @return the option with the given short name or NULL if not found.
     */
    -(PGCmdLineOption *)findOptionByShortName:(NSString *)name {
        return [self findOptionPassingTest:^BOOL(PGCmdLineOption *option, NSUInteger i, BOOL *stop) { return PGStringsEqual(name, option.shortName); }];
    }

    /**
     * Find the option with the given long name.
     *
     * @param name the long name.
     * @return the option with the given long name or NULL if not found.
     */
    -(PGCmdLineOption *)findOptionByLongName:(NSString *)name {
        return [self findOptionPassingTest:^BOOL(PGCmdLineOption *option, NSUInteger i, BOOL *stop) { return PGStringsEqual(name, option.longName); }];
    }

    /**
     * Create an error message object (an instance of NSError) that includes the command-line item and it's index.
     *
     * @param msg the error message.
     * @param idx the index.
     * @param item the command-line item.
     * @param error the write-back parameter for the error object.
     */
    -(void)createError:(NSString *)msg index:(NSUInteger)idx item:(NSString *)item error:(NSError **)error {
        if(error) {
            /* @f:0 */ NSDictionary *dict = @{ NSLocalizedDescriptionKey: msg, PGCmdLineErrorIndexKey: @(idx), PGCmdLineErrorItemKey: item }; /* @f:1 */
            (*error) = [NSError errorWithDomain:PGErrorDomain code:PGErrorCodeCmdLineParseError userInfo:dict];
        }
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

    /**
     * Return a meaningful description.
     *
     * @return the description.
     */
    -(NSString *)description {
        if(_initDone) {
            /*
             * Since PGCmdLine is immutable we really only need to generate the description once after it is created.
             */
            dispatch_once(&_descOnce, ^{
                NSString            *fmt000 = @"<%@:\n";
                NSString            *fmt001 = @"%@: \"%@\"\n";
                NSString            *fmt002 = @"%@: %lu\n";
                NSString            *fmt003 = @"                   : %@\n";
                NSString            *fmt004 = @"                   : \"%@\"";
                NSString            *suffix = @">";
                NSString            *padstr = @" ";
                NSUInteger          padlen  = 19;
                NSUInteger          padidx  = 0;
                NSRegularExpression *r      = [NSRegularExpression cachedRegex:@"(\"|\\\\)" error:nil];

                NSMutableString *description = [NSMutableString stringWithFormat:fmt000, NSStringFromClass([self class])];
                [description appendFormat:fmt001, [@"executable" stringByFrontPaddingToLength:padlen withString:padstr startingAtIndex:padidx], self.executableName];
                [description appendFormat:fmt002, [@"command-line" stringByFrontPaddingToLength:padlen withString:padstr startingAtIndex:padidx], self.rawArguments.count];
                [description appendFormat:fmt004, self.executableName];

                for(NSString *str in self.rawArguments) [description appendFormat:@", \"%@\"", [r stringByReplacingMatchesInString:str options:0 withTemplate:@"\\\\$1"]];
                [description appendString:@"\n"];

                [description appendFormat:fmt002, [@"options" stringByFrontPaddingToLength:padlen withString:padstr startingAtIndex:padidx], self.options.count];
                for(PGCmdLineOption *opt in self.options) [description appendFormat:fmt003, opt.description];
                [description appendFormat:fmt002, [@"unknown options" stringByFrontPaddingToLength:padlen withString:padstr startingAtIndex:padidx], self.unknownOptions.count];
                for(NSString *str in self.unknownOptions) [description appendFormat:fmt003, str];
                [description appendFormat:fmt002, [@"arguments" stringByFrontPaddingToLength:padlen withString:padstr startingAtIndex:padidx], self.nonOptionArguments.count];
                for(NSString *str in self.nonOptionArguments) [description appendFormat:fmt003, str];
                [description appendString:suffix];
                self->_description = description;
            });
            return _description;
        }
        return super.description;
    }

    /**
     * PGCmdLine is immutable to copy should just return itself.
     *
     * @param zone unused.
     * @return this instance.
     */
    -(id)copyWithZone:(nullable NSZone *)zone {
        return self; // PGCmdLine is immutable...
    }

    -(BOOL)isEqual:(id)other {
        return (other && ((other == self) || ([other isKindOfClass:[self class]] && [self _isEqualToCmdLine:other])));
    }

    -(BOOL)isEqualToCmdLine:(PGCmdLine *)cmdLine {
        return (cmdLine && ((cmdLine == self) || [self _isEqualToCmdLine:cmdLine]));
    }

    -(BOOL)_isEqualToCmdLine:(PGCmdLine *)cmdLine {
        return (PGArraysEqual(_rawArguments, cmdLine.rawArguments) &&     // Raw Arguments...
                (_parseOptions == cmdLine.parseOptions) &&                // Parsing Options...
                (_encoding == cmdLine.encoding) &&                        // Character Encoding...
                PGArraysEqual(_options, cmdLine.options) &&               // Command-line Options...
                PGStringsEqual(_executableName, cmdLine.executableName)); // Executable
    }

    -(NSUInteger)hash {
        if(_initDone) {
            /*
             * Since PGCmdLine is immutable we really only need to calculate the hash once after it is created.
             */
            dispatch_once(&_hashOnce, ^{
                self->_hash = (((((((([self->_rawArguments hash] * 31u) +      // Raw Arguments...
                                     (NSUInteger)self->_parseOptions) * 31u) + // Parsing Options...
                                   self->_encoding) * 31u) +                   // Character Encoding...
                                 [self->_options hash]) * 31u) +               // Command-line Options...
                               [self->_executableName hash]);                  // Executable
            });
            return _hash;
        }

        return super.hash;
    }

    +(instancetype)cmdLineWithArguments:(const char **)argv
                                 length:(NSUInteger)argc
                               encoding:(NSStringEncoding)encoding
                           parseOptions:(PGCmdLineParseOptions)parseOptions
                                options:(NSArray<PGCmdLineOption *> *)options
                                  error:(NSError **)error {
        return [[self alloc] initWithArguments:argv length:argc encoding:encoding parseOptions:parseOptions options:options error:error];
    }

    +(instancetype)cmdLineWithArguments:(const char **)argv
                                 length:(NSUInteger)argc
                           parseOptions:(PGCmdLineParseOptions)parseOptions
                                options:(NSArray<PGCmdLineOption *> *)options
                                  error:(NSError **)error {
        return [[self alloc] initWithArguments:argv length:argc encoding:NSUTF8StringEncoding parseOptions:parseOptions options:options error:error];
    }

    +(instancetype)cmdLineWithArguments:(const char **)argv
                                 length:(NSUInteger)argc
                               encoding:(NSStringEncoding)encoding
                           parseOptions:(PGCmdLineParseOptions)parseOptions
                             optionList:(const PGCmdLineOptionStruct *)options
                                  error:(NSError **)error {
        NSMutableArray<PGCmdLineOption *> *opts = [NSMutableArray new];

        while(options && (options->shortName || options->longName)) {
            [opts addObject:PGMakeCmdLineOpt(convertString(options->shortName, encoding),
                                             convertString(options->longName, encoding),
                                             options->isRequired,
                                             options->argumentState,
                                             options->argumentType,
                                             convertString(options->regexPattern, encoding))];
            options++;
        }

        return [self cmdLineWithArguments:argv length:argc encoding:encoding parseOptions:parseOptions options:opts error:error];
    }

    +(instancetype)cmdLineWithArguments:(const char **)argv
                                 length:(NSUInteger)argc
                           parseOptions:(PGCmdLineParseOptions)parseOptions
                             optionList:(const PGCmdLineOptionStruct *)options
                                  error:(NSError **)error {
        return [self cmdLineWithArguments:argv length:argc encoding:NSUTF8StringEncoding parseOptions:parseOptions optionList:options error:error];
    }

@end

