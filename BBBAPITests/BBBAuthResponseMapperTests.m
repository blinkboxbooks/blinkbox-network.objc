//
//  BBBAuthResponseMapperTests.m
//  BBBAPI
//
//  Created by Owen Worley on 05/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//
#import "BBBAuthResponseMapper.h"
#import "BBBAuthenticationServiceConstants.h"

@interface BBBAuthResponseMapperTests : XCTestCase
@property (nonatomic, strong) BBBAuthResponseMapper *mapper;
@end

@implementation BBBAuthResponseMapperTests

- (void) setUp{
    [super setUp];
    self.mapper = [BBBAuthResponseMapper new];
}

- (void) tearDown{
    self.mapper = nil;
    [super tearDown];
}

- (void) testMappingValidResponse{

    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;

    [self validAuthResponseData:&data
                       response:&response
                     statusCode:200];


    id result = [self.mapper responseFromData:data
                                     response:response
                                        error:&error];

    XCTAssertNotNil(result);
    XCTAssertNil(error);
}

- (void) testMappingValidResponseWithRedirectStatusCode{

    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;

    [self validAuthResponseData:&data
                       response:&response
                    statusCode:301];


    id result = [self.mapper responseFromData:data
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

    [self authResponseData:&data
                  response:&response
            withStatusCode:200
                   withURL:URL
            withDictionary:authData];


    id result = [self.mapper responseFromData:data
                                     response:response
                                        error:&error];

    XCTAssertNil(result);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects([error domain], kBBBAuthServiceName);
    XCTAssertEqual([error code], BBBAuthServiceErrorCodeCouldNotParseAuthData);
}

- (void) testMappingInvalidGrant{
    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;

    [self invalidGrantResponseData:&data
                          response:&response];


    id result = [self.mapper responseFromData:data
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

    [self invalidClientResponseData:&data
                           response:&response];


    id result = [self.mapper responseFromData:data
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

    [self invalidRequestResponseData:&data
                            response:&response
                              reason:@"client_limit_reached"];


    id result = [self.mapper responseFromData:data
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

    [self invalidRequestResponseData:&data
                            response:&response
                              reason:@"country_geoblocked"];


    id result = [self.mapper responseFromData:data
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

    [self invalidRequestResponseData:&data
                            response:&response
                              reason:@"username_already_taken"];


    id result = [self.mapper responseFromData:data
                                     response:response
                                        error:&error];

    XCTAssertNil(result);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects([error domain], kBBBAuthServiceName);
    XCTAssertEqual([error code], BBBAuthServiceErrorCodeUsernameAlreadyTaken);
}

#pragma mark - Test helper methods
- (NSDictionary *)invalidRequestResponseData:(NSData **)data
                                    response:(NSURLResponse **)response
                                      reason:(NSString*)reason{

    NSDictionary *responseDict = @{@"error" : @"invalid_request",
                                   @"error_reason" : reason};

    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/oauth2/token"];

    [self authResponseData:data
                  response:response
            withStatusCode:400
                   withURL:URL
            withDictionary:responseDict];

    return responseDict;
}

- (NSDictionary *)invalidClientResponseData:(NSData **)data
                                   response:(NSURLResponse **)response{

    NSDictionary *responseDict = @{@"error" : @"invalid_client",
                                   @"error_description" : @"The client id and/or client secret is incorrect."};

    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/oauth2/token"];

    [self authResponseData:data
                  response:response
            withStatusCode:400
                   withURL:URL
            withDictionary:responseDict];

    return responseDict;
}

- (NSDictionary *)invalidGrantResponseData:(NSData **)data
                                  response:(NSURLResponse **)response{

    NSDictionary *responseDict = @{@"error" : @"invalid_grant",
                                   @"error_description" : @"The username and/or password is incorrect."};

    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/oauth2/token"];

    [self authResponseData:data
                  response:response
            withStatusCode:400
                   withURL:URL
            withDictionary:responseDict];

    return responseDict;
}

- (NSDictionary *)validAuthResponseData:(NSData **)data
                               response:(NSURLResponse**)response
                             statusCode:(NSInteger)statusCode{

    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/oauth2/token"];

    NSDictionary *authData = @{@"access_token" : @"a_valid_access_token",
                               @"token_type" : @"bearer",
                               @"expires_in" : @(1800),
                               @"refresh_token" : @"a_valid_refresh_token",
                               @"user_id" : @"urn:blinkbox:zuul:user:3931",
                               @"user_uri" : @"/users/3931",
                               @"user_username" : @"xctest_books@blinkbox.com",
                               @"user_first_name" : @"XCTest",
                               @"user_last_name" : @"Books"};

    [self authResponseData:data
                  response:response
            withStatusCode:statusCode
                   withURL:URL
            withDictionary:authData];

    return authData;
}

- (void) authResponseData:(NSData **)data
                 response:(NSURLResponse**)response
           withStatusCode:(NSInteger)statusCode
                  withURL:(NSURL*)URL
           withDictionary:(NSDictionary*)dict{

    *data = [NSJSONSerialization dataWithJSONObject:dict
                                            options:0
                                              error:nil];

    *response = [[NSHTTPURLResponse alloc] initWithURL:URL
                                            statusCode:statusCode
                                           HTTPVersion:@"HTTP/1.1"
                                          headerFields:[NSDictionary dictionary]];
    
    
    
}
@end
