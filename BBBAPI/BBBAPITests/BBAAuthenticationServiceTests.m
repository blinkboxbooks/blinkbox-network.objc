//
//  BBAAuthenticationServiceTests.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 04/08/2014.
 

#import "BBAAuthenticationService.h"
#import "BBAUserDetails.h"
#import "BBAClientDetails.h"
#import "BBAAuthData.h"
#import "BBASwizzlingHelper.h"
#import "BBAAuthenticationServiceConstants.h"
#import "BBAAPIErrors.h"
#import "BBANetworkConfiguration.h"
#import "BBAAuthenticator.h"
#import "BBADefaultAuthenticator.h"

#define BBAAssertAuthResponseErrorCode(authData,error,errorCode)\
XCTAssertNil(authData);\
XCTAssertEqualObjects(error.domain, kBBAAuthServiceName);\
XCTAssertEqual(error.code, errorCode);

@interface BBAMockAuthNetworkConfiguration : BBANetworkConfiguration

@end

@implementation BBAMockAuthNetworkConfiguration

@end

@interface BBAMockTestAuthenticator : BBADefaultAuthenticator
@end

@implementation BBAMockTestAuthenticator

@end


@interface BBAAuthenticationServiceTests : XCTestCase{
    BBAAuthenticationService *service;
    BBAMockAuthNetworkConfiguration *configuration;
    BBAMockTestAuthenticator *authenticator;
    
    IMP oldImplementation;
    id (^block)(id);
}

@end

@implementation BBAAuthenticationServiceTests

#pragma mark - Setup/TearDown

- (void) setUp{
    [super setUp];
    configuration = [BBAMockAuthNetworkConfiguration new];
    authenticator = [BBAMockTestAuthenticator new];
    [configuration setValue:authenticator forKeyPath:@"authenticator"];
    __weak typeof(configuration) wconfiguration = configuration;
    block = ^id(id o){
        return wconfiguration;
    };
    
    Class c = [BBANetworkConfiguration class];
    c = object_getClass((id)c);
    SEL selector = @selector(defaultConfiguration);
    Method originalMethod = class_getClassMethod(c, selector);
    IMP newImplementation = imp_implementationWithBlock(block);
    oldImplementation = method_setImplementation(originalMethod, newImplementation);
    service = [BBAAuthenticationService new];


}

- (void) tearDown{
    Class c = [BBANetworkConfiguration class];
    c = object_getClass((id)c);
    SEL selector = @selector(defaultConfiguration);
    Method originalMethod = class_getInstanceMethod(c,selector);
    class_replaceMethod(c, selector, oldImplementation, method_getTypeEncoding(originalMethod));
    service = nil;
    authenticator = nil;
    block = nil;
    [super tearDown];
}

#pragma mark - Tests that do not call Live API's

- (void) testRegisterUserAndClientWithNilClient{
    BBA_DISABLE_ASSERTIONS();
    BBAUserDetails *user = [self validRegistrationUser];
    BBAClientDetails *client = nil;
    BBA_PREPARE_ASYNC_TEST();
    [service registerUser:user client:client completion:^(BBAAuthData *data, NSError *error) {
        BBAAssertErrorHasCodeAndDomain(error, BBAAPIWrongUsage, kBBAAuthServiceName);
        XCTAssertNil(data);
        BBA_FLAG_ASYNC_TEST_COMPLETE();
    }];
    BBA_WAIT_FOR_ASYNC_TEST();
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
    BBA_PREPARE_ASYNC_TEST();
    [service registerUser:user client:client completion:^(BBAAuthData *data, NSError *error) {
        BBAAssertErrorHasCodeAndDomain(error, BBAAPIWrongUsage, kBBAAuthServiceName);
        XCTAssertNil(data);
        BBA_FLAG_ASYNC_TEST_COMPLETE();
    }];
    BBA_WAIT_FOR_ASYNC_TEST();
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
    BBA_PREPARE_ASYNC_TEST();
    [service registerClient:client forUser:user completion:^(BBAClientDetails *data, NSError *error) {
        BBAAssertErrorHasCodeAndDomain(error, BBAAPIWrongUsage, kBBAAuthServiceName);
        XCTAssertNil(data);
        BBA_FLAG_ASYNC_TEST_COMPLETE();
    }];
    BBA_WAIT_FOR_ASYNC_TEST();
    BBA_ENABLE_ASSERTIONS();
}

- (void) testRegisterClientWithNilUser{
    BBA_DISABLE_ASSERTIONS();
    BBAUserDetails *user = nil;
    BBAClientDetails *client = [self validRegistrationClient];
    BBA_PREPARE_ASYNC_TEST();
    [service registerClient:client forUser:user completion:^(BBAClientDetails *data, NSError *error) {
        BBAAssertErrorHasCodeAndDomain(error, BBAAPIWrongUsage, kBBAAuthServiceName);
        XCTAssertNil(data);
        BBA_FLAG_ASYNC_TEST_COMPLETE();
    }];
    BBA_WAIT_FOR_ASYNC_TEST();
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
    BBA_PREPARE_ASYNC_TEST();
    [service loginUser:nil
                client:nil
            completion:^(BBAAuthData *data, NSError *error) {
                BBAAssertErrorHasCodeAndDomain(error, BBAAPIWrongUsage, kBBAAuthServiceName);
                XCTAssertNil(data);
                BBA_FLAG_ASYNC_TEST_COMPLETE();
            }];

    BBA_WAIT_FOR_ASYNC_TEST();
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
    BBA_PREPARE_ASYNC_TEST();
    [service refreshAuthData:validAuthData completion:^(BBAAuthData *refreshedData, NSError *error) {
        BBAAssertErrorHasCodeAndDomain(error, BBAAPIWrongUsage, kBBAAuthServiceName);
        XCTAssertNil(refreshedData);
        BBA_FLAG_ASYNC_TEST_COMPLETE();
    }];

    BBA_WAIT_FOR_ASYNC_TEST();
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
    BBA_PREPARE_ASYNC_TEST();

    [service getAllClientsForUser:nil completion:^(NSArray *clients, NSError *error) {
        BBAAssertErrorHasCodeAndDomain(error, BBAAPIWrongUsage, kBBAAuthServiceName);
        XCTAssertNil(clients);
        BBA_FLAG_ASYNC_TEST_COMPLETE();
    }];

    BBA_WAIT_FOR_ASYNC_TEST();
    BBA_ENABLE_ASSERTIONS();
}

- (void) testDeleteClientWithNilUser{
    BBA_DISABLE_ASSERTIONS();
    BBA_PREPARE_ASYNC_TEST();
    BBAUserDetails *user = nil;
    BBAClientDetails *client = [BBAClientDetails new];
    client.uri = @"1";
    [service deleteClient:client forUser:user completion:^(BOOL succes, NSError *error) {
        XCTAssertFalse(succes);
        XCTAssertEqualObjects(error.domain, kBBAAuthServiceName);
        XCTAssertEqual(error.code, BBAAPIWrongUsage);
        BBA_FLAG_ASYNC_TEST_COMPLETE();
    }];

    BBA_WAIT_FOR_ASYNC_TEST();
    BBA_ENABLE_ASSERTIONS();
}

- (void) testDeleteClientWithNilClient{
    BBA_DISABLE_ASSERTIONS();
    BBA_PREPARE_ASYNC_TEST();
    BBAClientDetails *client;
    BBAUserDetails *user = [self validUserDetails];

    [service deleteClient:client forUser:user completion:^(BOOL succes, NSError *error) {
        XCTAssertFalse(succes);
        XCTAssertEqualObjects(error.domain, kBBAAuthServiceName);
        XCTAssertEqual(error.code, BBAAPIWrongUsage);
        BBA_FLAG_ASYNC_TEST_COMPLETE();
    }];

    BBA_WAIT_FOR_ASYNC_TEST();
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
    BBA_PREPARE_ASYNC_TEST();
    [service resetPasswordForUser:nil completion:^(BOOL success, NSError *error) {
        XCTAssertFalse(success);
        XCTAssertEqualObjects(error.domain, kBBAAuthServiceName);
        XCTAssertEqual(error.code, BBAAPIWrongUsage);

        BBA_FLAG_ASYNC_TEST_COMPLETE();
    }];
    BBA_WAIT_FOR_ASYNC_TEST();
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
    BBA_PREPARE_ASYNC_TEST();

    [service revokeRefreshTokenForUser:nil completion:^(BOOL succes, NSError *error) {
        XCTAssertFalse(succes);
        XCTAssertEqualObjects(error.domain, kBBAAuthServiceName);
        XCTAssertEqual(error.code, BBAAPIWrongUsage);
        BBA_FLAG_ASYNC_TEST_COMPLETE();
    }];

    BBA_WAIT_FOR_ASYNC_TEST();
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


#pragma mark - Helper methods

- (void) prepareDefaultAuthenticatorWithValidUser:(BBAUserDetails **)user
                                        andClient:(BBAClientDetails **)client{

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
    [authenticator setValue:nil forKey:@"currentUser"];
    [authenticator setValue:nil forKey:@"currentClient"];
}

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
