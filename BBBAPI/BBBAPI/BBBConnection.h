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

NS_ENUM(NSInteger, BBBHTTPStatus){
    BBBHTTPSuccess = 200,
    BBBHTTPUnauthorized = 401,
    BBBHTTPForbidden = 403,
    BBBHTTPNotFound = 404,
    BBBHTTPConflict = 409,
    BBBHTTPServerError = 500,
};

NS_ENUM(NSInteger, BBBConnectionError){
    /**
     *  This error is passed up and it means a generic could not connect error
     */
    BBBConnectionErrorCannotConnect = 666,
    BBBConnectionErrorServerError = 667,
    BBBConnectionErrorNotFound = 668,
    BBBConnectionErrorForbidden = 669,
};


extern NSString *const BBBConnectionErrorDomain;

extern NSString *const BBBHTTPVersion11;

@class BBBResponse;
@class BBBRequestFactory;

@interface BBBConnection : NSObject

@property (nonatomic, strong) BBBRequestFactory *requestFactory;

@property (nonatomic, strong) id<BBBResponseMapping> responseMapper;

@property (nonatomic, weak) id<BBBAuthenticator> authenticator;

@property (nonatomic, strong, readonly) NSURL *baseURL;

@property (nonatomic, assign) BBBContentType contentType;

@property (nonatomic, assign) BOOL requiresAuthentication;
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

- (void) perform:(BBBHTTPMethod)method
      completion:(void (^)(id response, NSError *error))completion;

- (void) perform:(BBBHTTPMethod)method
         forUser:(BBBUserDetails *)user
      completion:(void (^)(id response, NSError *error))completion;
@end


