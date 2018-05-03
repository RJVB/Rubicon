#import "PGInternal.h"
#import "PGCmdLineCommon.h"

NSString *const PGCmdLineRegexPrefix                  = @"🍸";
NSString *const PGCmdLineCleanOptionPattern           = @"^\\s*(-{1,2})\\s*";
NSString *const PGCmdLineCleanNonOptionPattern        = @"^(\\s*)\\\\(-|\\\\)";
NSString *const PGCmdLineLongOptionParamMarkerPattern = @"\\s*=";
NSString *const PGCmdLineLongOptionMarker             = @"--";
NSString *const PGCmdLineShortOptionMarker            = @"-";
NSString *const PGCmdLineCleanOptionTemplate          = @"$1";
NSString *const PGCmdLineCleanNonOptionTemplate       = @"$1$2";

NS_INLINE BOOL PGCmdLineStringsEqual(NSString *s1, NSString *s2) {
    if((s1 == nil) && (s2 == nil)) return NO;
    return PGStringsEqual(s1, s2);
}

void PGAddCmdLineOptionToList(PGCmdLineOption *option, NSMutableArray<PGCmdLineOption *> *optionList) {
    PGFindCmdLineOptionInArrayBlock blk = ^BOOL(PGCmdLineOption *obj, NSUInteger idx, BOOL *stop) {
        return (PGCmdLineStringsEqual(obj.shortName, option.shortName) || PGCmdLineStringsEqual(obj.longName, option.longName));
    };

    NSUInteger idx = [optionList indexOfObjectPassingTest:blk];

    while(idx != NSNotFound) {
        [optionList removeObjectAtIndex:idx];
        idx = [optionList indexOfObjectPassingTest:blk];
    }

    [optionList addObject:[option copy]];
}

NSArray<PGCmdLineOption *> *PGCreateOptionsList(NSArray<PGCmdLineOption *> *options) {
    NSMutableArray<PGCmdLineOption *> *opts = [NSMutableArray arrayWithCapacity:options.count];

    for(PGCmdLineOption *opt in options) {
        PGAddCmdLineOptionToList(opt, opts);
    }

    return opts;
}

NSStrArray PGConvertCommandLineItems(NSUInteger argc, const char **argv, NSStringEncoding encoding, NSError **error) {
    if(argc && argv) {
        NSMutableStrArray args = [NSMutableArray arrayWithCapacity:argc];

        do {
            if(*argv) {
                [args addObject:[NSString stringWithCString:*(argv++) encoding:encoding]];
            }
            else {
                NSDictionary *dict = @{ NSLocalizedDescriptionKey: PGErrorMsgCmdLineInvalidCommandLine };
                PGSetReference(error, [NSError errorWithDomain:PGErrorDomain code:PGErrorCodeCmdLineParseError userInfo:dict]);
                return nil;
            }
        }
        while(--argc);

        return [NSArray arrayWithArray:args];
    }

    return @[];
}
