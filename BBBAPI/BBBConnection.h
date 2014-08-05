//
//  BBBConnection.h
//  BBBNetworking
//
//  Created by Tomek Kuźma on 24/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBBNetworkingConstants.h"
#import "BBBAuthenticator.h"
#import "BBBResponseMapping.h"
#import "BBBNetworkConfiguration.h"

typedef NS_ENUM(NSInteger, BBBURLConnectionErrorCode){
    /**
     *  This error is passed up and it means a generic could not connect error
     */
    BBBURLConnectionErrorCodeCannotConnect = 666,
    /**
     *  Error generated when data cannot be serialised to JSON when sending
     *  a request
     */
};


extern NSString *const kBBBURLConnectionErrorDomain;

@class BBBResponse;
@class BBBRequestFactory;

@interface BBBConnection : NSObject

@property (nonatomic, strong) BBBRequestFactory *requestFactory;

@property (nonatomic, strong) id<BBBResponseMapping> responseMapper;

@property (nonatomic, weak) id<BBBAuthenticator> authenticator;

@property (nonatomic, strong, readonly) NSURL *baseURL;

@property (nonatomic, assign) BBBContentType contentType;

/**
 *  Create a new connection with the given URL
 *
 *  @param URL URL of the server resource, must not be `nil`
 *
 *  @return a `BBBURLConnection` pointing to the URL specified
 */
- (id) initWithBaseURL:(NSURL *)URL;

- (id) initWithDomain:(BBBAPIDomain)domain relativeURL:(NSString *)relativeURLString;

/**
 *  Add a parameter to this request. Parameters with duplicate keys are overwritten.
 *
 *  @param key   The key of the parameter
 *  @param value The value of the parameter as an `NSString`
 */

#pragma mark - Parameters
- (void) addParameterWithKey:(NSString*)key value:(NSString*)value;

/**
 *  Add a header field to this request. Existing headers with duplicate keys are overwritten.
 *
 *  @param key   The key for this header parameter
 *  @param value The value for this header paramater as an `NSArray`
 */
- (void) addParameterWithKey:(NSString *)key arrayValue:(NSArray *)value;

- (void) removeParameterWithKey:(NSString *)key;


/**
 *  Add a header field to this request. Existing headers with duplicate keys are overwritten.
 *
 *  @param key   The key for this header parameter
 *  @param value The value for this header paramater as an `NSString`
 */
- (void) addHeaderFieldWithKey:(NSString*)key value:(NSString*)value;

- (void) removeHeaderFieldWithKey:(NSString*)key;

/**
 *  Set the connection method.
 *
 *  @param httpMethod a `BBBHTTPMethod` describing the required http method.
 */
- (void) setHTTPMethod:(BBBHTTPMethod)httpMethod;

- (void) perform:(BBBHTTPMethod)method
      completion:(void (^)(id response, NSError *error))completion;

@end


