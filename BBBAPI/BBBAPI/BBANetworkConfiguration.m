//
//  BBANetworkConfiguration.m
//  BBANetworking
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBANetworkConfiguration.h"
#import "BBAAuthResponseMapper.h"
#import "BBATokensResponseMapper.h"
#import "BBAClientsResponseMapper.h"
#import "BBAAuthenticationServiceConstants.h"
#import "BBADefaultAuthenticator.h"

@implementation BBANetworkConfiguration

+ (instancetype)defaultConfiguration{
    
    static BBANetworkConfiguration *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}



- (id)init{
    self = [super init];
    self.authenticator = [BBADefaultAuthenticator new];
    return self;
}

- (id<BBAAuthenticator>) sharedAuthenticator{
    return [self authenticator];
}

+ (void) setSharedAuthenticator:(id<BBAAuthenticator>) authenticator{
    [[self defaultConfiguration ]setAuthenticator:authenticator];
}

- (void) assignDefaultMapper{
    //    [self setReponseMapper:[BBAAuthResponseMapper new] forServiceName:kAuthServiceName];
}

+ (id<BBAResponseMapping>)responseMapperForServiceName:(NSString *)name{
    if ([name isEqualToString:kBBAAuthServiceName]) {
        return [BBAAuthResponseMapper new];
    }
    if ([name isEqualToString:kBBAAuthServiceTokensName]) {
        return [BBATokensResponseMapper new];
    }
    if ([name isEqualToString:kBBAAuthServiceClientsName]) {
        return [BBAClientsResponseMapper new];
    }
    return nil;
}

- (NSURL *)baseURLForDomain:(BBAAPIDomain)domain{
    NSURL *baseURL = nil;
    switch (domain) {
        case BBAAPIDomainAuthentication:
            baseURL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com"];
            break;
        case BBAAPIDomainREST:
            baseURL = [NSURL URLWithString:@"https://api.blinkboxbooks.com"];
            break;
            
        default:
            break;
    }
    NSAssert(baseURL, @"No baseURL for domain %ld", domain);
    return baseURL;
}

@end
