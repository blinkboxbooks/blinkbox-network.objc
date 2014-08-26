//
//  BBBLog.m
//  BBBAPI
//
//  Created by Owen Worley on 26/08/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import "BBBLogger.h"

@implementation BBBLogger
/**
 *  Perform one time initialisation of logger when it is first loaded.
 *
 *  Set up our loggers. Logs currently go to XCode Console and ASL (console.app).
 *
 *  We should add file logging later, and optionally remote network logging.
 *
 *  We can make the debug menu in the app read the file logs, that would be epic.
 *
 *  We should maybe consider some simple crypto on the logs that we save.
 *
 *  Lumberjack supports a nice file logger API which batches saves, making zip and crypto relatively
 *  straight forward.
 *
 *  Exciting!!
 */

+ (void) load{
#if COCOAPODS_POD_AVAILABLE_CocoaLumberjack
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
#endif
}

+ (void) log:(NSString *)format, ...{
    va_list args;
    va_start(args, format);
    [self log:format withParameters:args];
    va_end(args);
}

+ (void) log:(NSString *)format withParameters:(va_list)args{
    NSString *message = [[NSString alloc]initWithFormat:format arguments:args];
#if COCOAPODS_POD_AVAILABLE_CocoaLumberjack
    DDLogInfo(@"%@", message);
#else
    NSLog(@"%@", message);
#endif
}

@end
