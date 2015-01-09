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
#import "BBALibraryResponseMapper.h"
#import "BBAStatusResponseMapper.h"
#import "BBAKeyServiceResponseMapper.h"
#import "BBALibraryService.h"
#import "BBAKeyService.h"

@interface BBANetworkConfiguration ()

@property (nonatomic, strong) id<BBAAuthenticator> authenticator;

@property (nonatomic, strong) NSMutableDictionary *endpoints;

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

- (id) init{
    self = [super init];
    return self;
}

- (id<BBAAuthenticator>) authenticator{
    if (!_authenticator) {
        _authenticator = [BBADefaultAuthenticator new];
    }
    return _authenticator;
}

- (id<BBAAuthenticator>) sharedAuthenticator{
    return [self authenticator];
}

- (void) setSharedAuthenticator:(id<BBAAuthenticator>) authenticator{
    NSParameterAssert(authenticator);
    if (authenticator) {
        [self setAuthenticator:authenticator];
    }
}

- (id<BBAResponseMapping>) newResponseMapperForServiceName:(NSString *)name{
    if ([name isEqualToString:kBBAAuthServiceName]) {
        return [BBAAuthResponseMapper new];
    }
    else if ([name isEqualToString:kBBAAuthServiceTokensName]) {
        return [BBATokensResponseMapper new];
    }
    else if ([name isEqualToString:kBBAAuthServiceClientsName]) {
        return [BBAClientsResponseMapper new];
    }
    else if ([name isEqualToString:BBALibraryServiceName]) {
        return [BBALibraryResponseMapper new];
    }
    else if ([name isEqualToString:BBAStatusResponseServiceName]) {
        return [BBAStatusResponseMapper new];
    }
    else if ([name isEqualToString:BBAKeyServiceName]) {
        return [BBAKeyServiceResponseMapper new];
    }
    NSAssert(NO, @"unexpected service name : %@", name);
    return nil;
}

- (NSMutableDictionary *) endpoints{
    
    if (_endpoints) {
        return _endpoints;
    }
    
    _endpoints = [NSMutableDictionary new];
    _endpoints[@(BBAAPIDomainREST)] = [NSURL URLWithString:@"https://api.blinkboxbooks.com/service/"];
    _endpoints[@(BBAAPIDomainAuthentication)] = [NSURL URLWithString:@"https://auth.blinkboxbooks.com"];
    return _endpoints;
}

- (NSURL *) baseURLForDomain:(BBAAPIDomain)domain{
    
    NSURL *baseURL = self.endpoints[@(domain)];
    
    if (!self.delegate) {
        NSAssert(baseURL, @"No baseURL for domain %ld", domain);
        return baseURL;
    }
    
    NSURL *overridenURL;
    
    
    overridenURL = [self.delegate configuration:self
                                overrideBaseURL:baseURL
                                      forDomain:domain];
    
    if (overridenURL) {
        return overridenURL;
    }
    
    return baseURL;
}

- (void) setBaseURL:(NSURL *)baseURL forDomain:(BBAAPIDomain)domain{
    NSParameterAssert(baseURL);
    
    self.endpoints[@(domain)] = baseURL;
}

@end
