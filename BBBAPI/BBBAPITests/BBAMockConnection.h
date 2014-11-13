//
//  BBAMockConnection.h
//  BBAAPI
//
//  Created by Tomek Kuźma on 04/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAConnection.h"
@class BBAUserDetails;

@interface BBAMockConnection : BBAConnection
/**
 *  Defaults is `YES`
 */
@property (nonatomic, assign) BOOL shouldCallCompletion;

@property (nonatomic, assign) BOOL wasPerformCompletionCalled;

@property (nonatomic, strong) id objectToReturn;
@property (nonatomic, strong) NSError *errorToReturn;

@property (nonatomic, strong) NSMutableDictionary *passedParameters;
@property (nonatomic, strong) NSMutableDictionary *passedArrayParameters;
@property (nonatomic, strong) NSMutableDictionary *passedHeaders;
@property (nonatomic, strong) BBAUserDetails *passedUserDetails;
@property (nonatomic, assign) BBAHTTPMethod passedHTTPMethod;


@end
