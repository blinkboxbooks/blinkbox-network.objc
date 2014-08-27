//
//  BBAAuthenticationServiceTests.m
//  BBAAPI
//
//  Created by Owen Worley on 04/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAAuthenticationService.h"
#import "BBAUserDetails.h"
#import "BBAClientDetails.h"
#import "BBAAuthData.h"
#import "BBAAuthenticationServiceConstants.h"
#import "BBAAPIErrors.h"
#import "BBANetworkConfiguration.h"
#import "BBAAuthenticator.h"

#define BBAAssertAuthResponseErrorCode(authData,error,errorCode)\
XCTAssertNil(authData);\
XCTAssertEqualObjects(error.domain, kBBAAuthServiceName);\
XCTAssertEqual(error.code, errorCode);

@interface BBAAuthenticationServiceTests : XCTestCase

@end

@implementation BBAAuthenticationServiceTests

BBAAuthenticationService *service;

- (void) setUp{
    [super setUp];
    service = [BBAAuthenticationService new];


}
- (void) tearDown{
    [self resetDefaultAuthenticatorUserAndClient];
    service = nil;
    [super tearDown];
}

#pragma mark - Tests that do not call Live API's
- (void) testRegisterUserAndClientWithNilClient{
    BBA_DISABLE_ASSERTIONS();
    BBAUserDetails *user = [self validRegistrationUser];
    BBAClientDetails *client = nil;
    BBA_PREPARE_SEMAPHORE();
    [service registerUser:user client:client completion:^(BBAAuthData *data, NSError *error) {
        BBAAssertAuthResponseErrorCode(data, error, BBAAPIWrongUsage);
        BBA_SIGNAL_SEMAPHORE();
    }];
    BBA_WAIT_FOR_SEMAPHORE();
    BBA_ENABLE_ASSERTIONS();
}

- (void) testRegisterUserAndClientThrowsWithNilClient{
    BBAUserDetails *user = [self validRegistrationUser];
    BBAClientDetails *client = nil;
    XCTAssertThrows([service registerUser:user client:client completion:^(BBAAuthData *data, NSError *error) {
    }]);
}

- (void) testRegisterUserAndClientWithNilUser{
    BBA_DISABLE_ASSERTIONS();
    BBAUserDetails *user = nil;
    BBAClientDetails *client = [self validRegistrationClient];
    BBA_PREPARE_SEMAPHORE();
    [service registerUser:user client:client completion:^(BBAAuthData *data, NSError *error) {
        BBAAssertAuthResponseErrorCode(data, error, BBAAPIWrongUsage);
        BBA_SIGNAL_SEMAPHORE();
    }];
    BBA_WAIT_FOR_SEMAPHORE();
    BBA_ENABLE_ASSERTIONS();
}

- (void) testRegisterUserAndClientThrowsWithNilUser{
    BBAUserDetails *user = nil;
    BBAClientDetails *client = [self validRegistrationClient];
    XCTAssertThrows([service registerUser:user client:client completion:^(BBAAuthData *data, NSError *error) {
    }]);
}

- (void) testRegisterUserAndClientThrowsWithNilCompletion{
    BBAUserDetails *user = [self validRegistrationUser];
    BBAClientDetails *client = [self validRegistrationClient];
    XCTAssertThrows([service registerUser:user client:client completion:nil]);
}

- (void) testRegisterClientWithNilClient{
    BBA_DISABLE_ASSERTIONS();
    BBAUserDetails *user = [self validUserDetails];
    BBAClientDetails *client = nil;
    BBA_PREPARE_SEMAPHORE();
    [service registerClient:client forUser:user completion:^(BBAClientDetails *data, NSError *error) {
        BBAAssertAuthResponseErrorCode(data, error, BBAAPIWrongUsage);
        BBA_SIGNAL_SEMAPHORE();
    }];
    BBA_WAIT_FOR_SEMAPHORE();
    BBA_ENABLE_ASSERTIONS();
}

- (void) testRegisterClientWithNilUser{
    BBA_DISABLE_ASSERTIONS();
    BBAUserDetails *user = nil;
    BBAClientDetails *client = [self validRegistrationClient];
    BBA_PREPARE_SEMAPHORE();
    [service registerClient:client forUser:user completion:^(BBAClientDetails *data, NSError *error) {
        BBAAssertAuthResponseErrorCode(data, error, BBAAPIWrongUsage);
        BBA_SIGNAL_SEMAPHORE();
    }];
    BBA_WAIT_FOR_SEMAPHORE();
    BBA_ENABLE_ASSERTIONS();
}

- (void) testRegisterClientThrowsWithNilClient{
    BBAUserDetails *user = [self validUserDetails];
    BBAClientDetails *client = nil;
    XCTAssertThrows([service registerClient:client forUser:user completion:^(BBAClientDetails *data, NSError *error) {
    }]);
}

- (void) testRegisterClientThrowsWithNilUser{
    BBAUserDetails *user = nil;
    BBAClientDetails *client = [self validRegistrationClient];
    XCTAssertThrows([service registerClient:client forUser:user completion:^(BBAClientDetails *data, NSError *error) {
    }]);
}

- (void) testRegisterClientThrowsWithNilCompletion{
    BBAUserDetails *user = [self validUserDetails];
    BBAClientDetails *client = [self validRegistrationClient];
    XCTAssertThrows([service registerClient:client forUser:user completion:nil]);
}

- (void) testLoginWithNilUserAndClient{
    BBA_DISABLE_ASSERTIONS();
    BBA_PREPARE_SEMAPHORE();
    [service loginUser:nil
                client:nil
            completion:^(BBAAuthData *data, NSError *error) {
                BBAAssertAuthResponseErrorCode(data, error, BBAAPIWrongUsage);
                BBA_SIGNAL_SEMAPHORE();
            }];

    BBA_WAIT_FOR_SEMAPHORE();
    BBA_ENABLE_ASSERTIONS();
}

- (void) testLoginThrowsWithNilUser{
    BBAUserDetails *user = nil;
    XCTAssertThrows([service loginUser:user client:nil completion:^(BBAAuthData *data, NSError *error) {
    }]);

}

- (void) testLoginThrowsWithNilCompletion{
    BBAUserDetails *user = [self validUserDetails];
    XCTAssertThrows([service registerClient:nil forUser:user completion:nil]);
}

- (void) testRefreshAuthDataWithNilAuthData{
    BBAAuthData *validAuthData = nil;
    BBA_DISABLE_ASSERTIONS();
    BBA_PREPARE_SEMAPHORE();
    [service refreshAuthData:validAuthData completion:^(BBAAuthData *refreshedData, NSError *error) {
        BBAAssertAuthResponseErrorCode(refreshedData, error, BBAAPIWrongUsage);
        BBA_SIGNAL_SEMAPHORE();
    }];

    BBA_WAIT_FOR_SEMAPHORE();
    BBA_ENABLE_ASSERTIONS();
}

- (void) testRefreshAuthDataThrowsWithNilAuthData{
    XCTAssertThrows([service refreshAuthData:nil completion:^(BBAAuthData *refeshedData, NSError *error) {
    }]);
}

- (void) testRefreshAuthDataThrowsWithNilAuthCompletion{
    BBAAuthData *data = [self validUserAuthDataForRefreshing];
    XCTAssertThrows([service refreshAuthData:data completion:nil]);
}

- (void) testGetAllClientsForNilUser{
    BBA_DISABLE_ASSERTIONS();
    BBA_PREPARE_SEMAPHORE();

    [service getAllClientsForUser:nil completion:^(NSArray *clients, NSError *error) {
        BBAAssertAuthResponseErrorCode(clients, error, BBAAPIWrongUsage);
        BBA_SIGNAL_SEMAPHORE();
    }];

    BBA_WAIT_FOR_SEMAPHORE();
    BBA_ENABLE_ASSERTIONS();
}

- (void) testDeleteClientWithNilUser{
    BBA_DISABLE_ASSERTIONS();
    BBA_PREPARE_SEMAPHORE();
    BBAUserDetails *user = nil;
    BBAClientDetails *client = [BBAClientDetails new];
    client.uri = @"1";
    [service deleteClient:client forUser:user completion:^(BOOL succes, NSError *error) {
        XCTAssertFalse(succes);
        XCTAssertEqualObjects(error.domain, kBBAAuthServiceName);
        XCTAssertEqual(error.code, BBAAPIWrongUsage);
        BBA_SIGNAL_SEMAPHORE();
    }];

    BBA_WAIT_FOR_SEMAPHORE();
    BBA_ENABLE_ASSERTIONS();
}

- (void) testDeleteClientWithNilClient{
    BBA_DISABLE_ASSERTIONS();
    BBA_PREPARE_SEMAPHORE();
    BBAClientDetails *client;
    BBAUserDetails *user = [self validUserDetails];

    [service deleteClient:client forUser:user completion:^(BOOL succes, NSError *error) {
        XCTAssertFalse(succes);
        XCTAssertEqualObjects(error.domain, kBBAAuthServiceName);
        XCTAssertEqual(error.code, BBAAPIWrongUsage);
        BBA_SIGNAL_SEMAPHORE();
    }];

    BBA_WAIT_FOR_SEMAPHORE();
    BBA_ENABLE_ASSERTIONS();
}

- (void) testDeleteClientThrowsWithNilUser{
    BBAUserDetails *user  = nil;
    BBAClientDetails *client = [BBAClientDetails new];
    client.uri = @"1";
    XCTAssertThrows([service deleteClient:client forUser:user completion:^(BOOL succes, NSError *error) {

    }]);
}

- (void) testDeleteClientThrowsWithNilCompletion{
    BBAUserDetails *user  = [self validUserDetails];
    BBAClientDetails *client = [BBAClientDetails new];
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

- (void) testResetPasswordForNilUser{
    BBA_DISABLE_ASSERTIONS();
    BBA_PREPARE_SEMAPHORE();
    [service resetPasswordForUser:nil completion:^(BOOL success, NSError *error) {
        XCTAssertFalse(success);
        XCTAssertEqualObjects(error.domain, kBBAAuthServiceName);
        XCTAssertEqual(error.code, BBAAPIWrongUsage);

        BBA_SIGNAL_SEMAPHORE();
    }];
    BBA_WAIT_FOR_SEMAPHORE();
    BBA_ENABLE_ASSERTIONS();

}

- (void) testResetPasswordThrowsForNilUser{
    XCTAssertThrows([service resetPasswordForUser:nil completion:^(BOOL success, NSError *error) {
    }]);
}

- (void) testResetPasswordThrowsForNilCompletion{
    BBAUserDetails *user = [self validUserDetails];
    XCTAssertThrows([service resetPasswordForUser:user completion:nil]);
}

- (void) testRevokeRefreshTokenWithNilUser{
    BBA_DISABLE_ASSERTIONS();
    BBA_PREPARE_SEMAPHORE();

    [service revokeRefreshTokenForUser:nil completion:^(BOOL succes, NSError *error) {
        XCTAssertFalse(succes);
        XCTAssertEqualObjects(error.domain, kBBAAuthServiceName);
        XCTAssertEqual(error.code, BBAAPIWrongUsage);
        BBA_SIGNAL_SEMAPHORE();
    }];

    BBA_WAIT_FOR_SEMAPHORE();
    BBA_ENABLE_ASSERTIONS();
}

- (void) testRevokeRefreshTokenThrowsWithNilUser{
    XCTAssertThrows([service revokeRefreshTokenForUser:nil completion:^(BOOL succes, NSError *error) {
    }]);
}

- (void) testRevokeRefreshTokenThrowsWithNilCompletion{
    BBAUserDetails *user = [self validUserDetails];
    XCTAssertThrows([service revokeRefreshTokenForUser:user completion:nil]);
}

#pragma mark - Tests that call Live API's
#if 0
//This creates an account on prod.
- (void) testRegisterUserAndClient{
    BBAUserDetails *user = [self validRegistrationUser];
    BBAClientDetails *client = [self validRegistrationClient];
    BBA_PREPARE_SEMAPHORE();
    [service registerUser:user client:client completion:^(BBAAuthData *data, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(data);
        BBA_SIGNAL_SEMAPHORE();
    }];
    BBA_WAIT_FOR_SEMAPHORE();
}
#endif

- (void) testRegisterClientAndDeleteClient{
    BBAUserDetails *user = [self validUserDetails];
    BBAClientDetails *client = [BBAClientDetails new];
    client.name = @"Unit Test";
    client.brand = @"Apple";
    client.operatingSystem = @"iOS8";
    client.model = @"iPhone Simulator";

    __block BBAClientDetails *addedClient = [BBAClientDetails new];

    BBA_PREPARE_SEMAPHORE();
    [service registerClient:client
                    forUser:user
                 completion:^(BBAClientDetails *data, NSError *error) {
                     XCTAssertNotNil(data);
                     XCTAssertNotNil(data.uri);
                     XCTAssertNil(error);
                     addedClient.uri = data.uri;
                     BBA_SIGNAL_SEMAPHORE();
                 }];
    BBA_WAIT_FOR_SEMAPHORE();

    BBA_RESET_SEMAPHORE();
    [service deleteClient:addedClient
                  forUser:user
               completion:^(BOOL succes, NSError *error) {
                   XCTAssertTrue(succes);
                   XCTAssertNil(error);
                   BBA_SIGNAL_SEMAPHORE();
               }];
    BBA_WAIT_FOR_SEMAPHORE();
}

- (void) testValidLoginWithUser{
    BBA_PREPARE_SEMAPHORE();
    BBAUserDetails *user = [self validUserDetails];

    [service loginUser:user
                client:nil
            completion:^(BBAAuthData *data, NSError *error) {
                XCTAssertNotNil(data);
                XCTAssertNil(error);
                BBA_SIGNAL_SEMAPHORE();
            }];

    BBA_WAIT_FOR_SEMAPHORE();
}

- (void) testLoginWithUnregisteredUser{
    BBA_PREPARE_SEMAPHORE();
    BBAUserDetails *user = [self nonexistantUserDetails];
    [service loginUser:user
                client:nil
            completion:^(BBAAuthData *data, NSError *error) {
                BBAAssertAuthResponseErrorCode(data, error, BBAAuthServiceErrorCodeInvalidGrant);
                BBA_SIGNAL_SEMAPHORE();
            }];

    BBA_WAIT_FOR_SEMAPHORE();
}

- (void) testLoginWithIncorrectPassword{
    BBA_PREPARE_SEMAPHORE();
    BBAUserDetails *user = [self validUserDetails];
    user.password = @"not_the_correct_password";
    [service loginUser:user
                client:nil
            completion:^(BBAAuthData *data, NSError *error) {
                BBAAssertAuthResponseErrorCode(data, error, BBAAuthServiceErrorCodeInvalidGrant);
                BBA_SIGNAL_SEMAPHORE();
            }];

    BBA_WAIT_FOR_SEMAPHORE();
}

- (void) testValidLoginWithUserAndClient{
    BBA_PREPARE_SEMAPHORE();
    BBAUserDetails *user = nil;
    BBAClientDetails *client = nil;
    [self prepareValidUserDetails:&user withMatchingClientDetails:&client];

    [service loginUser:user
                client:client
            completion:^(BBAAuthData *data, NSError *error) {
                XCTAssertNotNil(data);
                XCTAssertNil(error);
                BBA_SIGNAL_SEMAPHORE();
            }];

    BBA_WAIT_FOR_SEMAPHORE();
}

- (void) testLoginWithUserAndInvalidClient{
    BBA_PREPARE_SEMAPHORE();
    BBAUserDetails *user = [self validUserDetails];
    BBAClientDetails *client = [self invalidClientDetails];

    [service loginUser:user
                client:client
            completion:^(BBAAuthData *data, NSError *error) {
                BBAAssertAuthResponseErrorCode(data, error, BBAAuthServiceErrorCodeInvalidClient);
                BBA_SIGNAL_SEMAPHORE();
            }];

    BBA_WAIT_FOR_SEMAPHORE();
}

- (void) testRefreshAuthDataWithInvalidAuthData{
    BBAAuthData *validAuthData = [self invalidAuthDataForRefresh];

    BBA_PREPARE_SEMAPHORE();
    [service refreshAuthData:validAuthData completion:^(BBAAuthData *refreshedData, NSError *error) {
        BBAAssertAuthResponseErrorCode(refreshedData, error, BBAAuthServiceErrorCodeInvalidGrant);
        BBA_SIGNAL_SEMAPHORE();
    }];

    BBA_WAIT_FOR_SEMAPHORE();
}

- (void) testRefreshAuthDataWithValidRefreshToken{
    BBAAuthData *validAuthData = [self validUserAuthDataForRefreshing];
    XCTAssertNotNil(validAuthData, @"Cannot test refresh with invalid authData");

    BBA_PREPARE_SEMAPHORE();
    [service refreshAuthData:validAuthData completion:^(BBAAuthData *refeshedData, NSError *error) {

        XCTAssertNil(error);
        XCTAssertNotNil(refeshedData);
        BBA_SIGNAL_SEMAPHORE();
    }];

    BBA_WAIT_FOR_SEMAPHORE();
}

- (void) testRefreshAuthDataWithValidRefreshTokenButIncorrectClientInformation{
    BBAAuthData *validAuthData = [self validUserAuthDataForRefreshing];
    validAuthData.clientId = @"asdasd";
    validAuthData.clientSecret = @"asdasdsadasf";
    XCTAssertNotNil(validAuthData, @"Cannot test refresh with invalid authData");

    BBA_PREPARE_SEMAPHORE();
    [service refreshAuthData:validAuthData completion:^(BBAAuthData *refreshedData, NSError *error) {

        BBAAssertAuthResponseErrorCode(refreshedData, error, BBAAuthServiceErrorCodeInvalidClient);
        BBA_SIGNAL_SEMAPHORE();
    }];

    BBA_WAIT_FOR_SEMAPHORE();
}

- (void) testResetPassword{
    BBA_PREPARE_SEMAPHORE();

    BBAUserDetails *details = [BBAUserDetails new];
    details.email = @"randomtestaccount@blinkbox.com";

    [service resetPasswordForUser:details completion:^(BOOL success, NSError *error) {
        XCTAssertTrue(success);
        XCTAssertNil(error);
        BBA_SIGNAL_SEMAPHORE();
    }];

    BBA_WAIT_FOR_SEMAPHORE();
}

- (void) testRevokeValidRefreshToken{
    BBAAuthData *validAuthData = [self validUserAuthDataForRefreshing];
    XCTAssertNotNil(validAuthData, @"Cannot test revoke with invalid authData");
    BBAUserDetails *revokeUserDetails = [BBAUserDetails new];
    revokeUserDetails.refreshToken = validAuthData.refreshToken;

    BBA_PREPARE_SEMAPHORE();
    [service revokeRefreshTokenForUser:revokeUserDetails
                            completion:^(BOOL success, NSError *error) {

                                XCTAssertNil(error);
                                XCTAssertTrue(success);
                                BBA_SIGNAL_SEMAPHORE();
                            }];

    BBA_WAIT_FOR_SEMAPHORE();
}

- (void) testRevokeInvalidRefreshToken{
    BBAUserDetails *revokeUserDetails = [BBAUserDetails new];
    revokeUserDetails.refreshToken = @"sdfsdfsdfsdf32g";

    BBA_PREPARE_SEMAPHORE();
    [service revokeRefreshTokenForUser:revokeUserDetails
                            completion:^(BOOL success, NSError *error) {

                                XCTAssertEqualObjects(error.domain, kBBAAuthServiceName);
                                XCTAssertEqual(error.code, BBAAuthServiceErrorCodeInvalidGrant);
                                XCTAssertFalse(success);
                                BBA_SIGNAL_SEMAPHORE();
                            }];

    BBA_WAIT_FOR_SEMAPHORE();
}

- (void) testGetAllClients{
    BBA_PREPARE_SEMAPHORE();

    BBAUserDetails *user;
    BBAClientDetails *client;
    [self prepareDefaultAuthenticatorWithValidUser:&user
                                         andClient:&client];

    [service getAllClientsForUser:user completion:^(NSArray *clients, NSError *error) {
        XCTAssertTrue([clients isKindOfClass:[NSArray class]]);
        XCTAssertNil(error);
        BBA_SIGNAL_SEMAPHORE();
        
    }];
    BBA_WAIT_FOR_SEMAPHORE();
    
}

#pragma mark - Helper methods
- (void) prepareDefaultAuthenticatorWithValidUser:(BBAUserDetails **)user
                                        andClient:(BBAClientDetails **)client{
    NSObject <BBAAuthenticator> *authenticator = [BBANetworkConfiguration sharedAuthenticator];

    BBAUserDetails *validuser = nil;
    BBAClientDetails *validclient = nil;

    [self prepareValidUserDetails:&validuser
        withMatchingClientDetails:&validclient];

    [authenticator setValue:validuser forKey:@"currentUser"];
    [authenticator setValue:validclient forKey:@"currentClient"];

    *user = validuser;
    *client = validclient;
}

- (void) resetDefaultAuthenticatorUserAndClient{
    NSObject <BBAAuthenticator> *authenticator = [BBANetworkConfiguration sharedAuthenticator];
    [authenticator setValue:nil forKey:@"currentUser"];
    [authenticator setValue:nil forKey:@"currentClient"];
}

- (BBAAuthData *) validUserAuthDataForRefreshing{
    __block BBAAuthData *authData = [BBAAuthData new];
    BBAUserDetails *user;
    BBAClientDetails *client;
    [self prepareValidUserDetails:&user withMatchingClientDetails:&client];
    BBA_PREPARE_SEMAPHORE();
    [service loginUser:user
                client:client
            completion:^(BBAAuthData *data, NSError *error) {
                authData = data;
                BBA_SIGNAL_SEMAPHORE();
            }];
    BBA_WAIT_FOR_SEMAPHORE();
    authData.clientId = client.identifier;
    authData.clientSecret = client.secret;
    return authData;
}

- (BBAUserDetails *) validRegistrationUser{
    BBAUserDetails *details = [BBAUserDetails new];
    details.email = [NSString stringWithFormat:@"xctest_books_%06i@blinkbox.com", arc4random()];
    details.password = @"xctest_sexytest";
    details.firstName = @"XCTest Books";
    details.lastName = @"Account";
    details.acceptsTermsAndConditions = YES;
    details.allowMarketing = NO;
    return details;
}

- (BBAClientDetails *) validRegistrationClient{
    BBAClientDetails *details = [BBAClientDetails new];
    details.name = @"XCTest's iPhone Simulator";
    details.brand = @"Apple";
    details.operatingSystem = @"iOS7";
    details.model = @"iPhone Simulator";
    return details;
}

- (BBAAuthData *) invalidAuthDataForRefresh{
    BBAAuthData *data = [BBAAuthData new];
    data.refreshToken = @"garbage";
    return data;
}

- (BBAUserDetails *) validUserDetails{
    BBAUserDetails *userDetails = [BBAUserDetails new];
    userDetails.email = @"xctest_books@blinkbox.com";
    userDetails.password = @"xctest_sexytest";
    return userDetails;
}

- (BBAClientDetails *) invalidClientDetails{
    BBAClientDetails *clientDetails = [BBAClientDetails new];
    clientDetails.identifier = @"urn:blinkbox:zuul:client:-1";
    clientDetails.secret = @"111111111222222222233333333334444444445555";
    return clientDetails;
}

- (BBAUserDetails *) nonexistantUserDetails{
    BBAUserDetails *userDetails = [BBAUserDetails new];
    userDetails.email = @"xctest_books_this_account_is_not_registered_do_not_register_it@blinkbox.com";
    userDetails.password = @"xctest_sexytest";
    return userDetails;
}

- (void) prepareValidUserDetails:(BBAUserDetails **)userDetails
       withMatchingClientDetails:(BBAClientDetails **)clientDetails{
    BBAUserDetails *validUserDetails = [BBAUserDetails new];
    validUserDetails.email = @"xctest_books_with_client@blinkbox.com";
    validUserDetails.password = @"xctest_sexytest_with_client";

    BBAClientDetails *validClientDetails = [BBAClientDetails new];
    validClientDetails.identifier = @"urn:blinkbox:zuul:client:32359";
    validClientDetails.secret = @"9d6pFCSy6kUg8AP3JKZ6uhn-AzBg3c31sGqSPyzBTY0";
    
    *userDetails = validUserDetails;
    *clientDetails = validClientDetails;
}
@end
