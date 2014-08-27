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

@interface BBAConnection : NSObject

@property (nonatomic, strong) BBARequestFactory *requestFactory;

@property (nonatomic, strong) id<BBAResponseMapping> responseMapper;

@property (nonatomic, weak) id<BBAAuthenticator> authenticator;

@property (nonatomic, strong, readonly) NSURL *baseURL;

@property (nonatomic, assign) BBAContentType contentType;

@property (nonatomic, assign) BOOL requiresAuthentication;
/**
 *  Create a new connection with the given URL
 *
 *  @param URL URL of the server resource, must not be `nil`
 *
 *  @return a `BBAURLConnection` pointing to the URL specified
 */
- (id) initWithBaseURL:(NSURL *)URL;

- (id) initWithDomain:(BBAAPIDomain)domain relativeURL:(NSString *)relativeURLString;

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

- (void) perform:(BBAHTTPMethod)method
      completion:(void (^)(id response, NSError *error))completion;

- (void) perform:(BBAHTTPMethod)method
         forUser:(BBAUserDetails *)user
      completion:(void (^)(id response, NSError *error))completion;
@end


