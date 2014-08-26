//
//  BBBLogger.h
//  BBBAPI
//
//  Created by Owen Worley on 26/08/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifdef COCOAPODS_POD_AVAILABLE_CocoaLumberjack
#undef LOG_LEVEL_DEF
#define LOG_LEVEL_DEF BBBAPILogLevel
static const int BBBAPILogLevel = LOG_LEVEL_VERBOSE;
#endif

#define BBBLog(frmt, ...) \
[BBBLogger log:(frmt), ##__VA_ARGS__]

/**
 *  BBBLog provides console, asl and file logging to the API project.
 */
@interface BBBLogger : NSObject
+ (void) log:(NSString *)format, ... __attribute__((format(__NSString__,1,2)));
@end
