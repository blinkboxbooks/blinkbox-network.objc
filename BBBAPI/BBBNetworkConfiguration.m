//
//  BBBNetworkConfiguration.m
//  BBBNetworking
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBNetworkConfiguration.h"
#import "BBBAuthResponseMapper.h"
#import "BBBTokensResponseMapper.h"
#import "BBBClientsResponseMapper.h"
#import "BBBAuthenticationServiceConstants.h"
#import "BBBDefaultAuthenticator.h"

@implementation BBBNetworkConfiguration

+ (instancetype)shared{

    static BBBNetworkConfiguration *sharedInstance = nil;

        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[self alloc] init];
        });
        return sharedInstance;
}

- (id)init{
    self = [super init];
    self.authenticator = [BBBDefaultAuthenticator new];
    return self;
}

+ (id<BBBAuthenticator>) sharedAuthenticator{
    return [[self shared]authenticator];
}

+ (void) setSharedAuthenticator:(id<BBBAuthenticator>) authenticator{
    [[self shared]setAuthenticator:authenticator];
}

- (void) assignDefaultMapper{
//    [self setReponseMapper:[BBBAuthResponseMapper new] forServiceName:kAuthServiceName];
}

+ (id<BBBResponseMapping>)responseMapperForServiceName:(NSString *)name{
    if ([name isEqualToString:kBBBAuthServiceName]) {
        return [BBBAuthResponseMapper new];
    }
    if ([name isEqualToString:kBBBAuthServiceTokensName]) {
        return [BBBTokensResponseMapper new];
    }
    if ([name isEqualToString:kBBBAuthServiceClientsName]) {
        return [BBBClientsResponseMapper new];
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
