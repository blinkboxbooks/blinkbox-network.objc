//
//  BBBNetworkConfiguration.h
//  BBBNetworking
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBBResponseMapping.h"

typedef NS_ENUM(NSInteger, BBBAPIDomain) {
    BBBAPIDomainAuthentication = 0,
    BBBAPIDomainREST = 1
};

@interface BBBNetworkConfiguration : NSObject

+ (void) setBaseURL:(NSURL *)baseURL forDomain:(BBBAPIDomain)domain;
+ (NSURL *)baseURLForDomain:(BBBAPIDomain)domain;

+ (void) setReponseMapper:(id<BBBResponseMapping>)mapper forServiceName:(NSString *)serviceName;
+ (id<BBBResponseMapping>)responseMapperForServiceName:(NSString *)name;

@end
