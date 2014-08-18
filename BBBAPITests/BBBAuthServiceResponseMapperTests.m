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
#import "BBBClientsResponseMapper.h"
#import "BBBClientDetails.h"
#import "BBBAPIErrors.h"

@interface BBBAuthServiceResponseMapperTests : XCTestCase
@property (nonatomic, strong) BBBAuthResponseMapper *authResponseMapper;
@property (nonatomic, strong) BBBTokensResponseMapper *tokensResponseMapper;
@property (nonatomic, strong) BBBClientsResponseMapper *clientsResponseMapper;
@end

@implementation BBBAuthServiceResponseMapperTests

- (void) setUp{
    [super setUp];
    self.authResponseMapper = [BBBAuthResponseMapper new];
    self.tokensResponseMapper = [BBBTokensResponseMapper new];
    self.clientsResponseMapper = [BBBClientsResponseMapper new];
}

- (void) tearDown{
    self.authResponseMapper = nil;
    self.tokensResponseMapper = nil;
    self.clientsResponseMapper = nil;
    [super tearDown];
}
#pragma mark - AuthResponseMapperTests
- (void) testMappingValidLoginUserOnlyResponse{

    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;

    [self validLoginUserAuthResponseData:&data
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

    [self validLoginUserAndClientAuthResponseData:&data
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
    [self registrationUserAndClientAuthResponseData:&data
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

    [self validLoginUserAuthResponseData:&data
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

    [self authResponseData:&data
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

    [self validRefreshUserAndClientTokenData:&data
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

    [self validRefreshUserWithoutClientTokenData:&data
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

    [self invalidGrantResponseData:&data
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

    [self invalidClientResponseData:&data
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

    [self invalidRequestResponseData:&data
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

    [self invalidRequestResponseData:&data
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

    [self invalidRequestResponseData:&data
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

#pragma mark - TokensResponseMapper tests
- (void) testMappingSuccessfulRevokeResponse{

    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;

    NSInteger statusCode = 200;
    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/tokens/revoke"];
    NSDictionary *dict = @{};
    [self authResponseData:&data
                  response:&response
            withStatusCode:statusCode
                   withURL:URL
            withDictionary:dict];

    //This service sends an empty (but initialised) data
    data = [NSData new];



    NSNumber *result = [self.tokensResponseMapper responseFromData:data
                                     response:response
                                        error:&error];

    XCTAssertTrue([result boolValue]);
    XCTAssertNil(error);
}

- (void) testMappingUnsuccessfulRevokeResponse{

    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;

    NSInteger statusCode = 400;
    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/tokens/revoke"];
    NSDictionary *dict = @{@"error" : @"invalid_grant",
                           @"error_description" : @"The refresh token is invalid"};

    [self authResponseData:&data
                  response:&response
            withStatusCode:statusCode
                   withURL:URL
            withDictionary:dict];




    NSNumber *result = [self.tokensResponseMapper responseFromData:data
                                     response:response
                                        error:&error];

    XCTAssertFalse([result boolValue]);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects([error domain], kBBBAuthServiceName);
    XCTAssertEqual([error code], BBBAuthServiceErrorCodeInvalidGrant);
}

#pragma mark - ClientsResponseMapper Tests
- (void) testMappingValidClientList{

    NSData *data;
    NSURLResponse *response;
    [self validClientListResponseData:&data
                             response:&response];

    NSError *error;

    NSArray *result = [self.clientsResponseMapper responseFromData:data
                                                           response:response
                                                             error:&error];

    XCTAssertTrue([result isKindOfClass:[NSArray class]]);
    XCTAssertNotNil(result);
    XCTAssertNil(error);
}

- (void) testMappingValidAddClientInfoResponse{

    NSData *data;
    NSURLResponse *response;
    [self validAddClientInfoResponseData:&data
                             response:&response];

    NSError *error;

    BBBClientDetails *result = [self.clientsResponseMapper responseFromData:data
                                                          response:response
                                                             error:&error];

    XCTAssertTrue([result isKindOfClass:[BBBClientDetails class]]);
    XCTAssertNotNil(result);
    XCTAssertNil(error);
}

- (void) testClientMappingUnauthorized{

    NSData *data;
    NSURLResponse *response;
    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/clients"];
    NSDictionary *dict = @{};
    [self authResponseData:&data
                  response:&response
            withStatusCode:401
                   withURL:URL
            withDictionary:dict];

    data = [NSData new];

    NSError *error;

    BBBClientDetails *result = [self.clientsResponseMapper responseFromData:data
                                                          response:response
                                                             error:&error];

    XCTAssertNil(result);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, kBBBAuthServiceName);
    XCTAssertEqual(error.code, BBBAPIErrorUnauthorised);
}

- (void) testMappingDeleteClientSuccess{
    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/clients"];
    NSData *data;
    NSURLResponse *response;
    [self authResponseData:&data
                  response:&response
            withStatusCode:200
                   withURL:URL
            withDictionary:@{}];
    data = [NSData data];

    NSError *error = nil;

    NSNumber *result = [self.clientsResponseMapper responseFromData:data
                                        response:response
                                           error:&error];

    XCTAssertTrue([result isKindOfClass:[NSNumber class]]);
    XCTAssertTrue([result boolValue]);
    XCTAssertNil(error);
}

- (void) testMappingDeleteClientUnauthorised{
    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/clients"];
    NSData *data;
    NSURLResponse *response;
    [self authResponseData:&data
                  response:&response
            withStatusCode:401
                   withURL:URL
            withDictionary:@{}];
    data = [NSData data];

    NSError *error = nil;

    NSNumber *result = [self.clientsResponseMapper responseFromData:data
                                                           response:response
                                                              error:&error];

    XCTAssertNil(result);
    XCTAssertFalse([result boolValue]);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects([error domain], kBBBAuthServiceName);
    XCTAssertEqual(error.code, BBBAPIErrorUnauthorised);
}

- (void) testMappingDeleteClientNotFound{
    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/clients"];
    NSData *data;
    NSURLResponse *response;
    [self authResponseData:&data
                  response:&response
            withStatusCode:404
                   withURL:URL
            withDictionary:@{}];
    data = [NSData data];

    NSError *error = nil;

    NSNumber *result = [self.clientsResponseMapper responseFromData:data
                                                           response:response
                                                              error:&error];

    XCTAssertNil(result);
    XCTAssertFalse([result boolValue]);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects([error domain], kBBBAuthServiceName);
    XCTAssertEqual(error.code, BBBAPIErrorNotFound);
}

#pragma mark - Test helper methods
- (NSDictionary *) validClientListResponseData:(NSData **)data
                                      response:(NSURLResponse **)response{

    NSDictionary *dict = @{
                           @"clients": @[
                                   @{
                                       @"client_id": @"urn:blinkbox:zuul:client:2697",
                                       @"client_uri": @"/clients/2697",
                                       @"client_name": @"GT-I9300",
                                       @"client_brand": @"samsung",
                                       @"client_model": @"GT-I9300",
                                       @"client_os": @"Android 18",
                                       @"last_used_date": @"2014-05-23"
                                       },
                                   @{
                                       @"client_id": @"urn:blinkbox:zuul:client:14140",
                                       @"client_uri": @"/clients/14140",
                                       @"client_name": @"Some random device",
                                       @"client_brand": @"Apple",
                                       @"client_model": @"iPad",
                                       @"client_os": @"iPhone OS 7.0.4",
                                       @"last_used_date": @"2014-05-30"
                                       }
                                   ]
                           };
    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/clients"];

    [self authResponseData:data
                  response:response
            withStatusCode:200
                   withURL:URL
            withDictionary:dict];


    return dict;

}

- (NSDictionary *) validAddClientInfoResponseData:(NSData **)data
                                         response:(NSURLResponse **)response{

    NSDictionary *dict = @{
                           @"client_id": @"urn:blinkbox:zuul:client:33100",
                           @"client_uri": @"/clients/33100",
                           @"client_name": @"Joe's iPhone",
                           @"client_brand": @"Apple",
                           @"client_model": @"iPhone 4",
                           @"client_os": @"iOS8",
                           @"last_used_date": @"2014-08-14",
                           @"client_secret": @"zz3XSEuZtpukH6Ie0rfRzycnbzXaO81g6qE1zKKDq0s"
                           };

    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/clients"];

    [self authResponseData:data
                  response:response
            withStatusCode:200
                   withURL:URL
            withDictionary:dict];


    return dict;
    
}

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

- (NSDictionary *)registrationUserAndClientAuthResponseData:(NSData **)data
                                                   response:(NSURLResponse**)response
                                                 statusCode:(NSInteger)statusCode{

    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/oauth2/token"];

    NSDictionary *authData = @{@"access_token": @"eyJraWQiOiJibGlua2JveC9wbGF0L2VuYy9yc2EvMSIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJhbGciOiJSU0EtT0FFUCJ9.ii33jw7lQZGZR1mS41KYPmvmjgKF8euUpSswV0zWBMkb8D5kZnpLEY_HM7oMpFmNr5ONicptW19lMz76P3xfPOPoD-FqDsywn8rTpnkOplJJDsZgSXPDUKubdzCA7JYj_zvnr-nBF5mcYKjErkKeH2hJm7_kRorddF3GSCKQH5dR4G9_qFyi2giCy5pFRn_-2p8l7JIpSuQvgL89mAE60JlJJQcqSFKZ7tosQBlbKe7MqxyyBYF-mQg-XEtsLBmVz_77TSqd4lusIlwZd-Ke110JbKJFPJGtPTMNRmhzEO4uAAVGmYgk1KCL8A4nrLEiORK7crceTIuWZ6wMFiSdvA.MWvgH37fQLhCoFs5.s7_POav6D7YAVCecnVcAdo6Pppmcw_dRzJJ_qvIkEWF3Qle0ksgwFB0I-rc4M-R1EKdmpkT5hnkexKNKmTdY203Fa9yzhkZzQSVRMytUe-P5ycjl0sxRA4RxCX_8aazrK8KFWLF9LJ39mbQjjbtrUdLWxzF4lL0YexzNGGQMC_B0qIP2Fwb0LaBRibOVqnRBiNIioM5bwFisyfY9Vvx2uLgU2wJfz1qnLwikF2xejLD3wVvenleWvJa2Pz19w3mCRzAHVhmBtL_t1vUy4qopbKv3l-lcUQczvHEnTRTAS9KWlpy0KSzQIpZTfmcz8F1SmYYZznRMnKtZST8lBi9gYSKeKqknC66TCuqz4CglLAD-sdIfsn346nArtbF0TgGe-Hv0yeYDvhCyltVz2Q.cAI9GR2KjoDcNelfThZQ1Q",
                               @"token_type":@"bearer",
                               @"expires_in":         @(1800),
                               @"refresh_token":@"pMg2C7XePHo9PcTxdQUlC5_XO5nRAb3vb4NwPU6Op84",
                               @"user_id":@"urn:blinkbox:zuul:user:30901",
                               @"user_uri":@"/users/30901",
                               @"user_username":@"joe@aaabloggs.com",
                               @"user_first_name":@"Joe",
                               @"user_last_name":@"Bloggs",
                               @"client_id":@"urn:blinkbox:zuul:client:32563",
                               @"client_uri":@"/clients/32563",
                               @"client_name":@"Bobs iPhone",
                               @"client_brand":@"Apple",
                               @"client_model":@"iPhone 5s",
                               @"client_os":@"iOS8",
                               @"last_used_date":@"2014-08-12",
                               @"client_secret":@"eXPrpPPuLQxxuxOZRMWmR3z1PnlQVFTnFPkVjzuHh5E"};

    [self authResponseData:data
                  response:response
            withStatusCode:statusCode
                   withURL:URL
            withDictionary:authData];

    return authData;
}
//Data for user login (no client)
- (NSDictionary *)validLoginUserAuthResponseData:(NSData **)data
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

//Data for refresh request WITH client
- (NSDictionary *) validRefreshUserAndClientTokenData:(NSData **)data
                                             response:(NSURLResponse **)response
                                           statusCode:(NSInteger)statusCode{
    //This is the same response as login WITH client, pass through
    return [self validLoginUserAndClientAuthResponseData:data
                                                response:response
                                              statusCode:statusCode];
}

//Data for refresh request WITHOUT client
- (NSDictionary *) validRefreshUserWithoutClientTokenData:(NSData **)data
                                                 response:(NSURLResponse **)response
                                               statusCode:(NSInteger)statusCode{
    //This is the same response as login WITHOUT client, pass through
    return [self validLoginUserAuthResponseData:data
                                       response:response
                                     statusCode:statusCode];
}

//Data for user login WITH client
- (NSDictionary *)validLoginUserAndClientAuthResponseData:(NSData **)data
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
                               @"user_last_name" : @"Books",
                               @"client_id": @"urn:blinkbox:zuul:client:32563",
                               @"client_uri": @"/clients/32563",
                               @"client_name": @"Bobs iPhone",
                               @"client_brand": @"Apple",
                               @"client_model": @"iPhone 5s",
                               @"client_os": @"iOS8",
                               @"last_used_date": @"2014-08-12"};

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
