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

@interface BBBAuthenticationService : NSObject

- (void) registerUser:(BBBUserDetails *)user
               client:(BBBClientDetails *)client
           completion:(void (^)(BBBAuthData *data, NSError *error))completion;

- (void) registerClient:(BBBClientDetails *)client
                forUser:(BBBUserDetails *)user
             completion:(void (^)(BBBAuthData *data, NSError *error))completion;

/**
 *  Log the user in
 *
 *  @param user       `BBBUserDetails` describing the login parameters to use
 *  @param client     optional `BBBClientDetails` object containing client details
 *  @param completion A block that will be called upon completion of the operation
 */
- (void) loginUser:(BBBUserDetails *)user
            client:(BBBClientDetails *)client
        completion:(void (^)(BBBAuthData *data, NSError *error))completion;

- (void) refreshAuthData:(BBBAuthData *)data
              completion:(void (^)(BBBAuthData *refeshedData, NSError *error))completion;

- (void) resetPasswordForUser:(BBBUserDetails *)user
                   completion:(void (^)(BOOL success, NSError *error))completion;

- (void) revokeRefreshTokenForUser:(BBBUserDetails *)user
                        completion:(void (^)(BOOL succes, NSError *error))completion;

- (void) getAllClientsForUser:(BBBUserDetails *)user
                   completion:(void (^)(NSArray *clients, NSError *error))completion;

- (void) deleteClient:(BBBClientDetails *)client
              forUser:(BBBUserDetails *)user
           completion:(void (^)(BOOL succes, NSError *error))completion;

@end
