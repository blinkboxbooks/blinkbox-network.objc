//
//  BBBAuthServiceErrorParser.h
//  BBBAPI
//
//  Created by Owen Worley on 12/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Parses server responses (JSON + statusCode) for common Auth errors such as invalid_grant
 */
@interface BBBAuthServiceErrorParser : NSObject
/**
 *  Return an NSError describing the auth service error for this JSON and statusCode, or nil
 *  if no error was encountered
 *
 *  @param JSON       A dictionary of response values from the server
 *  @param statusCode The statuscode of the HTTP Response
 *
 *  @return An NSError describing the server error or nil if no error was detected.
 */
- (NSError *) errorForResponseJSON:(NSDictionary *)JSON
                        statusCode:(NSInteger)statusCode;
@end
