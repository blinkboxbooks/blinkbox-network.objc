//
//  BBBAuthConnection.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 31/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBAuthConnection.h"

@implementation BBBAuthConnection
- (void) setPassword:(NSString *)password{
    if (password) {
        [super addParameterWithKey:@"password" value:password];
    }
    else{
        [super removeParameterWithKey:@"password" ];
    }
}
@end
