//
//  BBAServerDateFormatter.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 11/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAServerDateFormatter.h"

@implementation BBAServerDateFormatter

- (id) init{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) setup{
    [self setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [self setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [self setLocale:[NSLocale localeWithLocaleIdentifier:@"en_GB"]];
}

- (NSString  *) removeMillisecondsFromString:(NSString *)string{
    if ([string length] == 20) {
        return string;
    }
    //2014-08-04T17:31:55.773Z
    NSString *cut = [string stringByReplacingCharactersInRange:NSMakeRange(19, 5) withString:@""];
    return [cut stringByAppendingString:@"Z"];
}

- (NSDate *) dateFromString:(NSString *)string{
    NSParameterAssert(string);
    return [super dateFromString:[self removeMillisecondsFromString:string]];
}

@end
