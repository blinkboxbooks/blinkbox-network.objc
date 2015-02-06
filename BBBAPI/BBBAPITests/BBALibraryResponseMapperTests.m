//
//  BBALibraryReponseMapperTests.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 05/08/2014.
 

#import "BBALibraryResponseMapper.h"
#import "BBALibraryResponse.h"
#import "BBAAuthenticationService.h"
#import "BBAConnection.h"
#import "BBATestHelper.h"
#import "BBALibraryItem.h"
#import "BBAAuthenticationServiceConstants.h"
#import "BBAAPIErrors.h"

/*
 
 Web Service Documentation
 http://jira.blinkbox.local/confluence/display/PT/Library+Service+REST+API+Guide
 
 */

@interface BBALibraryResponseMapperTests : XCTestCase{
    BBALibraryResponseMapper *mapper;
}
@end

@implementation BBALibraryResponseMapperTests

#pragma mark - SetUp/TearDown

- (void) setUp{
    [super setUp];
    mapper = [BBALibraryResponseMapper new];
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
    BBALibraryResponse *response = [mapper responseFromData:[NSData new]
                                                   response:nil
                                                      error:&error];
    
    XCTAssertNil(response, @"No response should be returned");
    XCTAssertEqual(error.code, BBAResponseMappingErrorUnreadableData, @"should be unreadable data error");
    XCTAssertEqualObjects(error.domain, BBAResponseMappingErrorDomain, @"should be mapping error domain");
}

- (void) testPassingUnauthorizedErrorFromHTTPResponse{
    
    NSError *error;
    NSHTTPURLResponse *URLResponse = [self responseWithHTTPStatus:BBAHTTPUnauthorized];
    
    BBALibraryResponse *response = [mapper responseFromData:[NSData new]
                                                   response:URLResponse
                                                      error:&error];
    
    XCTAssertNil(response, @"No response should be returned");
    XCTAssertEqual(error.code, BBAAPIErrorUnauthorised, @"unauthorized user");
    XCTAssertEqualObjects(error.domain, kBBAAuthServiceName, @"domain must be equal");
    
}

- (void) testPassingServerInternalErrorFromHTTPResponse{
    NSError *error;
    NSHTTPURLResponse *URLResponse = [self responseWithHTTPStatus:BBAHTTPServerError];
    
    BBALibraryResponse *response = [mapper responseFromData:[NSData new]
                                                   response:URLResponse
                                                      error:&error];
    
    XCTAssertNil(response, @"No response should be returned");
    XCTAssertEqual(error.code, BBAAPIServerError, @"server internal error");
    XCTAssertEqualObjects(error.domain, BBAConnectionErrorDomain, @"domain must be equal");
    
}

- (void) testPassingNotFoundErrorFromHTTPResponse{
    NSError *error;
    NSHTTPURLResponse *URLResponse = [self responseWithHTTPStatus:BBAHTTPNotFound];
    
    BBALibraryResponse *response = [mapper responseFromData:[NSData new]
                                                   response:URLResponse
                                                      error:&error];
    
    XCTAssertNil(response, @"No response should be returned");
    XCTAssertEqual(error.code, BBAAPIErrorNotFound, @"not found error");
    XCTAssertEqualObjects(error.domain, BBAConnectionErrorDomain, @"domain must be equal");
    
}

- (void) testUndecodableJSONReturnsErrorFromJSONSerialisation{
    NSError *error;
    BBALibraryResponse *response = [mapper responseFromData:[self unvalidJSONData]
                                                   response:[self responseWithHTTPStatus:BBAHTTPSuccess]
                                                      error:&error];
    XCTAssertNil(response, @"respone should be nil");
    XCTAssertEqualObjects(error.domain, BBAConnectionErrorDomain, @"Should be a connection error");
    XCTAssertEqual(error.code, BBAAPIUnreadableData, @"Unreadable data");

}

- (void) testDecodingValidJSONProducesCorrectNumberOfLibraryItems{
    BBALibraryResponse *response;
    
    response = [mapper responseFromData:[self validJSONData]
                               response:[self responseWithHTTPStatus:BBAHTTPSuccess]
                                  error:nil];
    
    XCTAssertNotNil(response, @"should produce results");
    XCTAssertEqual([response.changes count], 3, @"There should be 3 changes ind the data");
    XCTAssertNotNil(response.syncDate);
}

- (void) testPassingSingleItemDoesNotThrow{
    NSError *error = nil;
    XCTAssertNoThrow([mapper responseFromData:[self validSingleItemResponse]
                                     response:[self responseWithHTTPStatus:BBAHTTPSuccess]
                                        error:&error],
                     @"Calling mapper witg single item in the data shouldn't throw");
}

- (void) testParsingOfSingleItemData{
    
    BBALibraryResponse *response;
    
    response = [mapper responseFromData:[self validSingleItemResponse]
                               response:[self responseWithHTTPStatus:BBAHTTPSuccess]
                                  error:nil];
    
    BBALibraryItem *item = [response.changes firstObject];
    XCTAssertNotNil(item, @"item shouldn't be nil");
    
    XCTAssertEqualObjects(item.isbn, @"9781451658866", @"isbn should be parsed");
    XCTAssertEqualObjects(item.identifier, @"2070+2204", @"id should be parsed");
    XCTAssertEqual(item.purchaseStatus, BBAPurchaseStatusPurchased, @"purchase status should be parsed");
    XCTAssertEqual(item.visibilityStatus, BBAVisiblityStatusCurrent, @"visiblity status incorrect");
    XCTAssertEqual(item.readingStatus, BBAReadingStatusRead, @"reading status incorrect");
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
    NSData *data = [BBATestHelper dataForTestBundleFileNamed:@"libResponse.json"
                                                forTestClass:[self class]];
    return data;
}

- (NSData *)validSingleItemResponse{
    NSData *data = [BBATestHelper dataForTestBundleFileNamed:@"libResponse_get_single_item.json"
                                                forTestClass:[self class]];
    return data;
}

- (NSHTTPURLResponse *)responseWithHTTPStatus:(NSInteger)status{
    NSHTTPURLResponse *URLResponse = [[NSHTTPURLResponse alloc] initWithURL:nil
                                                                 statusCode:status
                                                                HTTPVersion:@"HTTP/1.1"
                                                               headerFields:nil];
    return URLResponse;
}

@end
