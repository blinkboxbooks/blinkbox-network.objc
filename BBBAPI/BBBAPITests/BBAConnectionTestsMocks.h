//
//  BBAConnectionTestsMocks.h
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 24/10/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBARequestFactory.h"
#import "BBAResponseMapping.h"
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

@property (nonatomic, strong) BBARequest *requestToReturn;
@property (nonatomic, strong) NSError *errorToReturn;
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

@interface BBAMockURLSessionDataTask : NSURLSessionDataTask

@end

@interface BBAMockURLSession : NSURLSession
@property (nonatomic, strong) NSURLRequest *passedRequest;

@property (nonatomic, strong) BBAMockURLSessionDataTask *taskToReturn;

@property (nonatomic, strong) NSError *errorToReturn;
@property (nonatomic, strong) NSURLResponse *responseToReturn;
@property (nonatomic, strong) NSData *dataToReturn;

@end

@interface BBAMockResponseMapper : NSObject <BBAResponseMapping>
@property (nonatomic, strong) id objectToReturn;
@property (nonatomic, strong) NSError *errorToReturn;
@end