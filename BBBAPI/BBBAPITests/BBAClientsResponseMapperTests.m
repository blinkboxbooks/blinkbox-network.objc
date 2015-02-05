//
//  BBAClientsResponseMapperTests.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 20/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BBAClientsResponseMapper.h"
#import "BBAAuthServiceResponseMappersTestData.h"
#import "BBAClientDetails.h"
#import "BBAAuthenticationServiceConstants.h"
#import "BBAAPIErrors.h"
#import "BBAConnection.h"

@interface BBAClientsResponseMapperTests : XCTestCase
@property (nonatomic, strong) BBAClientsResponseMapper *clientsResponseMapper;
@end

@implementation BBAClientsResponseMapperTests

Class testData;
+ (void) setUp{
    testData = [BBAAuthServiceResponseMappersTestData class];
}

+ (void) tearDown{
    testData = nil;
}

- (void) setUp{
    [super setUp];
    self.clientsResponseMapper = [BBAClientsResponseMapper new];
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

    BBAClientDetails *result = [self.clientsResponseMapper responseFromData:data
                                                                   response:response
                                                                      error:&error];

    XCTAssertTrue([result isKindOfClass:[BBAClientDetails class]]);
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
            withStatusCode:BBAHTTPUnauthorized
                   withURL:URL
            withDictionary:dict];

    data = [NSData new];

    NSError *error;

    BBAClientDetails *result = [self.clientsResponseMapper responseFromData:data
                                                                   response:response
                                                                      error:&error];

    XCTAssertNil(result);
    XCTAssertNotNil(error);
    XCTAssertEqualObjects(error.domain, kBBAAuthServiceName);
    XCTAssertEqual(error.code, BBAAPIErrorUnauthorised);
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
            withStatusCode:BBAHTTPUnauthorized
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
    XCTAssertEqualObjects([error domain], kBBAAuthServiceName);
    XCTAssertEqual(error.code, BBAAPIErrorUnauthorised);
}

- (void) testMappingDeleteClientNotFound{
    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/clients"];
    NSData *data;
    NSURLResponse *response;
    [testData authResponseData:&data
                  response:&response
            withStatusCode:BBAHTTPNotFound
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
    XCTAssertEqualObjects([error domain], kBBAAuthServiceName);
    XCTAssertEqual(error.code, BBAAPIErrorNotFound);
}


@end
