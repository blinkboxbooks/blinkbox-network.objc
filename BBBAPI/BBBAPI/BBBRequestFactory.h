//
//  BBBRequestFactory.h
//  BBBAPI
//
//  Created by Tomek Kuźma on 31/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBBNetworkingConstants.h"

extern NSString *const BBBRequestFactoryDomain;

typedef NS_ENUM(NSInteger, BBBRequestFactoryError) {
    BBBURLConnectionErrorCodeCouldSerialiseDataToJSON = 580,
};

@class BBBRequest;
@interface BBBRequestFactory : NSObject
- (BBBRequest *) requestWith:(NSURL *)url
                  parameters:(NSDictionary *)parameters
                     headers:(NSDictionary *)headers
                      method:(BBBHTTPMethod)method
                 contentType:(BBBContentType)contentType
                       error:(NSError **)error;
@end
