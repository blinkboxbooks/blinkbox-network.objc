//
//  BBASuccessLibraryResponseMapperTests.m
//  BBAAPI
//
//  Created by Tomek Kuźma on 14/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAStatusResponseMapper.h"
#import "BBAAuthenticationService.h"
#import "BBAAPIErrors.h"
#import "BBAAuthenticationServiceConstants.h"
#import "BBAConnection.h"

@interface BBASuccessLibraryResponseMapperTests : XCTestCase{
    BBAStatusResponseMapper *mapper;
}
@end

@implementation BBASuccessLibraryResponseMapperTests

#pragma mark - SetUp/TearDown

- (void)setUp{
    mapper = [BBAStatusResponseMapper new];
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
                                   response:[self responseWithHTTPStatus:BBAHTTPSuccess]
                                      error:&error] boolValue];
    
    XCTAssertTrue(succes, @"should return @YES");
    XCTAssertNil(error, @"nothing should be written to the error address");
}

- (void) testForbiddenCode{
    NSError *error;
    BOOL succes = [[mapper responseFromData:nil
                                   response:[self responseWithHTTPStatus:BBAHTTPForbidden]
                                      error:&error] boolValue];
    
    XCTAssertFalse(succes, @"should return @NO");
    XCTAssertEqual(error.code, BBAAPIErrorForbidden, @"Forbidden code");
    XCTAssertEqualObjects(error.domain, BBAConnectionErrorDomain, @"connection domain");
}

- (void) testUnauthorizedCode{
    NSError *error;
    BOOL succes = [[mapper responseFromData:nil
                                   response:[self responseWithHTTPStatus:BBAHTTPUnauthorized]
                                      error:&error] boolValue];
    
    XCTAssertFalse(succes, @"should return @NO");
    XCTAssertEqual(error.code, BBAAPIErrorUnauthorised, @"unauthorized code");
    XCTAssertEqualObjects(error.domain, kBBAAuthServiceName, @"auth domain");
}

- (void) testNotFoundCode{
    NSError *error;
    BOOL succes = [[mapper responseFromData:nil
                                   response:[self responseWithHTTPStatus:BBAHTTPNotFound]
                                      error:&error] boolValue];
    
    XCTAssertFalse(succes, @"should return @NO");
    XCTAssertEqual(error.code, BBAAPIErrorNotFound, @"Not found code");
    XCTAssertEqualObjects(error.domain, BBAConnectionErrorDomain, @"connection domain");
}

- (void) testServerErrorCode{
    NSError *error;
    BOOL succes = [[mapper responseFromData:nil
                                   response:[self responseWithHTTPStatus:BBAHTTPServerError]
                                      error:&error] boolValue];
    
    XCTAssertFalse(succes, @"should return @NO");
    XCTAssertEqual(error.code, BBAAPIServerError, @"server error code");
    XCTAssertEqualObjects(error.domain, BBAConnectionErrorDomain, @"connection domain");
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
                                                                HTTPVersion:@"HTTP/1.1"
                                                               headerFields:nil];
    return URLResponse;
}

@end
