//
//  BBBAuthServiceErrorParser.h
//  BBBAPI
//
//  Created by Owen Worley on 12/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBBAuthServiceErrorParser : NSObject
- (NSError *) errorForResponseJSON:(NSDictionary *)JSON
                        statusCode:(NSInteger)statusCode;
@end
