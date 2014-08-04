//
//  BBBNetworkConfiguration.m
//  BBBNetworking
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBNetworkConfiguration.h"
#import "BBBAuthResponseMapper.h"
#import "BBBAuthenticationService.h"

@implementation BBBNetworkConfiguration

+ (instancetype)shared{
    return nil;
}
- (id)init{
    self = [super init];

    return self;
}

- (void) assignDefaultMapper{
//    [self setReponseMapper:[BBBAuthResponseMapper new] forServiceName:kAuthServiceName];
}
@end
