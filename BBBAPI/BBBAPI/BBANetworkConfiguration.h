//
//  BBANetworkConfiguration.h
//  BBANetworking
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBAResponseMapping.h"
#import "BBAAuthenticator.h"

typedef NS_ENUM(NSInteger, BBAAPIDomain) {
    /**
     *  API domain for network requests againsts authentication service
     */
    BBAAPIDomainAuthentication = 0,
    /**
     *  API domain for all services apart from authentication
     */
    BBAAPIDomainREST = 1
};

/**
 *  A `BBANetworkConfiguraiton` object provides default values as well as allows 
 *  to customise basic variables of the network stack, suck as endpoints addresses, 
 *  response mappers, objects responsible for authenticating requests and so on.
 */
@interface BBANetworkConfiguration : NSObject

/**
 *  Returns shared instance of the configuratio objects with defaults values
 *
 *  @return shared singleton instance of `BBANetworkConfiguration`
 */
+ (BBANetworkConfiguration *) defaultConfiguration;

/**
 *  Object conforming to `BBAAuthenticator` protocol, is used by all requests 
 *  in the BBBAPI. By defaults returns `BBADefaultsAuthenticator` which doesn't 
 *  persist any information to disk and performs login/register every time
 *  call to authenticate a request is received.
 *
 *  @see BBADefaultAuthenticator
 *  @see BBAAuthenticator
 *  @return retained value of object conforming to `BBAAuthenticator` protocol
 */
- (id<BBAAuthenticator>) sharedAuthenticator;

/**
 *  Overrides default/current authenticator, must not be `nil`.
 *
 *  @param authenticator authenticator to be used by the BBBAPI framwork
 */
-  (void) setSharedAuthenticator:(id<BBAAuthenticator>) authenticator;

/**
 *  Method to get current base URL that requests will be sent to
 *
 *  @param domain value of an enum BBAAPIDomain
 *
 *  @return `NSURL` object to perform requests in the given domain
 */
- (NSURL *) baseURLForDomain:(BBAAPIDomain)domain;

/**
 *  Customises the base URL for a given `domain`, changes the value returned by
 *  the `baseURLForDomain` method
 *
 *  @param baseURL `NSURL` object describing new endpoint, must not be `nil`.
 *  @param domain  domain enum
 */
- (void) setBaseURL:(NSURL *)baseURL forDomain:(BBAAPIDomain)domain;

/**
 *  Creates new object conforming to `BBAResponseMapping` assigned to map
 *  responses to usable format for given service or part of service
 *
 *  Supported services:
 *
 *  - kBBAAuthServiceName
 *  - kBBAAuthServiceTokensName
 *  - kBBAAuthServiceClientsName
 *  - BBALibraryServiceName
 *  - BBAStatusResponseServiceName
 *
 *  @param name must be on the list of supported services, throws otherwise
 *
 *  @return new instance of apprioprate mapper
 */
- (id<BBAResponseMapping>) newResponseMapperForServiceName:(NSString *)name;

@end
