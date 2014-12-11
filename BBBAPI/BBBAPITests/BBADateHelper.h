//
//  BBADateHelper.h
//  BBBAPI
//
//  Created by Owen Worley on 09/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Provides conversion of `NSString` to `NSDate` for the date format used by the server.
 */
@interface BBADateHelper : NSObject

/**
 *  Return an `NSDate` given an `NSString` containing a date in the server format
 *
 *  @param string `NSString` containing a date in the format ((%Y-%m-%dT%H:%M:%SZ"))
 *
 *  @return `NSDate`
 */
+ (NSDate *) dateFromString:(NSString *)string;

/**
 *  Returns an `NSString` given an `NSDate`
 *
 *  @param date `NSDate` to convert to `NSString` in server date format
 *
 *  @return `NSString` in server date format
 */
+ (NSString *) stringFromDate:(NSDate *)date;

@end
