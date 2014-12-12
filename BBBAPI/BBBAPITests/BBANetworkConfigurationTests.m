//
//  BBANetworkConfigurationTests.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 04/11/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import "BBANetworkConfiguration.h"
#import "BBADefaultAuthenticator.h"
#import "BBALibraryService.h"
#import "BBAAuthenticationServiceConstants.h"

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

- (void) testSettingSharedAuthenticatorRetains{
    id<BBAAuthenticator> authenticator = (id<BBAAuthenticator>) [NSObject new];
    [configuration setSharedAuthenticator:authenticator];
    XCTAssertEqualObjects([configuration sharedAuthenticator], authenticator);
}

- (void) testSetttingSharedAuthenticatorWhenTryingToSetNil{
    XCTAssertThrows([configuration setSharedAuthenticator:nil]);
}

- (void) testBaseURLForAuthenticationDomainReturnsProperValue{
    XCTAssertEqualObjects([configuration baseURLForDomain:(BBAAPIDomainAuthentication)],
                          [NSURL URLWithString:@"https://auth.blinkboxbooks.com"]);
}

- (void) testBaseURLforRESTDomainReturnsProperValue{
    XCTAssertEqualObjects([configuration baseURLForDomain:(BBAAPIDomainREST)],
                          [NSURL URLWithString:@"https://api.blinkboxbooks.com/service"]);
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

- (void) testDefaultResponseMapperForServices{
    NSArray *expectedMapping = (@[
                                  @{kBBAAuthServiceName : @"BBAAuthResponseMapper"},
                                  @{kBBAAuthServiceTokensName : @"BBATokensResponseMapper"},
                                  @{kBBAAuthServiceClientsName : @"BBAClientsResponseMapper"},
                                  @{BBALibraryServiceName : @"BBALibraryResponseMapper"},
                                  @{BBAStatusResponseServiceName : @"BBAStatusResponseMapper"},
                                  ]);
    
    for (NSDictionary *serviceDict in expectedMapping) {
        NSString *serviceName = [serviceDict.allKeys firstObject];
        id mapper = [configuration newResponseMapperForServiceName:serviceName];
        NSString *mapperClassName = NSStringFromClass([mapper class]);
        XCTAssertEqualObjects(serviceDict[serviceName], mapperClassName);
    }
    
}

- (void) testThrowsOnGettingReponseMapperFromUnknownService{
    XCTAssertThrows([configuration newResponseMapperForServiceName:@"service"]);
}

@end
