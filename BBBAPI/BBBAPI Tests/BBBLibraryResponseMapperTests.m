//
//  BBBLibraryReponseMapperTests.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 05/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBLibraryResponseMapper.h"
#import "BBBLibraryResponse.h"
#import "BBBAuthenticationService.h"
#import "BBBConnection.h"
#import "BBBTestHelper.h"
#import "BBBLibraryItem.h"
#import "BBBAuthenticationServiceConstants.h"
#import "BBBAPIErrors.h"

/*
 
 Web Service Documentation
 http://jira.blinkbox.local/confluence/display/PT/Library+Service+REST+API+Guide
 
 */

@interface BBBLibraryResponseMapperTests : XCTestCase{
    BBBLibraryResponseMapper *mapper;
}
@end

@implementation BBBLibraryResponseMapperTests

#pragma mark - SetUp/TearDown

- (void) setUp{
    [super setUp];
    mapper = [BBBLibraryResponseMapper new];
}

- (void) tearDown{
    mapper = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void) testInit{
    XCTAssertNotNil(mapper, @"Init should create an object");
}

- (void) testReturningWrongDataErrorIfNoResponseIsGiven{
    NSError *error;
    BBBLibraryResponse *response = [mapper responseFromData:[NSData new]
                                                   response:nil
                                                      error:&error];
    
    XCTAssertNil(response, @"No response should be returned");
    XCTAssertEqual(error.code, BBBResponseMappingErrorUnreadableData, @"should be unreadable data error");
    XCTAssertEqualObjects(error.domain, BBBResponseMappingErrorDomain, @"should be mapping error domain");
}

- (void) testPassingUnauthorizedErrorFromHTTPResponse{
    
    NSError *error;
    NSHTTPURLResponse *URLResponse = [self responseWithHTTPStatus:BBBHTTPUnauthorized];
    
    BBBLibraryResponse *response = [mapper responseFromData:[NSData new]
                                                   response:URLResponse
                                                      error:&error];
    
    XCTAssertNil(response, @"No response should be returned");
    XCTAssertEqual(error.code, BBBAPIErrorUnauthorised, @"unauthorized user");
    XCTAssertEqualObjects(error.domain, kBBBAuthServiceName, @"domain must be equal");
    
}

- (void) testPassingServerInternalErrorFromHTTPResponse{
    NSError *error;
    NSHTTPURLResponse *URLResponse = [self responseWithHTTPStatus:BBBHTTPServerError];
    
    BBBLibraryResponse *response = [mapper responseFromData:[NSData new]
                                                   response:URLResponse
                                                      error:&error];
    
    XCTAssertNil(response, @"No response should be returned");
    XCTAssertEqual(error.code, BBBConnectionErrorServerError, @"server internal error");
    XCTAssertEqualObjects(error.domain, BBBConnectionErrorDomain, @"domain must be equal");
    
}

- (void) testPassingNotFoundErrorFromHTTPResponse{
    NSError *error;
    NSHTTPURLResponse *URLResponse = [self responseWithHTTPStatus:BBBHTTPNotFound];
    
    BBBLibraryResponse *response = [mapper responseFromData:[NSData new]
                                                   response:URLResponse
                                                      error:&error];
    
    XCTAssertNil(response, @"No response should be returned");
    XCTAssertEqual(error.code, BBBConnectionErrorNotFound, @"not found error");
    XCTAssertEqualObjects(error.domain, BBBConnectionErrorDomain, @"domain must be equal");
    
}

- (void) testUndecodableJSONReturnsErrorFromJSONSerialisation{
    NSError *error;
    BBBLibraryResponse *response = [mapper responseFromData:[self unvalidJSONData]
                                                   response:[self responseWithHTTPStatus:BBBHTTPSuccess]
                                                      error:&error];
    XCTAssertNil(response, @"respone should be nil");
    XCTAssertEqualObjects(error.domain, BBBConnectionErrorDomain, @"Should be a connection error");
    XCTAssertEqual(error.code, BBBAPIUnreadableData, @"Unreadable data");

}

- (void) testDecodingValidJSONProducesCorrectNumberOfLibraryItems{
    BBBLibraryResponse *response;
    
    response = [mapper responseFromData:[self validJSONData]
                               response:[self responseWithHTTPStatus:BBBHTTPSuccess]
                                  error:nil];
    
    XCTAssertNotNil(response, @"should produce results");
    XCTAssertEqual([response.changes count], 3, @"There should be 3 changes ind the data");
    XCTAssertNotNil(response.syncDate);
}

- (void) testPassingSingleItemDoesNotThrow{
    NSError *error = nil;
    XCTAssertNoThrow([mapper responseFromData:[self validSingleItemResponse]
                                     response:[self responseWithHTTPStatus:BBBHTTPSuccess]
                                        error:&error],
                     @"Calling mapper witg single item in the data shouldn't throw");
}

- (void) testParsingOfSingleItemData{
    
    BBBLibraryResponse *response;
    
    response = [mapper responseFromData:[self validSingleItemResponse]
                               response:[self responseWithHTTPStatus:BBBHTTPSuccess]
                                  error:nil];
    
    BBBLibraryItem *item = [response.changes firstObject];
    XCTAssertNotNil(item, @"item shouldn't be nil");
    
    XCTAssertEqualObjects(item.isbn, @"9781451658866", @"isbn should be parsed");
    XCTAssertEqualObjects(item.identifier, @"2070+2204", @"id should be parsed");
    XCTAssertEqual(item.purchaseStatus, BBBPurchaseStatusPurchased, @"purchase status should be parsed");
    XCTAssertEqual(item.visibilityStatus, BBBVisiblityStatusCurrent, @"visiblity status incorrect");
    XCTAssertEqual(item.readingStatus, BBBReadingStatusRead, @"reading status incorrect");
    XCTAssertEqual(item.maxNumberOfAuthorisedDevices, 5, @"max number of devies incorrect");
    XCTAssertEqual(item.numberOfAuthorisedDevices, 0, @"number of devices incorrect");
    XCTAssertEqual([item.links count], (NSUInteger)4, @"wrong number of links");
    
}

#pragma mark - Helpers

- (NSData *)unvalidJSONData{
    NSString *string = @"{\"asdas\" : : : }";
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

- (NSData *)validJSONData{
    NSData *data = [BBBTestHelper dataForTestBundleFileNamed:@"libResponse.json"
                                                forTestClass:[self class]];
    return data;
}

- (NSData *)validSingleItemResponse{
    NSData *data = [BBBTestHelper dataForTestBundleFileNamed:@"libResponse_get_single_item.json"
                                                forTestClass:[self class]];
    return data;
}

- (NSHTTPURLResponse *)responseWithHTTPStatus:(NSInteger)status{
    NSHTTPURLResponse *URLResponse = [[NSHTTPURLResponse alloc] initWithURL:nil
                                                                 statusCode:status
                                                                HTTPVersion:BBBHTTPVersion11
                                                               headerFields:nil];
    return URLResponse;
}

@end
