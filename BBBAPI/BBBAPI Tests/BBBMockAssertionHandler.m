//
//  BBBMockAssertionHandler.m
//  BBBIosApp
//
//  Created by Tomek Kuźma on 28/05/2014.
//  Copyright (c) 2014 blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBBMockAssertionHandler.h"

@implementation BBBMockAssertionHandler
- (void)handleFailureInMethod:(SEL)selector
                       object:(id)object
                         file:(NSString *)fileName
                   lineNumber:(NSInteger)line
                  description:(NSString *)format, ...
{

}

- (void)handleFailureInFunction:(NSString *)functionName
                           file:(NSString *)fileName
                     lineNumber:(NSInteger)line
                    description:(NSString *)format, ...
{

}

@end
