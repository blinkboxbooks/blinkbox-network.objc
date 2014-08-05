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

@interface BBBAuthenticationServiceTests : XCTestCase

@end

@implementation BBBAuthenticationServiceTests

BBBAuthenticationService *service;

+ (void)setUp{
    service = [BBBAuthenticationService new];
    NSLog(@"service %@", service);
}

+ (void)tearDown{
    service = nil;
}
#pragma mark - Tests against live (prod) API
- (void) testRegisterUser{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void) testRegisterUserAndClient{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void) testRegisterClient{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void) testValidLoginWithUser{
    BBB_PREPARE_SEMAPHORE();
    BBBUserDetails *user = [self validUserDetails];
    BBBClientDetails *client = [self validClientDetails];

    [service loginUser:user
                client:client
            completion:^(BBBAuthData *data, NSError *error) {
                XCTAssertNotNil(data);
                XCTAssertNil(error);
                BBB_SIGNAL_SEMAPHORE();
    }];

    BBB_WAIT_FOR_SEMAPHORE();
}

- (void) testValidLoginWithUserAndClient{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void) testRefreshAuthData{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void) testResetPassword{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void) testRevokeRefreshToken{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void) testGetAllClients{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void) testDeleteClient{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}


#pragma mark - Helper methods
- (BBBUserDetails *) validUserDetails{
    BBBUserDetails *userDetails = [BBBUserDetails new];
    userDetails.email = @"xctest_books@blinkbox.com";
    userDetails.password = @"xctest_sexytest";
    return userDetails;
}

- (BBBClientDetails *) validClientDetails{
    return nil;
}
@end
