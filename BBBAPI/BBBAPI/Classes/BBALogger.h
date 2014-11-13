//
//  BBALogger.h
//  BBAAPI
//
//  Created by Owen Worley on 26/08/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BBALog(frmt, ...) \
[BBALogger log:(frmt), ##__VA_ARGS__]

/**
 *  BBALog provides console, asl and file logging to the API project.
 */
@interface BBALogger : NSObject
+ (void) log:(NSString *)format, ... __attribute__((format(__NSString__,1,2)));
@end
