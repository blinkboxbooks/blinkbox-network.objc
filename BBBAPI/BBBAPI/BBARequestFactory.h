//
//  BBARequestFactory.h
//  BBAAPI
//
//  Created by Tomek Kuźma on 31/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBANetworkingConstants.h"

extern NSString *const BBARequestFactoryDomain;

typedef NS_ENUM(NSInteger, BBARequestFactoryError) {
    BBAURLConnectionErrorCodeCouldSerialiseDataToJSON = 580,
};

@class BBARequest;
@interface BBARequestFactory : NSObject
- (BBARequest *) requestWith:(NSURL *)url
                  parameters:(NSDictionary *)parameters
                     headers:(NSDictionary *)headers
                      method:(BBAHTTPMethod)method
                 contentType:(BBAContentType)contentType
                       error:(NSError **)error;
@end
