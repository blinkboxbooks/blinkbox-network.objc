    //
//  BBAAuthenticationService.h
//  BBANetworking
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 29/07/2014.
 

#import <Foundation/Foundation.h>

@class BBAUserDetails;
@class BBAClientDetails;
@class BBAAuthData;

@interface BBAAuthenticationService : NSObject

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
- (void) registerUser:(BBAUserDetails *)user
               client:(BBAClientDetails *)client
           completion:(void (^)(BBAAuthData *data, NSError *error))completion;

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
- (void) registerClient:(BBAClientDetails *)client
                forUser:(BBAUserDetails *)user
             completion:(void (^)(BBAClientDetails *data, NSError *error))completion;

/**
 *  Log the user in
 *
 *  @param user       `BBAUserDetails` describing the login parameters to use
 *  User requires the following properties to be set:
 *  - email
 *  - password
 *  @param client     optional `BBAClientDetails` object containing client details
 *  @param completion A block that will be called upon completion of the operation. Required.
 */
- (void) loginUser:(BBAUserDetails *)user
            client:(BBAClientDetails *)client
        completion:(void (^)(BBAAuthData *data, NSError *error))completion;

/**
 *  Refresh the authentication data using a refresh token.
 *
 *  @param data       AuthData to refresh. Required.
 *  data requires the following properties to be set:
 *  - refreshToken
 *  @param completion Completion handler called with refreshed authentication data on success
 *  or an NSError describing the reason for failure. Required.
 */
- (void) refreshAuthData:(BBAAuthData *)data
              completion:(void (^)(BBAAuthData *refeshedData, NSError *error))completion;

/**
 *  Reset the password for this user. An email will be sent to the email address of the user.
 *
 *  @param user       The user for whom we are resetting the password. Required.
 *  User requires the following properties to be set:
 *  - email
 *  @param completion Called on completion of the operation. Required.
 */
- (void) resetPasswordForUser:(BBAUserDetails *)user
                   completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Revoke the refresh token for this user. Should be called when a user actively logs out.
 *
 *  @param user       The user for whom we are revoking a refresh token. Required.
 *  User requires the following properties to be set:
 *  - refreshToken
 *  @param completion Called on completion of the operation. Required.
 */
- (void) revokeRefreshTokenForUser:(BBAUserDetails *)user
                        completion:(void (^)(BOOL succes, NSError *error))completion;

/**
 *  Fetch an array of all registered clients for this user.
 *
 *  @param user       User for whom to fetch client details. Required.
 *  @param completion Called on completion. Required.
 */
- (void) getAllClientsForUser:(BBAUserDetails *)user
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
- (void) deleteClient:(BBAClientDetails *)client
              forUser:(BBAUserDetails *)user
           completion:(void (^)(BOOL succes, NSError *error))completion;

@end
