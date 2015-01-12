//
//  BBAServerDateFormatter.h
//  BBAAPI
//
//  Created by Tomek Kuźma on 11/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The `BBAServerDateFormatter` is responsible for parsing strings in this format:
 *  `@"yyyy-MM-dd'T'HH:mm:ss'Z'`
 *  into `NSDate` object, additionaly cropping milliseconds part of the string
 */
@interface BBAServerDateFormatter : NSDateFormatter

@end
