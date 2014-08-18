//
//  BBBAuthenticationService.m
//  BBBNetworking
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBAuthenticationService.h"
#import "BBBAuthenticationServiceConstants.h"
#import "BBBAPIErrors.h"
#import "BBBAuthConnection.h"
#import "BBBUserDetails.h"
#import "BBBClientDetails.h"
#import "BBBAuthData.h"
#import "BBBRequestFactory.h"

@interface BBBAuthenticationService ()
@property (nonatomic, strong) id<BBBResponseMapping> authResponseMapper;
@property (nonatomic, strong) id<BBBResponseMapping> tokensResponseMapper;
@property (nonatomic, strong) id<BBBResponseMapping> clientsResponseMapper;
@end

@implementation BBBAuthenticationService

#pragma mark - Init
- (instancetype) init{
    if (self = [super init]) {
        self.authResponseMapper = [BBBNetworkConfiguration responseMapperForServiceName:kBBBAuthServiceName];
        self.tokensResponseMapper = [BBBNetworkConfiguration responseMapperForServiceName:kBBBAuthServiceTokensName];
        self.clientsResponseMapper = [BBBNetworkConfiguration responseMapperForServiceName:kBBBAuthServiceClientsName];
    }
    return self;
}

#pragma mark - Public API
- (void) registerUser:(BBBUserDetails *)user
               client:(BBBClientDetails *)client
           completion:(void (^)(BBBAuthData *, NSError *))completion{


    //Validate parameters
    if (user.firstName == nil || user.lastName == nil || user.email == nil || user.password == nil
        || user.acceptsTermsAndConditions == NO || client.name == nil || client.brand == nil
        || client.operatingSystem == nil || client.model == nil) {
        completion(nil,  [NSError errorWithDomain:kBBBAuthServiceName
                                             code:BBBAPIErrorInvalidParameters
                                         userInfo:nil]);
        return;
    }


    BBBAuthConnection *connection = nil;
    connection = [[BBBAuthConnection alloc] initWithDomain:(BBBAPIDomainAuthentication)
                                               relativeURL:kBBBAuthServiceURLOAUTH2];

    connection.requestFactory = [BBBRequestFactory new];
    connection.responseMapper = self.authResponseMapper;
    connection.requiresAuthentication = NO;

    [connection setUsername:user.email password:user.password firstName:user.firstName
                   lastName:user.lastName acceptedTerms:user.acceptsTermsAndConditions
             allowMarketing:user.allowMarketing clientName:client.name clientBrand:client.brand
                   clientOS:client.operatingSystem clientModel:client.model];

    connection.grantType = BBBGrantTypeRegistration;

    [connection perform:(BBBHTTPMethodPOST)
             completion:^(BBBAuthData *data, NSError *error) {
                 completion(data,error);
             }];

}

- (void) registerClient:(BBBClientDetails *)client
                forUser:(BBBUserDetails *)user
             completion:(void (^)(BBBClientDetails *, NSError *))completion{

    if (!client.name || !client.brand || !client.operatingSystem || !client.model) {
        completion(nil,  [NSError errorWithDomain:kBBBAuthServiceName
                                             code:BBBAPIErrorInvalidParameters
                                         userInfo:nil]);
        return;
    }

    BBBAuthConnection *connection = nil;
    connection = [[BBBAuthConnection alloc] initWithDomain:(BBBAPIDomainAuthentication)
                                               relativeURL:kBBBAuthServiceURLClients];

    connection.requestFactory = [BBBRequestFactory new];
    connection.responseMapper = self.clientsResponseMapper;

    [connection setClientName:client.name];
    [connection setClientBrand:client.brand];
    [connection setClientModel:client.model];
    [connection setClientOS:client.operatingSystem];

    [connection perform:(BBBHTTPMethodPOST)
                forUser:user
             completion:^(BBBClientDetails *data, NSError *error) {
                 completion(data,error);
             }];

}

- (void) loginUser:(BBBUserDetails *)user
            client:(BBBClientDetails *)client
        completion:(void (^)(BBBAuthData *, NSError *))completion{
    if (user.email == nil || user.password == nil) {
        NSError *error =  [NSError errorWithDomain:kBBBAuthServiceName
                                              code:BBBAPIErrorInvalidParameters
                                          userInfo:nil];
        completion(nil,error);
        return;
    }

    BBBAuthConnection *connection = nil;
    connection = [[BBBAuthConnection alloc] initWithDomain:(BBBAPIDomainAuthentication)
                                                          relativeURL:kBBBAuthServiceURLOAUTH2];

    connection.requestFactory = [BBBRequestFactory new];
    connection.responseMapper = self.authResponseMapper;
    connection.requiresAuthentication = NO;

    connection.username = user.email;
    connection.password = user.password;

    //Client id and secret are optional parameters
    if (client.identifier != nil && client.secret != nil) {
        connection.clientId = client.identifier;
        connection.clientSecret = client.secret;
    }

    connection.grantType = BBBGrantTypePassword;

    [connection perform:(BBBHTTPMethodPOST)
             completion:^(BBBAuthData *data, NSError *error) {
                 completion(data,error);
             }];
}

- (void) refreshAuthData:(BBBAuthData *)data
              completion:(void (^)(BBBAuthData *, NSError *))completion{

    if (data.refreshToken == nil) {
        NSError *error =  [NSError errorWithDomain:kBBBAuthServiceName
                                              code:BBBAPIErrorInvalidParameters
                                          userInfo:nil];
        completion(nil,error);
        return;
    }

    BBBAuthConnection *connection = nil;
    connection = [[BBBAuthConnection alloc] initWithDomain:(BBBAPIDomainAuthentication)
                                               relativeURL:kBBBAuthServiceURLOAUTH2];

    connection.requestFactory = [BBBRequestFactory new];
    connection.responseMapper = self.authResponseMapper;
    connection.requiresAuthentication = NO;

    connection.grantType = BBBGrantTypeRefreshToken;
    connection.refreshToken = data.refreshToken;

    //Client id and secret are optional parameters
    if (data.clientId != nil && data.clientSecret != nil) {
        connection.clientId = data.clientId;
        connection.clientSecret = data.clientSecret;
    }


    [connection perform:(BBBHTTPMethodPOST)
             completion:^(BBBAuthData *data, NSError *error) {
                 completion(data,error);
             }];
}

- (void) resetPasswordForUser:(BBBUserDetails *)user
                   completion:(void (^)(BOOL, NSError *))completion{

    if (user.email == nil) {
        if (completion) {
            completion(NO,  [NSError errorWithDomain:kBBBAuthServiceName
                                                code:BBBAPIErrorInvalidParameters
                                            userInfo:nil]);
        }
        return;
    }

    BBBAuthConnection *connection = nil;
    connection = [[BBBAuthConnection alloc] initWithDomain:(BBBAPIDomainAuthentication)
                                               relativeURL:kBBBAuthServiceURLPasswordReset];

    connection.requestFactory = [BBBRequestFactory new];
    connection.responseMapper = self.tokensResponseMapper;
    connection.requiresAuthentication = NO;

    [connection setUsername:user.email];

    [connection perform:(BBBHTTPMethodPOST)
             completion:^(NSNumber *success, NSError *error) {
                 completion([success boolValue], error);
             }];
}

- (void) revokeRefreshTokenForUser:(BBBUserDetails *)user
                        completion:(void (^)(BOOL, NSError *))completion{
    if (user.refreshToken == nil) {
        NSError *error =  [NSError errorWithDomain:kBBBAuthServiceName
                                              code:BBBAPIErrorInvalidParameters
                                          userInfo:nil];
        completion(NO,error);
        return;
    }

    BBBAuthConnection *connection = nil;
    connection = [[BBBAuthConnection alloc] initWithDomain:(BBBAPIDomainAuthentication)
                                               relativeURL:kBBBAuthServiceURLTokensRevoke];

    connection.requestFactory = [BBBRequestFactory new];
    connection.responseMapper = self.tokensResponseMapper;
    connection.requiresAuthentication = NO;

    connection.refreshToken = user.refreshToken;

    [connection perform:(BBBHTTPMethodPOST)
             completion:^(NSNumber *success, NSError *error) {
                 completion([success boolValue], error);
             }];

} 

- (void) getAllClientsForUser:(BBBUserDetails *)user
                   completion:(void (^)(NSArray *, NSError *))completion{


    BBBAuthConnection *connection = nil;
    connection = [[BBBAuthConnection alloc] initWithDomain:(BBBAPIDomainAuthentication)
                                               relativeURL:kBBBAuthServiceURLClients];

    connection.requestFactory = [BBBRequestFactory new];
    connection.responseMapper = self.clientsResponseMapper;

    [connection perform:(BBBHTTPMethodGET)
                forUser:user
             completion:^(NSArray *clients, NSError *error) {
                 completion(clients, error);
             }];
}

- (void) deleteClient:(BBBClientDetails *)client
              forUser:(BBBUserDetails *)user
           completion:(void (^)(BOOL, NSError *))completion{


    if (client.uri == nil) {
        completion(NO, [NSError errorWithDomain:kBBBAuthServiceName
                                           code:BBBAPIErrorInvalidParameters
                                       userInfo:nil]);
        return;
    }

    BBBAuthConnection *connection = nil;

    connection = [[BBBAuthConnection alloc] initWithDomain:BBBAPIDomainAuthentication
                                               relativeURL:client.uri];

    connection.requestFactory = [BBBRequestFactory new];
    connection.responseMapper = self.clientsResponseMapper;
    [connection perform:(BBBHTTPMethodDELETE)
                forUser:user
             completion:^(NSNumber *result, NSError *error) {
                 completion([result boolValue], error);
             }];
}


@end
