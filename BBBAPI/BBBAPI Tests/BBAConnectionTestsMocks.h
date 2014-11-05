//
//  BBAConnectionTestsMocks.h
//  BBBAPI
//
//  Created by Tomek Kuźma on 24/10/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBARequestFactory.h"
#import "BBANetworkConfiguration.h"
#import "BBAAuthenticator.h"

@class BBARequest;
@class BBAUserDetails;

@interface BBAMockNetworkConfiguration : BBANetworkConfiguration
@property (nonatomic, assign) BBAAPIDomain passedDomain;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) id authenticator;
@end

@interface BBAMockAuthenticator : NSObject <BBAAuthenticator>
@property (nonatomic, strong) BBARequest *passedRequest;
@property (nonatomic, strong) BBAUserDetails *passedUser;

@property (nonatomic, strong) NSError *errorToReturn;
@property (nonatomic, assign) BOOL valueToReturn;
@property (nonatomic, assign) BOOL wasAskedToAuthenticate;
@end


@interface BBAMockRequestFactory : BBARequestFactory
@property (nonatomic, strong) NSURL *passedURL;
@property (nonatomic, strong) NSDictionary *passedParameters;
@property (nonatomic, strong) NSDictionary *passedHeaders;
@property (nonatomic, assign) BBAHTTPMethod passedMethod;
@property (nonatomic, assign) BBAContentType passedContentType;

@property (nonatomic, strong) BBARequest *requestToReturn;
@property (nonatomic, strong) NSError *errorToReturn;
@end