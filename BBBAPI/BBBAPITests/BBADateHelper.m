//
//  BBADateHelper.m
//  BBBAPI
//
//  Created by Owen Worley on 09/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBADateHelper.h"
#import <time.h>
#import <xlocale.h>

@implementation BBADateHelper
+ (NSString *) dateFormat{
    return @"%Y-%m-%dT%H:%M:%SZ";
}

+ (NSDate *) dateFromString:(NSString *)string{
    if (!string) {
        return nil;
    }
    struct tm  time;
    const char *formatString = [[self dateFormat] cStringUsingEncoding:NSUTF8StringEncoding];

    (void) strptime_l([string cStringUsingEncoding:NSUTF8StringEncoding], formatString, &time, NULL);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: mktime(&time)];
    return date;
}

+ (NSString *) stringFromDate:(NSDate *)date{
    if (!date) {
        return nil;
    }
    const char *formatString = [[self dateFormat] cStringUsingEncoding:NSUTF8StringEncoding];
    char buf[20];
    time_t clock = [date timeIntervalSince1970];
    struct tm time;
    gmtime_r(&clock, &time);
    strftime_l(buf, sizeof(buf), formatString, &time, NULL);
    return [NSString stringWithUTF8String:buf];
}

@end
