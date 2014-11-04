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

@interface BBANetworkConfiguration ()

@property (nonatomic, strong) id<BBAAuthenticator> authenticator;

@end

@implementation BBANetworkConfiguration

+ (instancetype) defaultConfiguration{
    
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}



- (id)init{
    self = [super init];
    return self;
}

- (id<BBAAuthenticator>)authenticator{
    if (!_authenticator) {
        _authenticator = [BBADefaultAuthenticator new];
    }
    return _authenticator;
}

- (id<BBAAuthenticator>) sharedAuthenticator{
    return [self authenticator];
}

- (void) setSharedAuthenticator:(id<BBAAuthenticator>) authenticator{
    [self setAuthenticator:authenticator];
}

-(id<BBAResponseMapping>) responseMapperForServiceName:(NSString *)name{
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
