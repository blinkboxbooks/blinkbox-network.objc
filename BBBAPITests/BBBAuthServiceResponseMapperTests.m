//
//  BBBAuthServiceResponseMapperTests.m
//  BBBAPI
//
//  Created by Owen Worley on 05/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//
#import "BBBAuthResponseMapper.h"
#import "BBBTokensResponseMapper.h"
#import "BBBAuthenticationServiceConstants.h"
#import "BBBClientDetails.h"
#import "BBBAPIErrors.h"
#import "BBBAuthServiceResponseMappersTestData.h"

@interface BBBAuthServiceResponseMapperTests : XCTestCase
@property (nonatomic, strong) BBBAuthResponseMapper *authResponseMapper;
@property (nonatomic, strong) BBBTokensResponseMapper *tokensResponseMapper;
@end


@implementation BBBAuthServiceResponseMapperTests

Class testData;
+ (void) setUp{
    testData = [BBBAuthServiceResponseMappersTestData class];
}

+ (void) tearDown{
    testData = nil;
}

- (void) setUp{
    [super setUp];
    self.authResponseMapper = [BBBAuthResponseMapper new];
    self.tokensResponseMapper = [BBBTokensResponseMapper new];
}

- (void) tearDown{
    self.authResponseMapper = nil;
    self.tokensResponseMapper = nil;
    [super tearDown];
}
#pragma mark - AuthResponseMapperTests
- (void) testMappingValidLoginUserOnlyResponse{

    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;

    [testData validLoginUserAuthResponseData:&data
                                response:&response
                              statusCode:200];


    id result = [self.authResponseMapper responseFromData:data
                                     response:response
                                        error:&error];

    XCTAssertNotNil(result);
    XCTAssertNil(error);
}

- (void) testMappingValidLoginUserAndClientResponse{

    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;

    [testData validLoginUserAndClientAuthResponseData:&data
                                         response:&response
                                       statusCode:200];


    id result = [self.authResponseMapper responseFromData:data
                                     response:response
                                        error:&error];

    XCTAssertNotNil(result);
    XCTAssertNil(error);
}

- (void) testMappingValidUserAndClientRegistrationResponse{
    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;
    [testData registrationUserAndClientAuthResponseData:&data
                                           response:&response
                                         statusCode:200];


    id result = [self.authResponseMapper responseFromData:data
                                     response:response
                                        error:&error];

    XCTAssertNotNil(result);
    XCTAssertNil(error);
}

- (void) testMappingValidLoginUserOnlyResponseWithRedirectStatusCode{

    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;

    [testData validLoginUserAuthResponseData:&data
                                response:&response
                              statusCode:301];


    id result = [self.authResponseMapper responseFromData:data
                                     response:response
                                        error:&error];

    XCTAssertNil(result);
    XCTAssertNotNil(error);
}

- (void) testMappingInvalidResponseWith200StatusCode{

    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/oauth2/token"];

    NSDictionary *authData = @{@"unknown" : @"value"};

    [testData authResponseData:&data
                  response:&response
            withStatusCode:200
                   withURL:URL
            withDictionary:authData];


    id result = [self.authResponseMapper responseFromData:data
                                     response:response
                                        error:&error];

    XCTAssertNil(result);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects([error domain], kBBBAuthServiceName);
    XCTAssertEqual([error code], BBBAuthServiceErrorCodeInvalidResponse);
}

- (void) testMappingValidRefreshTokenWithClientResponse{

    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;

    [testData validRefreshUserAndClientTokenData:&data
                                response:&response
                              statusCode:200];


    id result = [self.authResponseMapper responseFromData:data
                                     response:response
                                        error:&error];

    XCTAssertNotNil(result);
    XCTAssertNil(error);

}

- (void) testMappingValidRefreshTokenWithoutClientResponse{

    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;

    [testData validRefreshUserWithoutClientTokenData:&data
                                        response:&response
                                      statusCode:200];


    id result = [self.authResponseMapper responseFromData:data
                                     response:response
                                        error:&error];

    XCTAssertNotNil(result);
    XCTAssertNil(error);
    
}

- (void) testMappingInvalidGrant{
    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;

    [testData invalidGrantResponseData:&data
                          response:&response];


    id result = [self.authResponseMapper responseFromData:data
                                     response:response
                                        error:&error];

    XCTAssertNil(result);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects([error domain], kBBBAuthServiceName);
    XCTAssertEqual([error code], BBBAuthServiceErrorCodeInvalidGrant);
}

- (void) testMappingInvalidClient{
    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;

    [testData invalidClientResponseData:&data
                           response:&response];


    id result = [self.authResponseMapper responseFromData:data
                                     response:response
                                        error:&error];

    XCTAssertNil(result);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects([error domain], kBBBAuthServiceName);
    XCTAssertEqual([error code], BBBAuthServiceErrorCodeInvalidClient);
}

- (void) testMappingInvalidRequestClientLimitReached{
    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;

    [testData invalidRequestResponseData:&data
                            response:&response
                              reason:@"client_limit_reached"];


    id result = [self.authResponseMapper responseFromData:data
                                     response:response
                                        error:&error];

    XCTAssertNil(result);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects([error domain], kBBBAuthServiceName);
    XCTAssertEqual([error code], BBBAuthServiceErrorCodeClientLimitReached);
}

- (void) testMappingInvalidRequestCountryGeoblocked{
    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;

    [testData invalidRequestResponseData:&data
                            response:&response
                              reason:@"country_geoblocked"];


    id result = [self.authResponseMapper responseFromData:data
                                     response:response
                                        error:&error];

    XCTAssertNil(result);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects([error domain], kBBBAuthServiceName);
    XCTAssertEqual([error code], BBBAuthServiceErrorCodeCountryGeoblocked);
}

- (void) testMappingInvalidRequestUsernameAlreadyTaken{
    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;

    [testData invalidRequestResponseData:&data
                            response:&response
                              reason:@"username_already_taken"];


    id result = [self.authResponseMapper responseFromData:data
                                     response:response
                                        error:&error];

    XCTAssertNil(result);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects([error domain], kBBBAuthServiceName);
    XCTAssertEqual([error code], BBBAuthServiceErrorCodeUsernameAlreadyTaken);
}

@end
