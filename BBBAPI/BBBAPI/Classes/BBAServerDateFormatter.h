//
//  BBAServerDateFormatter.h
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 11/08/2014.
 

#import <Foundation/Foundation.h>

/**
 *  The `BBAServerDateFormatter` is responsible for parsing strings in this format:
 *  `@"yyyy-MM-dd'T'HH:mm:ss'Z'`
 *  into `NSDate` object, additionaly cropping milliseconds part of the string
 */
@interface BBAServerDateFormatter : NSDateFormatter

@end
