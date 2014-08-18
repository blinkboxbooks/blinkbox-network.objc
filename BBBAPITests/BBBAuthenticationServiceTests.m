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

+ (void) setUp{
    service = [BBBAuthenticationService new];
}

+ (void) tearDown{
    service = nil;
}

- (void) tearDown{
    [self resetDefaultAuthenticatorUserAndClient];
}

#pragma mark - Tests against live (prod) API
- (void) testRegisterUserAndClientWithNilClient{
    BBBUserDetails *user;
    BBBClientDetails *client = nil;
    BBB_PREPARE_SEMAPHORE();
    [service registerUser:user client:client completion:^(BBBAuthData *data, NSError *error) {
        BBBAssertAuthResponseErrorCode(data, error, BBBAPIErrorInvalidParameters);
        BBB_SIGNAL_SEMAPHORE();
    }];
    BBB_WAIT_FOR_SEMAPHORE();
}

- (void) testRegisterUserAndClientWithNilUser{
    BBBUserDetails *user = nil;
    BBBClientDetails *client;
    BBB_PREPARE_SEMAPHORE();
    [service registerUser:user client:client completion:^(BBBAuthData *data, NSError *error) {
        BBBAssertAuthResponseErrorCode(data, error, BBBAPIErrorInvalidParameters);
        BBB_SIGNAL_SEMAPHORE();
    }];
    BBB_WAIT_FOR_SEMAPHORE();
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
    BBB_PREPARE_SEMAPHORE();

    [service loginUser:nil
                client:nil
            completion:^(BBBAuthData *data, NSError *error) {
                BBBAssertAuthResponseErrorCode(data, error, BBBAPIErrorInvalidParameters);
                BBB_SIGNAL_SEMAPHORE();
            }];

    BBB_WAIT_FOR_SEMAPHORE();
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

    BBB_PREPARE_SEMAPHORE();
    [service refreshAuthData:validAuthData completion:^(BBBAuthData *refreshedData, NSError *error) {
        BBBAssertAuthResponseErrorCode(refreshedData, error, BBBAPIErrorInvalidParameters);
        BBB_SIGNAL_SEMAPHORE();
    }];

    BBB_WAIT_FOR_SEMAPHORE();
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

- (BBBUserDetails *)validRegistrationUser{
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

- (BBBAuthData *)invalidAuthDataForRefresh{
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
