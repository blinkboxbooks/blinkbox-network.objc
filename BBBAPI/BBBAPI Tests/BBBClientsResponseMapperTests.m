//
//  BBBClientsResponseMapperTests.m
//  BBBAPI
//
//  Created by Owen Worley on 20/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BBBClientsResponseMapper.h"
#import "BBBAuthServiceResponseMappersTestData.h"
#import "BBBClientDetails.h"
#import "BBBAuthenticationServiceConstants.h"
#import "BBBAPIErrors.h"

@interface BBBClientsResponseMapperTests : XCTestCase
@property (nonatomic, strong) BBBClientsResponseMapper *clientsResponseMapper;
@end

@implementation BBBClientsResponseMapperTests

Class testData;
+ (void) setUp{
    testData = [BBBAuthServiceResponseMappersTestData class];
}

+ (void) tearDown{
    testData = nil;
}

- (void) setUp{
    [super setUp];
    self.clientsResponseMapper = [BBBClientsResponseMapper new];
}

- (void) tearDown{
    self.clientsResponseMapper = nil;
    [super tearDown];
}

#pragma mark - ClientsResponseMapper Tests
- (void) testMappingValidClientList{

    NSData *data;
    NSURLResponse *response;
    [testData validClientListResponseData:&data
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
    [testData validAddClientInfoResponseData:&data
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
    [testData authResponseData:&data
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
    [testData authResponseData:&data
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
    [testData authResponseData:&data
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
    [testData authResponseData:&data
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


@end
