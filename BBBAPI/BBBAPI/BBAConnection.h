//
//  BBAConnection.h
//  BBANetworking
//
//  Created by Tomek Kuźma on 24/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBANetworkingConstants.h"
#import "BBAAuthenticator.h"
#import "BBAResponseMapping.h"
#import "BBANetworkConfiguration.h"

NS_ENUM(NSInteger, BBAHTTPStatus){
    BBAHTTPSuccess = 200,
    BBAHTTPUnauthorized = 401,
    BBAHTTPForbidden = 403,
    BBAHTTPNotFound = 404,
    BBAHTTPConflict = 409,
    BBAHTTPServerError = 500,
};

extern NSString *const BBAConnectionErrorDomain;

extern NSString *const BBAHTTPVersion11;

@class BBAResponse;
@class BBARequestFactory;

/**
 *  General purpose class to perform asynchornous network requests
 */
@interface BBAConnection : NSObject

/**
 *  Object responible for creating `BBBRequest` object from parameters supplied by the 
 *  `BBAConnection`. Created lazily when performing request
 */
@property (nonatomic, strong) BBARequestFactory *requestFactory;

/**
 *  Object used to map response data from the network to usable form, must not be `nil` by the time
 *  the `perform...` method are called
 */
@property (nonatomic, strong) id<BBAResponseMapping> responseMapper;

/**
 *  Used to authenticate requests, connection grabs it from `BBANetworkConfiguration`.
 *  Requests are authenticated when `requiresAuthentication` is set to `YES`.
 */
@property (nonatomic, weak) id<BBAAuthenticator> authenticator;

/**
 *  Current base URL value for the connection
 */
@property (nonatomic, strong, readonly) NSURL *baseURL;

/**
 *  Content type of the request that will be sent, default value is `BBAContentTypeUnknown`
 */
@property (nonatomic, assign) BBAContentType contentType;

/**
 *  When set to `YES`, prior to sending the requests, `authenticator` is asked to authenticate
 *  a request.
 */
@property (nonatomic, assign) BOOL requiresAuthentication;

/**
 *  Create a new connection with the given URL
 *
 *  @param URL URL of the server resource, must not be `nil`
 *
 *  @return a `BBAConnection` pointing to the URL specified
 */
- (id) initWithBaseURL:(NSURL *)URL;

/**
 *  Create new connection with with base URL taken from `[BBANetworkConfiguration defaultConfiguration]`
 *
 *  @param domain            domain to get base URL for
 *  @param relativeURLString specific endpoint to append to base URL for given `domain`
 *
 *  @return new instance of the `BBAConnection`
 */
- (id) initWithDomain:(BBAAPIDomain)domain relativeURL:(NSString *)relativeURLString;

/**
 *  Add a parameter to this request. Parameters with duplicate keys are overwritten.
 *
 *  @param key   The key of the parameter
 *  @param value The value of the parameter as an `NSString`
 */

- (void) addParameterWithKey:(NSString*)key value:(NSString*)value;

/**
 *  Add a header field to this request. Existing headers with duplicate keys are overwritten.
 *
 *  @param key   The key for this header parameter
 *  @param value The value for this header paramater as an `NSArray`
 */
- (void) addParameterWithKey:(NSString *)key arrayValue:(NSArray *)value;

/**
 *  Add or removed parameter `value` for given `key`. If `value` is not `nil`, it adds it to 
 *  paremeters that will be sent with the request, otherwise removes it from this list.
 *
 *  @param value value to be added to parameter list or `nil`
 *  @param key   key, must be non-`nil` `NSString`
 */
- (void) setParameterValue:(NSString *)value withKey:(NSString *)key;

/**
 *  Add a header field to this request. Existing headers with duplicate keys are overwritten.
 *
 *  @param key   The key for this header parameter
 *  @param value The value for this header paramater as an `NSString`
 */
- (void) addHeaderFieldWithKey:(NSString*)key value:(NSString*)value;

/**
 *  Makes request to `baseURL` with specified parameters
 *
 *  @param method     HTTP method
 *  @param completion called upon finish or when request fails, must not be `nil`.
 */
- (void) perform:(BBAHTTPMethod)method
      completion:(void (^)(id response, NSError *error))completion;

/**
 *  Makes request to `baseURL` with specified parameters for given user
 *
 *  @param method     HTTP method
 *  @param user       options parameter, passed to `authenticator` when `requiresAuthentication` is
 *                    set to `YES`
 *  @param completion called upon finish or when request fails, must not be `nil`.
 */
- (void) perform:(BBAHTTPMethod)method
         forUser:(BBAUserDetails *)user
      completion:(void (^)(id response, NSError *error))completion;
@end


