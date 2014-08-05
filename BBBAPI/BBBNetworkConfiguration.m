//
//  BBBNetworkConfiguration.m
//  BBBNetworking
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBNetworkConfiguration.h"
#import "BBBAuthResponseMapper.h"
#import "BBBAuthenticationServiceConstants.h"

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

+ (id<BBBResponseMapping>)responseMapperForServiceName:(NSString *)name{
    if ([name isEqualToString:kBBBAuthServiceName]) {
        return [BBBAuthResponseMapper new];
    }
    return nil;
}

+ (NSURL *)baseURLForDomain:(BBBAPIDomain)domain{
    NSURL *baseURL = nil;
    switch (domain) {
        case BBBAPIDomainAuthentication:
            baseURL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com"];
            break;

        default:
            break;
    }
    NSAssert(baseURL, @"No baseURL for domain %i", domain);
    return baseURL;
}

@end
