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

NS_ENUM(NSInteger, BBBAuthenticationError){
    /**
     *  Generic unauthorized error code
     */
    BBBAuthenticationServiceErrorUnauthorized = 560
};

extern NSString *const BBBAuthenticaitonServiceErrorDomain;

@interface BBBAuthenticationService : NSObject

/**
 *  Register a user and client with the server.
 *
 *  @param user       The details of the user to register. Required.
 *  User requires the following properties to be set:
 *  - firstName
 *  - lastName
 *  - email
 *  - password
 *  @param client     The details of the client to register. Required.
 *  Client requires the following properties to be set:
 *  - name
 *  - brand
 *  - operatingSystem
 *  - model
 *  @param completion Completion handler called with authentication data on success
 *  or an NSError describing the reason for failure. Required.
 */
- (void) registerUser:(BBBUserDetails *)user
               client:(BBBClientDetails *)client
           completion:(void (^)(BBBAuthData *data, NSError *error))completion;

/**
 *  Register a client for an existing user.
 *
 *  @param client     The details of the client to register.
 *  Client requires the following properties to be set:
 *  - name
 *  - brand
 *  - operatingSystem
 *  - model
 *  @param user       The details of the user for whom to register the client.
 *  @param completion Completion handler called with authentication data on success
 *  or an NSError describing the reason for failure. Required.
 */
- (void) registerClient:(BBBClientDetails *)client
                forUser:(BBBUserDetails *)user
             completion:(void (^)(BBBClientDetails *data, NSError *error))completion;

/**
 *  Log the user in
 *
 *  @param user       `BBBUserDetails` describing the login parameters to use
 *  User requires the following properties to be set:
 *  - email
 *  - password
 *  @param client     optional `BBBClientDetails` object containing client details
 *  @param completion A block that will be called upon completion of the operation. Required.
 */
- (void) loginUser:(BBBUserDetails *)user
            client:(BBBClientDetails *)client
        completion:(void (^)(BBBAuthData *data, NSError *error))completion;

/**
 *  Refresh the authentication data using a refresh token.
 *
 *  @param data       AuthData to refresh. Required.
 *  data requires the following properties to be set:
 *  - refreshToken
 *  @param completion Completion handler called with refreshed authentication data on success
 *  or an NSError describing the reason for failure. Required.
 */
- (void) refreshAuthData:(BBBAuthData *)data
              completion:(void (^)(BBBAuthData *refeshedData, NSError *error))completion;

/**
 *  Reset the password for this user. An email will be sent to the email address of the user.
 *
 *  @param user       The user for whom we are resetting the password. Required.
 *  User requires the following properties to be set:
 *  - email
 *  @param completion Called on completion of the operation. Required.
 */
- (void) resetPasswordForUser:(BBBUserDetails *)user
                   completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Revoke the refresh token for this user. Should be called when a user actively logs out.
 *
 *  @param user       The user for whom we are revoking a refresh token. Required.
 *  User requires the following properties to be set:
 *  - refreshToken
 *  @param completion Called on completion of the operation. Required.
 */
- (void) revokeRefreshTokenForUser:(BBBUserDetails *)user
                        completion:(void (^)(BOOL succes, NSError *error))completion;

/**
 *  Fetch an array of all registered clients for this user.
 *
 *  @param user       User for whom to fetch client details. Required.
 *  @param completion Called on completion. Required.
 */
- (void) getAllClientsForUser:(BBBUserDetails *)user
                   completion:(void (^)(NSArray *clients, NSError *error))completion;

/**
 *  Delete (unregister) a client for a user
 *
 *  @param client     The client to delete (unregister)
 *  Client requires the following properties to be set:
 *  - uri
 *  @param user       The user that owns the client to be deleted.
 *  @param completion Called on completion. Required.
 */
- (void) deleteClient:(BBBClientDetails *)client
              forUser:(BBBUserDetails *)user
           completion:(void (^)(BOOL succes, NSError *error))completion;

@end
