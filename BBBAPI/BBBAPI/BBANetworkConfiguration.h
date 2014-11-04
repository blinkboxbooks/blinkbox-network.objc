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
    BBAAPIDomainAuthentication = 0,
    BBAAPIDomainREST = 1
};

/**
 *  A `BBANetworkConfiguraiton` object provides default values as well as allows 
 *  to customise basic variables of the network stack, suck as endpoints addresses, 
 *  response mappers, objects responsible for authenticating requests and so on.
 */
@interface BBANetworkConfiguration : NSObject


+ (BBANetworkConfiguration *) defaultConfiguration;

- (id<BBAAuthenticator>) sharedAuthenticator;

-  (void) setSharedAuthenticator:(id<BBAAuthenticator>) authenticator;

- (NSURL *) baseURLForDomain:(BBAAPIDomain)domain;

- (void) setBaseURL:(NSURL *)baseURL forDomain:(BBAAPIDomain)domain;

- (id<BBAResponseMapping>) newResponseMapperForServiceName:(NSString *)name;

@end
