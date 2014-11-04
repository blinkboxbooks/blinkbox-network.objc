//
//  BBANetworkConfigurationTests.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 04/11/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import "BBANetworkConfiguration.h"
#import "BBADefaultAuthenticator.h"

@interface BBANetworkConfigurationTests : XCTestCase{
    BBANetworkConfiguration *configuration;
}

@end

@implementation BBANetworkConfigurationTests

#pragma mark - Setup/Teardown

- (void) setUp{
    [super setUp];
    configuration = [BBANetworkConfiguration new];

}

- (void) tearDown{
    configuration = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void) testInit{
    XCTAssertNotNil(configuration);
}

- (void) testCreatingDefaultAuthenticator{
    XCTAssertEqualObjects([[configuration sharedAuthenticator] class], [BBADefaultAuthenticator class]);
}

- (void) testSettingSharedAuthenticator{
    id<BBAAuthenticator> authenticator = (id<BBAAuthenticator>) [NSObject new];
    [configuration setSharedAuthenticator:authenticator];
    XCTAssertEqualObjects([configuration sharedAuthenticator], authenticator);
}

- (void) testBaseURLForAuthenticationDomainReturnsProperValue{
    XCTAssertEqualObjects([configuration baseURLForDomain:(BBAAPIDomainAuthentication)],
                          [NSURL URLWithString:@"https://auth.blinkboxbooks.com"]);
}

- (void) testBaseURLforRESTDomainReturnsProperValue{
    XCTAssertEqualObjects([configuration baseURLForDomain:(BBAAPIDomainREST)],
                          [NSURL URLWithString:@"https://api.blinkboxbooks.com"]);
}

- (void) testBaseURLForDomainThrowsOnUnexpectedDomain{
    XCTAssertThrows([configuration baseURLForDomain:12345123]);
}

- (void) testCustomisingBaseURLRemembersNewValue{
    NSURL *url = [NSURL URLWithString:@"http://someaddress.co.uk"];
    [configuration setBaseURL:url forDomain:(BBAAPIDomainREST)];
    XCTAssertEqualObjects(url, [configuration baseURLForDomain:BBAAPIDomainREST]);
}

- (void) testCustmisingBaseURLThrowsForNilParameter{
    XCTAssertThrows([configuration setBaseURL:nil forDomain:(BBAAPIDomainREST)]);
}

@end
