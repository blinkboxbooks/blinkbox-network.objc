//
//  BBAAuthServiceResponseMapperTests.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 05/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//
#import "BBAAuthResponseMapper.h"
#import "BBATokensResponseMapper.h"
#import "BBAAuthenticationServiceConstants.h"
#import "BBAClientDetails.h"
#import "BBAAPIErrors.h"
#import "BBAAuthServiceResponseMappersTestData.h"

@interface BBAAuthServiceResponseMapperTests : XCTestCase
@property (nonatomic, strong) BBAAuthResponseMapper *authResponseMapper;
@property (nonatomic, strong) BBATokensResponseMapper *tokensResponseMapper;
@end


@implementation BBAAuthServiceResponseMapperTests

Class testData;
+ (void) setUp{
    testData = [BBAAuthServiceResponseMappersTestData class];
}

+ (void) tearDown{
    testData = nil;
}

- (void) setUp{
    [super setUp];
    self.authResponseMapper = [BBAAuthResponseMapper new];
    self.tokensResponseMapper = [BBATokensResponseMapper new];
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
    XCTAssertEqualObjects([error domain], kBBAAuthServiceName);
    XCTAssertEqual([error code], BBAAuthServiceErrorCodeInvalidResponse);
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
    XCTAssertEqualObjects([error domain], kBBAAuthServiceName);
    XCTAssertEqual([error code], BBAAuthServiceErrorCodeInvalidGrant);
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
    XCTAssertEqualObjects([error domain], kBBAAuthServiceName);
    XCTAssertEqual([error code], BBAAuthServiceErrorCodeInvalidClient);
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
    XCTAssertEqualObjects([error domain], kBBAAuthServiceName);
    XCTAssertEqual([error code], BBAAuthServiceErrorCodeClientLimitReached);
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
    XCTAssertEqualObjects([error domain], kBBAAuthServiceName);
    XCTAssertEqual([error code], BBAAuthServiceErrorCodeCountryGeoblocked);
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
    XCTAssertEqualObjects([error domain], kBBAAuthServiceName);
    XCTAssertEqual([error code], BBAAuthServiceErrorCodeUsernameAlreadyTaken);
}

@end
