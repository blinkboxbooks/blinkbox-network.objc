//
//  BBBAuthenticationService.h
//  BBBNetworking
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBBUserDetails;
@class BBBClientDetails;
@class BBBAuthData;

extern NSString *const kAuthServiceName;

@interface BBBAuthenticationService : NSObject

- (void) registerUser:(BBBUserDetails *)user
               client:(BBBClientDetails *)client
           completion:(void (^)(BBBAuthData *data, NSError *error))completion;

- (void) registerClient:(BBBClientDetails *)client
                forUser:(BBBUserDetails *)user
             completion:(void (^)(BBBAuthData *data, NSError *error))completion;

/**
 *  <#Description#>
 *
 *  @param user       <#user description#>
 *  @param client     optional parameter
 *  @param completion <#completion description#>
 */
- (void) login:(BBBUserDetails *)user
        client:(BBBClientDetails *)client
    completion:(void (^)(BBBAuthData *data, NSError *error))completion;

- (void) refreshAuthData:(BBBAuthData *)data
              completion:(void (^)(BBBAuthData *refeshedData, NSError *error))completion;

- (void) resetPassword:(BBBUserDetails *)user
            completion:(void (^)(BOOL success, NSError *error))completion;

- (void) revokeRefreshTokenFor:(BBBUserDetails *)user
                    completion:(void (^)(BOOL succes, NSError *error))completion;

@end
