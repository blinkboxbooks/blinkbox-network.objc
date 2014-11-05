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
    BBARequestFactoryErrorCouldNotCreateRequest = 581,
    BBARequestFactoryErrorHeadersInvalid = 582,
    BBARequestFactoryErrorParametersInvalid = 583,

};

@class BBARequest;

/**
 *  This class is responsible for constructing `BBARequest` objects
 */
@interface BBARequestFactory : NSObject

/**
 *  Construct a `BBARequest` given a set of input parameters
 *
 *  @param url         `NSURL` to request (required, must not be nil)
 *  @param parameters  `NSDictionary` of request parameters. Values should be `NSString` or\
    `NSArray` objects. `NSArray` objects are constructed as follows for GET requests:\
    key=value1&key=value2 etc (optional, may be nil)
 *  @param headers     `NSDictionary` of header values. Header values must be `NSString` (optional)
 *  @param method      `BBAHTTPMethod` e.g. `BBAHTTPMethodGET`. See `BBAHTTPMethod` for list. (required)
 *  @param contentType `BBAContentType` e.g. `BBAContentTypeJSON`. see `BBAContentType`. (required)
 *  @param error       `NSError` that will be set if there was an error constructing the `BBARequest` (optional, may be nil)
 *
 *  @return `BBARequest` containing specified parameters, or `nil` if an error occurred.
 */
- (BBARequest *) requestWith:(NSURL *)url
                  parameters:(NSDictionary *)parameters
                     headers:(NSDictionary *)headers
                      method:(BBAHTTPMethod)method
                 contentType:(BBAContentType)contentType
                       error:(NSError **)error;
@end
