//
//  BBAAuthentication_IntegrationTests.m
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 13/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BBAAuthenticationService.h"
#import "BBAUserDetails.h"
#import "BBAClientDetails.h"
#import "BBAAuthData.h"
#import "BBAAuthenticationServiceConstants.h"
#import "BBATestMacros.h"
#import "BBAAPIErrors.h"

@interface BBAAuthentication_IntegrationTests : XCTestCase{
    BBAAuthenticationService *service;
}

@end

@implementation BBAAuthentication_IntegrationTests

- (void) setUp{
    [super setUp];
    service = [BBAAuthenticationService new];
}

- (void) tearDown{
    service = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void) testRegisterUserAndClient{
    BBAUserDetails *user = [self validRegistrationUser];
    BBAClientDetails *client = [self validRegistrationClient];
    BBA_PREPARE_ASYNC_TEST();
    [service registerUser:user client:client completion:^(BBAAuthData *data, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(data);
        BBA_FLAG_ASYNC_TEST_COMPLETE();
    }];
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testRegisterClientAndDeleteClient{
    BBAUserDetails *user = [self validUserDetails];
    BBAClientDetails *client = [BBAClientDetails new];
    client.name = @"Unit Test";
    client.brand = @"Apple";
    client.operatingSystem = @"iOS8";
    client.model = @"iPhone Simulator";
    
    __block BBAClientDetails *addedClient = [BBAClientDetails new];
    
    BBA_PREPARE_ASYNC_TEST();
    [service registerClient:client
                    forUser:user
                 completion:^(BBAClientDetails *data, NSError *error) {
                     XCTAssertNotNil(data);
                     XCTAssertNotNil(data.uri);
                     XCTAssertNil(error);
                     addedClient.uri = data.uri;
                     BBA_FLAG_ASYNC_TEST_COMPLETE();
                 }];
    BBA_WAIT_FOR_ASYNC_TEST();
    
    BBA_RESET_ASYNC_TEST();
    [service deleteClient:addedClient
                  forUser:user
               completion:^(BOOL succes, NSError *error) {
                   XCTAssertTrue(succes);
                   XCTAssertNil(error);
                   BBA_FLAG_ASYNC_TEST_COMPLETE();
               }];
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testValidLoginWithUser{
    BBA_PREPARE_ASYNC_TEST();
    BBAUserDetails *user = [self validUserDetails];
    
    [service loginUser:user
                client:nil
            completion:^(BBAAuthData *data, NSError *error) {
                XCTAssertNotNil(data);
                XCTAssertNil(error);
                BBA_FLAG_ASYNC_TEST_COMPLETE();
            }];
    
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testLoginWithUnregisteredUser{
    BBA_PREPARE_ASYNC_TEST();
    BBAUserDetails *user = [self nonexistantUserDetails];
    [service loginUser:user
                client:nil
            completion:^(BBAAuthData *data, NSError *error) {
                BBAAssertErrorHasCodeAndDomain(error, BBAAuthServiceErrorCodeInvalidGrant, kBBAAuthServiceName);
                XCTAssertNil(data);
                BBA_FLAG_ASYNC_TEST_COMPLETE();
            }];
    
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testLoginWithIncorrectPassword{
    BBA_PREPARE_ASYNC_TEST();
    BBAUserDetails *user = [self validUserDetails];
    user.password = @"not_the_correct_password";
    [service loginUser:user
                client:nil
            completion:^(BBAAuthData *data, NSError *error) {
                BBAAssertErrorHasCodeAndDomain(error, BBAAuthServiceErrorCodeInvalidGrant, kBBAAuthServiceName);
                XCTAssertNil(data);
                BBA_FLAG_ASYNC_TEST_COMPLETE();
            }];
    
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testValidLoginWithUserAndClient{
    BBA_PREPARE_ASYNC_TEST();
    BBAUserDetails *user = nil;
    BBAClientDetails *client = nil;
    [self prepareValidUserDetails:&user withMatchingClientDetails:&client];
    
    [service loginUser:user
                client:client
            completion:^(BBAAuthData *data, NSError *error) {
                XCTAssertNotNil(data);
                XCTAssertNil(error);
                BBA_FLAG_ASYNC_TEST_COMPLETE();
            }];
    
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testLoginWithUserAndInvalidClient{
    BBA_PREPARE_ASYNC_TEST();
    BBAUserDetails *user = [self validUserDetails];
    BBAClientDetails *client = [self invalidClientDetails];
    
    [service loginUser:user
                client:client
            completion:^(BBAAuthData *data, NSError *error) {
                BBAAssertErrorHasCodeAndDomain(error,
                                               BBAAuthServiceErrorCodeInvalidClient,
                                               kBBAAuthServiceName);
                XCTAssertNil(data);
                BBA_FLAG_ASYNC_TEST_COMPLETE();
            }];
    
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testRefreshAuthDataWithInvalidAuthData{
    BBAAuthData *validAuthData = [self invalidAuthDataForRefresh];
    
    BBA_PREPARE_ASYNC_TEST();
    [service refreshAuthData:validAuthData completion:^(BBAAuthData *refreshedData, NSError *error) {
        BBAAssertErrorHasCodeAndDomain(error, BBAAuthServiceErrorCodeInvalidGrant, kBBAAuthServiceName);
        XCTAssertNil(refreshedData);
        BBA_FLAG_ASYNC_TEST_COMPLETE();
    }];
    
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testRefreshAuthDataWithValidRefreshToken{
    BBAAuthData *validAuthData = [self validUserAuthDataForRefreshing];
    XCTAssertNotNil(validAuthData, @"Cannot test refresh with invalid authData");
    
    BBA_PREPARE_ASYNC_TEST();
    [service refreshAuthData:validAuthData completion:^(BBAAuthData *refeshedData, NSError *error) {
        
        XCTAssertNil(error);
        XCTAssertNotNil(refeshedData);
        BBA_FLAG_ASYNC_TEST_COMPLETE();
    }];
    
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testRefreshAuthDataWithValidRefreshTokenButIncorrectClientInformation{
    BBAAuthData *validAuthData = [self validUserAuthDataForRefreshing];
    validAuthData.clientId = @"asdasd";
    validAuthData.clientSecret = @"asdasdsadasf";
    XCTAssertNotNil(validAuthData, @"Cannot test refresh with invalid authData");
    
    BBA_PREPARE_ASYNC_TEST();
    [service refreshAuthData:validAuthData completion:^(BBAAuthData *refreshedData, NSError *error) {
        
        BBAAssertErrorHasCodeAndDomain(error, BBAAuthServiceErrorCodeInvalidClient, kBBAAuthServiceName);
        XCTAssertNil(refreshedData);
        BBA_FLAG_ASYNC_TEST_COMPLETE();
    }];
    
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testResetPassword{
    BBA_PREPARE_ASYNC_TEST();
    
    BBAUserDetails *details = [BBAUserDetails new];
    details.email = @"randomtestaccount@blinkbox.com";
    
    [service resetPasswordForUser:details completion:^(BOOL success, NSError *error) {
        XCTAssertTrue(success);
        XCTAssertNil(error);
        BBA_FLAG_ASYNC_TEST_COMPLETE();
    }];
    
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testRevokeValidRefreshToken{
    BBAAuthData *validAuthData = [self validUserAuthDataForRefreshing];
    XCTAssertNotNil(validAuthData, @"Cannot test revoke with invalid authData");
    BBAUserDetails *revokeUserDetails = [BBAUserDetails new];
    revokeUserDetails.refreshToken = validAuthData.refreshToken;
    
    BBA_PREPARE_ASYNC_TEST();
    [service revokeRefreshTokenForUser:revokeUserDetails
                            completion:^(BOOL success, NSError *error) {
                                
                                XCTAssertNil(error);
                                XCTAssertTrue(success);
                                BBA_FLAG_ASYNC_TEST_COMPLETE();
                            }];
    
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testRevokeInvalidRefreshToken{
    BBAUserDetails *revokeUserDetails = [BBAUserDetails new];
    revokeUserDetails.refreshToken = @"sdfsdfsdfsdf32g";
    
    BBA_PREPARE_ASYNC_TEST();
    [service revokeRefreshTokenForUser:revokeUserDetails
                            completion:^(BOOL success, NSError *error) {
                                
                                XCTAssertEqualObjects(error.domain, kBBAAuthServiceName);
                                XCTAssertEqual(error.code, BBAAuthServiceErrorCodeInvalidGrant);
                                XCTAssertFalse(success);
                                BBA_FLAG_ASYNC_TEST_COMPLETE();
                            }];
    
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testGetAllClients{
    BBA_PREPARE_ASYNC_TEST();
    
    BBAUserDetails *user;
    BBAClientDetails *client;
    [self prepareValidUserDetails:&user
        withMatchingClientDetails:&client];
    
    [service getAllClientsForUser:user completion:^(NSArray *clients, NSError *error) {
        XCTAssertTrue([clients isKindOfClass:[NSArray class]]);
        XCTAssertNil(error);
        BBA_FLAG_ASYNC_TEST_COMPLETE();
        
    }];
    BBA_WAIT_FOR_ASYNC_TEST();
    
}


#pragma mark - Helpers

- (BBAAuthData *) validUserAuthDataForRefreshing{
    __block BBAAuthData *authData = [BBAAuthData new];
    BBAUserDetails *user;
    BBAClientDetails *client;
    [self prepareValidUserDetails:&user withMatchingClientDetails:&client];
    BBA_PREPARE_ASYNC_TEST();
    [service loginUser:user
                client:client
            completion:^(BBAAuthData *data, NSError *error) {
                authData = data;
                BBA_FLAG_ASYNC_TEST_COMPLETE();
            }];
    BBA_WAIT_FOR_ASYNC_TEST();
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
