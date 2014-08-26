//
//  BBBSuccessLibraryResponseMapperTests.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 14/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBStatusResponseMapper.h"
#import "BBBAuthenticationService.h"
#import "BBBAPIErrors.h"
#import "BBBAuthenticationServiceConstants.h"
#import "BBBConnection.h"

@interface BBBSuccessLibraryResponseMapperTests : XCTestCase{
    BBBStatusResponseMapper *mapper;
}
@end

@implementation BBBSuccessLibraryResponseMapperTests

#pragma mark - SetUp/TearDown

- (void)setUp{
    mapper = [BBBStatusResponseMapper new];
    [super setUp];
}

- (void)tearDown{
    mapper = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void) testInit{
    XCTAssertNotNil(mapper, @"shouldn't be nil here");
}

- (void) testSuccessCode{
    NSError *error;
    BOOL succes = [[mapper responseFromData:nil
                                   response:[self responseWithHTTPStatus:BBBHTTPSuccess]
                                      error:&error] boolValue];
    
    XCTAssertTrue(succes, @"should return @YES");
    XCTAssertNil(error, @"nothing should be written to the error address");
}

- (void) testForbiddenCode{
    NSError *error;
    BOOL succes = [[mapper responseFromData:nil
                                   response:[self responseWithHTTPStatus:BBBHTTPForbidden]
                                      error:&error] boolValue];
    
    XCTAssertFalse(succes, @"should return @NO");
    XCTAssertEqual(error.code, BBBAPIErrorForbidden, @"Forbidden code");
    XCTAssertEqualObjects(error.domain, BBBConnectionErrorDomain, @"connection domain");
}

- (void) testUnauthorizedCode{
    NSError *error;
    BOOL succes = [[mapper responseFromData:nil
                                   response:[self responseWithHTTPStatus:BBBHTTPUnauthorized]
                                      error:&error] boolValue];
    
    XCTAssertFalse(succes, @"should return @NO");
    XCTAssertEqual(error.code, BBBAPIErrorUnauthorised, @"unauthorized code");
    XCTAssertEqualObjects(error.domain, kBBBAuthServiceName, @"auth domain");
}

- (void) testNotFoundCode{
    NSError *error;
    BOOL succes = [[mapper responseFromData:nil
                                   response:[self responseWithHTTPStatus:BBBHTTPNotFound]
                                      error:&error] boolValue];
    
    XCTAssertFalse(succes, @"should return @NO");
    XCTAssertEqual(error.code, BBBAPIErrorNotFound, @"Not found code");
    XCTAssertEqualObjects(error.domain, BBBConnectionErrorDomain, @"connection domain");
}

- (void) testServerErrorCode{
    NSError *error;
    BOOL succes = [[mapper responseFromData:nil
                                   response:[self responseWithHTTPStatus:BBBHTTPServerError]
                                      error:&error] boolValue];
    
    XCTAssertFalse(succes, @"should return @NO");
    XCTAssertEqual(error.code, BBBAPIServerError, @"server error code");
    XCTAssertEqualObjects(error.domain, BBBConnectionErrorDomain, @"connection domain");
}

- (void) testUnexpectedCodeThrows{
    XCTAssertThrows([mapper responseFromData:nil
                                    response:[self responseWithHTTPStatus:123]
                                       error:nil], @"unexpected http code");
}

#pragma mark - Helpers

- (NSHTTPURLResponse *)responseWithHTTPStatus:(NSInteger)status{
    NSHTTPURLResponse *URLResponse = [[NSHTTPURLResponse alloc] initWithURL:nil
                                                                 statusCode:status
                                                                HTTPVersion:BBBHTTPVersion11
                                                               headerFields:nil];
    return URLResponse;
}

@end
