//
//  BBATokensResponseMapperTests.m
//  BBAAPI
//
//  Created by Owen Worley on 20/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BBATokensResponseMapper.h"
#import "BBAAuthServiceResponseMappersTestData.h"
#import "BBAAuthenticationServiceConstants.h"

@interface BBATokensResponseMapperTests : XCTestCase
@property (nonatomic, strong) BBATokensResponseMapper *tokensResponseMapper;
@end

@implementation BBATokensResponseMapperTests
Class testData;
+ (void) setUp{
    testData = [BBAAuthServiceResponseMappersTestData class];
}

+ (void) tearDown{
    testData = nil;
}

- (void) setUp{
    [super setUp];
    self.tokensResponseMapper = [BBATokensResponseMapper new];
}

- (void) tearDown{
    self.tokensResponseMapper = nil;

    [super tearDown];
}


#pragma mark - TokensResponseMapper tests
- (void) testMappingSuccessfulRevokeResponse{

    NSData *data = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;

    NSInteger statusCode = 200;
    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/tokens/revoke"];
    NSDictionary *dict = @{};
    [testData authResponseData:&data
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

    [testData authResponseData:&data
                      response:&response
                withStatusCode:statusCode
                       withURL:URL
                withDictionary:dict];




    NSNumber *result = [self.tokensResponseMapper responseFromData:data
                                                          response:response
                                                             error:&error];

    XCTAssertFalse([result boolValue]);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects([error domain], kBBAAuthServiceName);
    XCTAssertEqual([error code], BBAAuthServiceErrorCodeInvalidGrant);
}

@end
