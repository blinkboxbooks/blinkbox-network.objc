//
//  BBAAuthenticationService.m
//  BBANetworking
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAAuthenticationService.h"
#import "BBAAuthenticationServiceConstants.h"
#import "BBAAPIErrors.h"
#import "BBAAuthConnection.h"
#import "BBAUserDetails.h"
#import "BBAClientDetails.h"
#import "BBAAuthData.h"
#import "BBARequestFactory.h"
#import "BBALogger.h"

@interface BBAAuthenticationService ()
@property (nonatomic, strong) id<BBAResponseMapping> authResponseMapper;
@property (nonatomic, strong) id<BBAResponseMapping> tokensResponseMapper;
@property (nonatomic, strong) id<BBAResponseMapping> clientsResponseMapper;
@end

@implementation BBAAuthenticationService

#pragma mark - Init
- (instancetype) init{
    if (self = [super init]) {
        BBANetworkConfiguration *configuration;
        configuration = [BBANetworkConfiguration defaultConfiguration];
        _authResponseMapper = [configuration newResponseMapperForServiceName:kBBAAuthServiceName];
        _tokensResponseMapper = [configuration newResponseMapperForServiceName:kBBAAuthServiceTokensName];
        _clientsResponseMapper = [configuration newResponseMapperForServiceName:kBBAAuthServiceClientsName];

        BBALog(@"AuthenticationService Initialised");
    }
    return self;
}

#pragma mark - Public API
- (void) registerUser:(BBAUserDetails *)user
               client:(BBAClientDetails *)client
           completion:(void (^)(BBAAuthData *, NSError *))completion{

    BBALog(@"registerUser:client:completion:");

    NSParameterAssert(user);
    NSParameterAssert(user.firstName);
    NSParameterAssert(user.lastName);
    NSParameterAssert(user.email);
    NSParameterAssert(user.password);

    NSParameterAssert(client);
    NSParameterAssert(client.name);
    NSParameterAssert(client.brand);
    NSParameterAssert(client.operatingSystem);
    NSParameterAssert(client.model);

    NSParameterAssert(completion);

    //Validate parameters
    if (user.firstName == nil || user.lastName == nil || user.email == nil || user.password == nil
        || user.acceptsTermsAndConditions == NO || client.name == nil || client.brand == nil
        || client.operatingSystem == nil || client.model == nil) {
        completion(nil,  [NSError errorWithDomain:kBBAAuthServiceName
                                             code:BBAAPIWrongUsage
                                         userInfo:nil]);
        return;
    }


    BBAAuthConnection *connection = nil;
    connection = [[BBAAuthConnection alloc] initWithDomain:(BBAAPIDomainAuthentication)
                                               relativeURL:kBBAAuthServiceURLOAUTH2];

    connection.requestFactory = [BBARequestFactory new];
    connection.responseMapper = self.authResponseMapper;
    connection.requiresAuthentication = NO;

    [connection setUsername:user.email password:user.password firstName:user.firstName
                   lastName:user.lastName acceptedTerms:user.acceptsTermsAndConditions
             allowMarketing:user.allowMarketing clientName:client.name clientBrand:client.brand
                   clientOS:client.operatingSystem clientModel:client.model];

    connection.grantType = BBAGrantTypeRegistration;

    [connection perform:(BBAHTTPMethodPOST)
             completion:^(BBAAuthData *data, NSError *error) {
                 completion(data,error);
             }];

}

- (void) registerClient:(BBAClientDetails *)client
                forUser:(BBAUserDetails *)user
             completion:(void (^)(BBAClientDetails *, NSError *))completion{
    BBALog(@"registerClient:client:completion:");

    NSParameterAssert(user);


    NSParameterAssert(client);
    NSParameterAssert(client.name);
    NSParameterAssert(client.brand);
    NSParameterAssert(client.operatingSystem);
    NSParameterAssert(client.model);

    NSParameterAssert(completion);

    BOOL hasNeededClientData = NO;
    hasNeededClientData = (client.name && client.brand && client.operatingSystem && client.model);
    if (!user || !hasNeededClientData) {
        completion(nil,  [NSError errorWithDomain:kBBAAuthServiceName
                                             code:BBAAPIWrongUsage
                                         userInfo:nil]);
        return;
    }

    BBAAuthConnection *connection = nil;
    connection = [[BBAAuthConnection alloc] initWithDomain:(BBAAPIDomainAuthentication)
                                               relativeURL:kBBAAuthServiceURLClients];

    connection.requestFactory = [BBARequestFactory new];
    connection.responseMapper = self.clientsResponseMapper;

    [connection setClientName:client.name];
    [connection setClientBrand:client.brand];
    [connection setClientModel:client.model];
    [connection setClientOS:client.operatingSystem];

    [connection perform:(BBAHTTPMethodPOST)
                forUser:user
             completion:^(BBAClientDetails *data, NSError *error) {
                 completion(data,error);
             }];

}

- (void) loginUser:(BBAUserDetails *)user
            client:(BBAClientDetails *)client
        completion:(void (^)(BBAAuthData *, NSError *))completion{

    BBALog(@"loginUser:client:completion:");

    NSParameterAssert(user.email);
    NSParameterAssert(user.password);
    NSParameterAssert(completion);

    if (user.email == nil || user.password == nil) {
        NSError *error =  [NSError errorWithDomain:kBBAAuthServiceName
                                              code:BBAAPIWrongUsage
                                          userInfo:nil];
        completion(nil,error);
        return;
    }

    BBAAuthConnection *connection = nil;
    connection = [[BBAAuthConnection alloc] initWithDomain:(BBAAPIDomainAuthentication)
                                                          relativeURL:kBBAAuthServiceURLOAUTH2];

    connection.requestFactory = [BBARequestFactory new];
    connection.responseMapper = self.authResponseMapper;
    connection.requiresAuthentication = NO;

    connection.username = user.email;
    connection.password = user.password;

    //Client id and secret are optional parameters
    if (client.identifier != nil && client.secret != nil) {
        connection.clientId = client.identifier;
        connection.clientSecret = client.secret;
    }

    connection.grantType = BBAGrantTypePassword;

    [connection perform:(BBAHTTPMethodPOST)
             completion:^(BBAAuthData *data, NSError *error) {
                 completion(data,error);
             }];
}

- (void) refreshAuthData:(BBAAuthData *)data
              completion:(void (^)(BBAAuthData *, NSError *))completion{

    BBALog(@"refreshAuthData:completion:");

    NSParameterAssert(completion);
    NSParameterAssert(data.refreshToken);

    if (data.refreshToken == nil) {
        NSError *error =  [NSError errorWithDomain:kBBAAuthServiceName
                                              code:BBAAPIWrongUsage
                                          userInfo:nil];
        completion(nil,error);
        return;
    }

    BBAAuthConnection *connection = nil;
    connection = [[BBAAuthConnection alloc] initWithDomain:(BBAAPIDomainAuthentication)
                                               relativeURL:kBBAAuthServiceURLOAUTH2];

    connection.requestFactory = [BBARequestFactory new];
    connection.responseMapper = self.authResponseMapper;
    connection.requiresAuthentication = NO;

    connection.grantType = BBAGrantTypeRefreshToken;
    connection.refreshToken = data.refreshToken;

    //Client id and secret are optional parameters
    if (data.clientId != nil && data.clientSecret != nil) {
        connection.clientId = data.clientId;
        connection.clientSecret = data.clientSecret;
    }


    [connection perform:(BBAHTTPMethodPOST)
             completion:^(BBAAuthData *data, NSError *error) {
                 completion(data,error);
             }];
}

- (void) resetPasswordForUser:(BBAUserDetails *)user
                   completion:(void (^)(BOOL, NSError *))completion{
    BBALog(@"resetPasswordForUser:completion:");

    NSParameterAssert(user.email);
    NSParameterAssert(completion);

    if (user.email == nil) {
        if (completion) {
            completion(NO,  [NSError errorWithDomain:kBBAAuthServiceName
                                                code:BBAAPIWrongUsage
                                            userInfo:nil]);
        }
        return;
    }

    BBAAuthConnection *connection = nil;
    connection = [[BBAAuthConnection alloc] initWithDomain:(BBAAPIDomainAuthentication)
                                               relativeURL:kBBAAuthServiceURLPasswordReset];

    connection.requestFactory = [BBARequestFactory new];
    connection.responseMapper = self.tokensResponseMapper;
    connection.requiresAuthentication = NO;

    [connection setUsername:user.email];

    [connection perform:(BBAHTTPMethodPOST)
             completion:^(NSNumber *success, NSError *error) {
                 completion([success boolValue], error);
             }];
}

- (void) revokeRefreshTokenForUser:(BBAUserDetails *)user
                        completion:(void (^)(BOOL, NSError *))completion{
    BBALog(@"revokeRefreshTokenForUser:completion:");

    NSParameterAssert(user.refreshToken);
    NSParameterAssert(completion);

    if (user.refreshToken == nil) {
        NSError *error =  [NSError errorWithDomain:kBBAAuthServiceName
                                              code:BBAAPIWrongUsage
                                          userInfo:nil];
        completion(NO,error);
        return;
    }

    BBAAuthConnection *connection = nil;
    connection = [[BBAAuthConnection alloc] initWithDomain:(BBAAPIDomainAuthentication)
                                               relativeURL:kBBAAuthServiceURLTokensRevoke];

    connection.requestFactory = [BBARequestFactory new];
    connection.responseMapper = self.tokensResponseMapper;
    connection.requiresAuthentication = NO;

    connection.refreshToken = user.refreshToken;

    [connection perform:(BBAHTTPMethodPOST)
             completion:^(NSNumber *success, NSError *error) {
                 completion([success boolValue], error);
             }];

} 

- (void) getAllClientsForUser:(BBAUserDetails *)user
                   completion:(void (^)(NSArray *, NSError *))completion{
    BBALog(@"getAllClientsForUser:completion:");

    NSParameterAssert(user);
    NSParameterAssert(completion);
    if (user == nil) {
        completion(nil,  [NSError errorWithDomain:kBBAAuthServiceName
                                             code:BBAAPIWrongUsage
                                         userInfo:nil]);
        return;
    }
    BBAAuthConnection *connection = nil;
    connection = [[BBAAuthConnection alloc] initWithDomain:(BBAAPIDomainAuthentication)
                                               relativeURL:kBBAAuthServiceURLClients];

    connection.requestFactory = [BBARequestFactory new];
    connection.responseMapper = self.clientsResponseMapper;

    [connection perform:(BBAHTTPMethodGET)
                forUser:user
             completion:^(NSArray *clients, NSError *error) {
                 completion(clients, error);
             }];
}

- (void) deleteClient:(BBAClientDetails *)client
              forUser:(BBAUserDetails *)user
           completion:(void (^)(BOOL, NSError *))completion{
    BBALog(@"deleteClient:user:completion:");

    NSParameterAssert(client.uri);
    NSParameterAssert(user);
    NSParameterAssert(completion);
    if (client.uri == nil || user == nil) {
        completion(NO, [NSError errorWithDomain:kBBAAuthServiceName
                                           code:BBAAPIWrongUsage
                                       userInfo:nil]);
        return;
    }

    BBAAuthConnection *connection = nil;

    connection = [[BBAAuthConnection alloc] initWithDomain:BBAAPIDomainAuthentication
                                               relativeURL:client.uri];

    connection.requestFactory = [BBARequestFactory new];
    connection.responseMapper = self.clientsResponseMapper;
    [connection perform:(BBAHTTPMethodDELETE)
                forUser:user
             completion:^(NSNumber *result, NSError *error) {
                 completion([result boolValue], error);
             }];
}


@end
