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

@interface BBANetworkConfiguration : NSObject
@property (nonatomic, strong) id<BBAAuthenticator> authenticator;
+ (id<BBAAuthenticator>) sharedAuthenticator;
+ (void) setSharedAuthenticator:(id<BBAAuthenticator>) authenticator;
+ (void) setBaseURL:(NSURL *)baseURL forDomain:(BBAAPIDomain)domain;
+ (NSURL *)baseURLForDomain:(BBAAPIDomain)domain;

+ (void) setReponseMapper:(id<BBAResponseMapping>)mapper forServiceName:(NSString *)serviceName;
+ (id<BBAResponseMapping>)responseMapperForServiceName:(NSString *)name;

@end
