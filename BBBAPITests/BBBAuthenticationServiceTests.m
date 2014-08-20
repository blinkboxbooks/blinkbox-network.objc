//
//  BBBAuthenticationServiceTests.m
//  BBBAPI
//
//  Created by Owen Worley on 04/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBAuthenticationService.h"
#import "BBBUserDetails.h"
#import "BBBClientDetails.h"
#import "BBBAuthData.h"
#import "BBBAuthenticationServiceConstants.h"
#import "BBBAPIErrors.h"
#import "BBBNetworkConfiguration.h"
#import "BBBAuthenticator.h"

#define BBBAssertAuthResponseErrorCode(authData,error,errorCode)\
XCTAssertNil(authData);\
XCTAssertEqualObjects(error.domain, kBBBAuthServiceName);\
XCTAssertEqual(error.code, errorCode);

@interface BBBAuthenticationServiceTests : XCTestCase

@end

@implementation BBBAuthenticationServiceTests

BBBAuthenticationService *service;

- (void) setUp{
    [super setUp];
    service = [BBBAuthenticationService new];


}
- (void) tearDown{
    [self resetDefaultAuthenticatorUserAndClient];
    service = nil;
    [super tearDown];
}

#pragma mark - Tests against live (prod) API
- (void) testRegisterUserAndClientWithNilClient{
    BBB_DISABLE_ASSERTIONS();
    BBBUserDetails *user = [self validRegistrationUser];
    BBBClientDetails *client = nil;
    BBB_PREPARE_SEMAPHORE();
    [service registerUser:user client:client completion:^(BBBAuthData *data, NSError *error) {
        BBBAssertAuthResponseErrorCode(data, error, BBBAPIErrorInvalidParameters);
        BBB_SIGNAL_SEMAPHORE();
    }];
    BBB_WAIT_FOR_SEMAPHORE();
    BBB_ENABLE_ASSERTIONS();
}

- (void) testRegisterUserAndClientThrowsWithNilClient{
    BBBUserDetails *user = [self validRegistrationUser];
    BBBClientDetails *client = nil;
    XCTAssertThrows([service registerUser:user client:client completion:^(BBBAuthData *data, NSError *error) {
    }]);
}

- (void) testRegisterUserAndClientWithNilUser{
    BBB_DISABLE_ASSERTIONS();
    BBBUserDetails *user = nil;
    BBBClientDetails *client = [self validRegistrationClient];
    BBB_PREPARE_SEMAPHORE();
    [service registerUser:user client:client completion:^(BBBAuthData *data, NSError *error) {
        BBBAssertAuthResponseErrorCode(data, error, BBBAPIErrorInvalidParameters);
        BBB_SIGNAL_SEMAPHORE();
    }];
    BBB_WAIT_FOR_SEMAPHORE();
    BBB_ENABLE_ASSERTIONS();
}

- (void) testRegisterUserAndClientThrowsWithNilUser{
    BBBUserDetails *user = nil;
    BBBClientDetails *client = [self validRegistrationClient];
    XCTAssertThrows([service registerUser:user client:client completion:^(BBBAuthData *data, NSError *error) {
    }]);
}

- (void) testRegisterUserAndClientThrowsWithNilCompletion{
    BBBUserDetails *user = [self validRegistrationUser];
    BBBClientDetails *client = [self validRegistrationClient];
    XCTAssertThrows([service registerUser:user client:client completion:nil]);
}

#if 0
//This creates an account on prod.
- (void) testRegisterUserAndClient{
    BBBUserDetails *user = [self validRegistrationUser];
    BBBClientDetails *client = [self validRegistrationClient];
    BBB_PREPARE_SEMAPHORE();
    [service registerUser:user client:client completion:^(BBBAuthData *data, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(data);
        BBB_SIGNAL_SEMAPHORE();
    }];
    BBB_WAIT_FOR_SEMAPHORE();
}
#endif

- (void) testRegisterClientWithNilClient{
    BBB_DISABLE_ASSERTIONS();
    BBBUserDetails *user = [self validUserDetails];
    BBBClientDetails *client = nil;
    BBB_PREPARE_SEMAPHORE();
    [service registerClient:client forUser:user completion:^(BBBClientDetails *data, NSError *error) {
        BBBAssertAuthResponseErrorCode(data, error, BBBAPIErrorInvalidParameters);
        BBB_SIGNAL_SEMAPHORE();
    }];
    BBB_WAIT_FOR_SEMAPHORE();
    BBB_ENABLE_ASSERTIONS();
}

- (void) testRegisterClientWithNilUser{
    BBB_DISABLE_ASSERTIONS();
    BBBUserDetails *user = nil;
    BBBClientDetails *client = [self validRegistrationClient];
    BBB_PREPARE_SEMAPHORE();
    [service registerClient:client forUser:user completion:^(BBBClientDetails *data, NSError *error) {
        BBBAssertAuthResponseErrorCode(data, error, BBBAPIErrorInvalidParameters);
        BBB_SIGNAL_SEMAPHORE();
    }];
    BBB_WAIT_FOR_SEMAPHORE();
    BBB_ENABLE_ASSERTIONS();
}

- (void) testRegisterClientThrowsWithNilClient{
    BBBUserDetails *user = [self validUserDetails];
    BBBClientDetails *client = nil;
    XCTAssertThrows([service registerClient:client forUser:user completion:^(BBBClientDetails *data, NSError *error) {
    }]);
}

- (void) testRegisterClientThrowsWithNilUser{
    BBBUserDetails *user = nil;
    BBBClientDetails *client = [self validRegistrationClient];
    XCTAssertThrows([service registerClient:client forUser:user completion:^(BBBClientDetails *data, NSError *error) {
    }]);
}

- (void) testRegisterClientThrowsWithNilCompletion{
    BBBUserDetails *user = [self validUserDetails];
    BBBClientDetails *client = [self validRegistrationClient];
    XCTAssertThrows([service registerClient:client forUser:user completion:nil]);
}

- (void) testRegisterClientAndDeleteClient{
    BBBUserDetails *user = [self validUserDetails];
    BBBClientDetails *client = [BBBClientDetails new];
    client.name = @"Unit Test";
    client.brand = @"Apple";
    client.operatingSystem = @"iOS8";
    client.model = @"iPhone Simulator";

    __block BBBClientDetails *addedClient = [BBBClientDetails new];

    BBB_PREPARE_SEMAPHORE();
    [service registerClient:client
                    forUser:user
                 completion:^(BBBClientDetails *data, NSError *error) {
                     XCTAssertNotNil(data);
                     XCTAssertNotNil(data.uri);
                     XCTAssertNil(error);
                     addedClient.uri = data.uri;
                     BBB_SIGNAL_SEMAPHORE();
                 }];
    BBB_WAIT_FOR_SEMAPHORE();

    BBB_RESET_SEMAPHORE();
    [service deleteClient:addedClient
                  forUser:user
               completion:^(BOOL succes, NSError *error) {
                   XCTAssertTrue(succes);
                   XCTAssertNil(error);
                   BBB_SIGNAL_SEMAPHORE();
               }];
    BBB_WAIT_FOR_SEMAPHORE();
}

- (void) testValidLoginWithUser{
    BBB_PREPARE_SEMAPHORE();
    BBBUserDetails *user = [self validUserDetails];

    [service loginUser:user
                client:nil
            completion:^(BBBAuthData *data, NSError *error) {
                XCTAssertNotNil(data);
                XCTAssertNil(error);
                BBB_SIGNAL_SEMAPHORE();
            }];

    BBB_WAIT_FOR_SEMAPHORE();
}

- (void) testLoginWithNilUserAndClient{
    BBB_DISABLE_ASSERTIONS();
    BBB_PREPARE_SEMAPHORE();
    [service loginUser:nil
                client:nil
            completion:^(BBBAuthData *data, NSError *error) {
                BBBAssertAuthResponseErrorCode(data, error, BBBAPIErrorInvalidParameters);
                BBB_SIGNAL_SEMAPHORE();
            }];

    BBB_WAIT_FOR_SEMAPHORE();
    BBB_ENABLE_ASSERTIONS();
}

- (void) testLoginThrowsWithNilUser{
    BBBUserDetails *user = nil;
    XCTAssertThrows([service loginUser:user client:nil completion:^(BBBAuthData *data, NSError *error) {
    }]);

}

- (void) testLoginThrowsWithNilCompletion{
    BBBUserDetails *user = [self validUserDetails];
    XCTAssertThrows([service registerClient:nil forUser:user completion:nil]);
}

- (void) testLoginWithUnregisteredUser{
    BBB_PREPARE_SEMAPHORE();
    BBBUserDetails *user = [self nonexistantUserDetails];
    [service loginUser:user
                client:nil
            completion:^(BBBAuthData *data, NSError *error) {
                BBBAssertAuthResponseErrorCode(data, error, BBBAuthServiceErrorCodeInvalidGrant);
                BBB_SIGNAL_SEMAPHORE();
            }];

    BBB_WAIT_FOR_SEMAPHORE();
}

- (void) testLoginWithIncorrectPassword{
    BBB_PREPARE_SEMAPHORE();
    BBBUserDetails *user = [self validUserDetails];
    user.password = @"not_the_correct_password";
    [service loginUser:user
                client:nil
            completion:^(BBBAuthData *data, NSError *error) {
                BBBAssertAuthResponseErrorCode(data, error, BBBAuthServiceErrorCodeInvalidGrant);
                BBB_SIGNAL_SEMAPHORE();
            }];

    BBB_WAIT_FOR_SEMAPHORE();
}

- (void) testValidLoginWithUserAndClient{
    BBB_PREPARE_SEMAPHORE();
    BBBUserDetails *user = nil;
    BBBClientDetails *client = nil;
    [self prepareValidUserDetails:&user withMatchingClientDetails:&client];

    [service loginUser:user
                client:client
            completion:^(BBBAuthData *data, NSError *error) {
                XCTAssertNotNil(data);
                XCTAssertNil(error);
                BBB_SIGNAL_SEMAPHORE();
            }];

    BBB_WAIT_FOR_SEMAPHORE();
}

- (void) testLoginWithUserAndInvalidClient{
    BBB_PREPARE_SEMAPHORE();
    BBBUserDetails *user = [self validUserDetails];
    BBBClientDetails *client = [self invalidClientDetails];

    [service loginUser:user
                client:client
            completion:^(BBBAuthData *data, NSError *error) {
                BBBAssertAuthResponseErrorCode(data, error, BBBAuthServiceErrorCodeInvalidClient);
                BBB_SIGNAL_SEMAPHORE();
            }];

    BBB_WAIT_FOR_SEMAPHORE();
}

- (void) testRefreshAuthDataWithNilAuthData{
    BBBAuthData *validAuthData = nil;
    BBB_DISABLE_ASSERTIONS();
    BBB_PREPARE_SEMAPHORE();
    [service refreshAuthData:validAuthData completion:^(BBBAuthData *refreshedData, NSError *error) {
        BBBAssertAuthResponseErrorCode(refreshedData, error, BBBAPIErrorInvalidParameters);
        BBB_SIGNAL_SEMAPHORE();
    }];

    BBB_WAIT_FOR_SEMAPHORE();
    BBB_ENABLE_ASSERTIONS();
}

- (void) testRefreshAuthDataThrowsWithNilAuthData{
    XCTAssertThrows([service refreshAuthData:nil completion:^(BBBAuthData *refeshedData, NSError *error) {
    }]);
}

- (void) testRefreshAuthDataThrowsWithNilAuthCompletion{
    BBBAuthData *data = [self validUserAuthDataForRefreshing];
    XCTAssertThrows([service refreshAuthData:data completion:nil]);
}

- (void) testRefreshAuthDataWithInvalidAuthData{
    BBBAuthData *validAuthData = [self invalidAuthDataForRefresh];

    BBB_PREPARE_SEMAPHORE();
    [service refreshAuthData:validAuthData completion:^(BBBAuthData *refreshedData, NSError *error) {
        BBBAssertAuthResponseErrorCode(refreshedData, error, BBBAuthServiceErrorCodeInvalidGrant);
        BBB_SIGNAL_SEMAPHORE();
    }];

    BBB_WAIT_FOR_SEMAPHORE();
}

- (void) testRefreshAuthDataWithValidRefreshToken{
    BBBAuthData *validAuthData = [self validUserAuthDataForRefreshing];
    XCTAssertNotNil(validAuthData, @"Cannot test refresh with invalid authData");

    BBB_PREPARE_SEMAPHORE();
    [service refreshAuthData:validAuthData completion:^(BBBAuthData *refeshedData, NSError *error) {

        XCTAssertNil(error);
        XCTAssertNotNil(refeshedData);
        BBB_SIGNAL_SEMAPHORE();
    }];

    BBB_WAIT_FOR_SEMAPHORE();
}

- (void) testRefreshAuthDataWithValidRefreshTokenButIncorrectClientInformation{
    BBBAuthData *validAuthData = [self validUserAuthDataForRefreshing];
    validAuthData.clientId = @"asdasd";
    validAuthData.clientSecret = @"asdasdsadasf";
    XCTAssertNotNil(validAuthData, @"Cannot test refresh with invalid authData");

    BBB_PREPARE_SEMAPHORE();
    [service refreshAuthData:validAuthData completion:^(BBBAuthData *refreshedData, NSError *error) {

        BBBAssertAuthResponseErrorCode(refreshedData, error, BBBAuthServiceErrorCodeInvalidClient);
        BBB_SIGNAL_SEMAPHORE();
    }];

    BBB_WAIT_FOR_SEMAPHORE();
}

- (void) testResetPassword{
    BBB_PREPARE_SEMAPHORE();

    BBBUserDetails *details = [BBBUserDetails new];
    details.email = @"randomtestaccount@blinkbox.com";

    [service resetPasswordForUser:details completion:^(BOOL success, NSError *error) {
        XCTAssertTrue(success);
        XCTAssertNil(error);
        BBB_SIGNAL_SEMAPHORE();
    }];

    BBB_WAIT_FOR_SEMAPHORE();
}

- (void) testResetPasswordForNilUser{
    BBB_DISABLE_ASSERTIONS();
    BBB_PREPARE_SEMAPHORE();
    [service resetPasswordForUser:nil completion:^(BOOL success, NSError *error) {
        XCTAssertFalse(success);
        XCTAssertEqualObjects(error.domain, kBBBAuthServiceName);
        XCTAssertEqual(error.code, BBBAPIErrorInvalidParameters);

        BBB_SIGNAL_SEMAPHORE();
    }];
    BBB_WAIT_FOR_SEMAPHORE();
    BBB_ENABLE_ASSERTIONS();

}

- (void) testResetPasswordThrowsForNilUser{
    XCTAssertThrows([service resetPasswordForUser:nil completion:^(BOOL success, NSError *error) {
    }]);
}

- (void) testResetPasswordThrowsForNilCompletion{
    BBBUserDetails *user = [self validUserDetails];
    XCTAssertThrows([service resetPasswordForUser:user completion:nil]);
}

- (void) testRevokeValidRefreshToken{
    BBBAuthData *validAuthData = [self validUserAuthDataForRefreshing];
    XCTAssertNotNil(validAuthData, @"Cannot test revoke with invalid authData");
    BBBUserDetails *revokeUserDetails = [BBBUserDetails new];
    revokeUserDetails.refreshToken = validAuthData.refreshToken;

    BBB_PREPARE_SEMAPHORE();
    [service revokeRefreshTokenForUser:revokeUserDetails
                            completion:^(BOOL success, NSError *error) {

                                XCTAssertNil(error);
                                XCTAssertTrue(success);
                                BBB_SIGNAL_SEMAPHORE();
                            }];

    BBB_WAIT_FOR_SEMAPHORE();
}

- (void) testRevokeInvalidRefreshToken{
    BBBUserDetails *revokeUserDetails = [BBBUserDetails new];
    revokeUserDetails.refreshToken = @"sdfsdfsdfsdf32g";

    BBB_PREPARE_SEMAPHORE();
    [service revokeRefreshTokenForUser:revokeUserDetails
                            completion:^(BOOL success, NSError *error) {

                                XCTAssertEqualObjects(error.domain, kBBBAuthServiceName);
                                XCTAssertEqual(error.code, BBBAuthServiceErrorCodeInvalidGrant);
                                XCTAssertFalse(success);
                                BBB_SIGNAL_SEMAPHORE();
                            }];

    BBB_WAIT_FOR_SEMAPHORE();
}

- (void) testRevokeRefreshTokenWithNilUser{
    BBB_DISABLE_ASSERTIONS();
    BBB_PREPARE_SEMAPHORE();

    [service revokeRefreshTokenForUser:nil completion:^(BOOL succes, NSError *error) {
        XCTAssertFalse(succes);
        XCTAssertEqualObjects(error.domain, kBBBAuthServiceName);
        XCTAssertEqual(error.code, BBBAPIErrorInvalidParameters);
        BBB_SIGNAL_SEMAPHORE();
    }];

    BBB_WAIT_FOR_SEMAPHORE();
    BBB_ENABLE_ASSERTIONS();
}

- (void) testRevokeRefreshTokenThrowsWithNilUser{
    XCTAssertThrows([service revokeRefreshTokenForUser:nil completion:^(BOOL succes, NSError *error) {
    }]);
}

- (void) testRevokeRefreshTokenThrowsWithNilCompletion{
    BBBUserDetails *user = [self validUserDetails];
    XCTAssertThrows([service revokeRefreshTokenForUser:user completion:nil]);
}

- (void) testGetAllClients{
    BBB_PREPARE_SEMAPHORE();

    BBBUserDetails *user;
    BBBClientDetails *client;
    [self prepareDefaultAuthenticatorWithValidUser:&user
                                         andClient:&client];

    [service getAllClientsForUser:user completion:^(NSArray *clients, NSError *error) {
        XCTAssertTrue([clients isKindOfClass:[NSArray class]]);
        XCTAssertNil(error);
        BBB_SIGNAL_SEMAPHORE();

    }];
    BBB_WAIT_FOR_SEMAPHORE();

}

- (void) testGetAllClientsForNilUser{
    BBB_DISABLE_ASSERTIONS();
    BBB_PREPARE_SEMAPHORE();

    [service getAllClientsForUser:nil completion:^(NSArray *clients, NSError *error) {
        BBBAssertAuthResponseErrorCode(clients, error, BBBAPIErrorInvalidParameters);
        BBB_SIGNAL_SEMAPHORE();
    }];

    BBB_WAIT_FOR_SEMAPHORE();
    BBB_ENABLE_ASSERTIONS();
}

- (void) testDeleteClientWithNilUser{
    BBB_DISABLE_ASSERTIONS();
    BBB_PREPARE_SEMAPHORE();
    BBBUserDetails *user = nil;
    BBBClientDetails *client = [BBBClientDetails new];
    client.uri = @"1";
    [service deleteClient:client forUser:user completion:^(BOOL succes, NSError *error) {
        XCTAssertFalse(succes);
        XCTAssertEqualObjects(error.domain, kBBBAuthServiceName);
        XCTAssertEqual(error.code, BBBAPIErrorInvalidParameters);
        BBB_SIGNAL_SEMAPHORE();
    }];

    BBB_WAIT_FOR_SEMAPHORE();
    BBB_ENABLE_ASSERTIONS();
}

- (void) testDeleteClientWithNilClient{
    BBB_DISABLE_ASSERTIONS();
    BBB_PREPARE_SEMAPHORE();
    BBBClientDetails *client;
    BBBUserDetails *user = [self validUserDetails];

    [service deleteClient:client forUser:user completion:^(BOOL succes, NSError *error) {
        XCTAssertFalse(succes);
        XCTAssertEqualObjects(error.domain, kBBBAuthServiceName);
        XCTAssertEqual(error.code, BBBAPIErrorInvalidParameters);
        BBB_SIGNAL_SEMAPHORE();
    }];

    BBB_WAIT_FOR_SEMAPHORE();
    BBB_ENABLE_ASSERTIONS();
}

- (void) testDeleteClientThrowsWithNilUser{
    BBBUserDetails *user  = nil;
    BBBClientDetails *client = [BBBClientDetails new];
    client.uri = @"1";
    XCTAssertThrows([service deleteClient:client forUser:user completion:^(BOOL succes, NSError *error) {

    }]);
}

- (void) testDeleteClientThrowsWithNilCompletion{
    BBBUserDetails *user  = [self validUserDetails];
    BBBClientDetails *client = [BBBClientDetails new];
    client.uri = @"1";
    XCTAssertThrows([service deleteClient:client forUser:user completion:nil]);
}

- (void) testGetAllClientsThrowsWithNilUser{
    XCTAssertThrows([service getAllClientsForUser:nil completion:^(NSArray *clients, NSError *error) {

    }]);
}

- (void) testGetAllClientsThrowsWithNilCompletion{
    XCTAssertThrows([service getAllClientsForUser:[self validUserDetails] completion:nil]);
}

#pragma mark - Helper methods
- (void) prepareDefaultAuthenticatorWithValidUser:(BBBUserDetails **)user
                                        andClient:(BBBClientDetails **)client{
    NSObject <BBBAuthenticator> *authenticator = [BBBNetworkConfiguration sharedAuthenticator];

    BBBUserDetails *validuser = nil;
    BBBClientDetails *validclient = nil;

    [self prepareValidUserDetails:&validuser
        withMatchingClientDetails:&validclient];

    [authenticator setValue:validuser forKey:@"currentUser"];
    [authenticator setValue:validclient forKey:@"currentClient"];

    *user = validuser;
    *client = validclient;
}

- (void) resetDefaultAuthenticatorUserAndClient{
    NSObject <BBBAuthenticator> *authenticator = [BBBNetworkConfiguration sharedAuthenticator];
    [authenticator setValue:nil forKey:@"currentUser"];
    [authenticator setValue:nil forKey:@"currentClient"];
}

- (BBBAuthData *) validUserAuthDataForRefreshing{
    __block BBBAuthData *authData = [BBBAuthData new];
    BBBUserDetails *user;
    BBBClientDetails *client;
    [self prepareValidUserDetails:&user withMatchingClientDetails:&client];
    BBB_PREPARE_SEMAPHORE();
    [service loginUser:user
                client:client
            completion:^(BBBAuthData *data, NSError *error) {
                authData = data;
                BBB_SIGNAL_SEMAPHORE();
            }];
    BBB_WAIT_FOR_SEMAPHORE();
    authData.clientId = client.identifier;
    authData.clientSecret = client.secret;
    return authData;
}

- (BBBUserDetails *) validRegistrationUser{
    BBBUserDetails *details = [BBBUserDetails new];
    details.email = [NSString stringWithFormat:@"xctest_books_%06i@blinkbox.com", arc4random()];
    details.password = @"xctest_sexytest";
    details.firstName = @"XCTest Books";
    details.lastName = @"Account";
    details.acceptsTermsAndConditions = YES;
    details.allowMarketing = NO;
    return details;
}

- (BBBClientDetails *) validRegistrationClient{
    BBBClientDetails *details = [BBBClientDetails new];
    details.name = @"XCTest's iPhone Simulator";
    details.brand = @"Apple";
    details.operatingSystem = @"iOS7";
    details.model = @"iPhone Simulator";
    return details;
}

- (BBBAuthData *) invalidAuthDataForRefresh{
    BBBAuthData *data = [BBBAuthData new];
    data.refreshToken = @"garbage";
    return data;
}

- (BBBUserDetails *) validUserDetails{
    BBBUserDetails *userDetails = [BBBUserDetails new];
    userDetails.email = @"xctest_books@blinkbox.com";
    userDetails.password = @"xctest_sexytest";
    return userDetails;
}

- (BBBClientDetails *) invalidClientDetails{
    BBBClientDetails *clientDetails = [BBBClientDetails new];
    clientDetails.identifier = @"urn:blinkbox:zuul:client:-1";
    clientDetails.secret = @"111111111222222222233333333334444444445555";
    return clientDetails;
}

- (BBBUserDetails *) nonexistantUserDetails{
    BBBUserDetails *userDetails = [BBBUserDetails new];
    userDetails.email = @"xctest_books_this_account_is_not_registered_do_not_register_it@blinkbox.com";
    userDetails.password = @"xctest_sexytest";
    return userDetails;
}

- (void) prepareValidUserDetails:(BBBUserDetails **)userDetails
       withMatchingClientDetails:(BBBClientDetails **)clientDetails{
    BBBUserDetails *validUserDetails = [BBBUserDetails new];
    validUserDetails.email = @"xctest_books_with_client@blinkbox.com";
    validUserDetails.password = @"xctest_sexytest_with_client";

    BBBClientDetails *validClientDetails = [BBBClientDetails new];
    validClientDetails.identifier = @"urn:blinkbox:zuul:client:32359";
    validClientDetails.secret = @"9d6pFCSy6kUg8AP3JKZ6uhn-AzBg3c31sGqSPyzBTY0";
    
    *userDetails = validUserDetails;
    *clientDetails = validClientDetails;
}
@end
