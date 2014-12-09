//
//  BBABookmarkServiceTests.m
//  BBBAPI
//
//  Created by Owen Worley on 03/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BBABookmarkService.h"
#import "BBAUserDetails.h"
#import "BBALibraryItem.h"
#import "BBAConnection.h"
#import "BBANetworkConfiguration.h"
#import "BBAConnectionTestsMocks.h"
#import "BBAMockConnection.h"
#import "BBALibraryItem.h"
#import "BBAAPIErrors.h"

#import <OHHTTPStubs/OHHTTPStubs.h>

@interface BBABookmarkServiceTests : XCTestCase{

    BBABookmarkService *service;
}

@end

@implementation BBABookmarkServiceTests

- (void)setUp {
    [super setUp];
    id mockAuthenticator = [BBAMockAuthenticator new];
    [[BBANetworkConfiguration defaultConfiguration] setSharedAuthenticator:mockAuthenticator];
    service = [BBABookmarkService new];
}

- (void)tearDown {
    service = nil;
    [OHHTTPStubs removeAllStubs];
    [super tearDown];
}

#pragma mark - Tests

- (void) testGetBookmarkChangesThrowsForNilUser{
    XCTAssertThrows([service getBookmarkChangesForItem:[BBALibraryItem new]
                                             afterDate:[NSDate new]
                                             typesMask:BBABookmarkTypeAll
                                                  user:nil
                                            completion:^(NSArray *bookmarkChanges, NSDate *syncDate, NSError *error) {

                                            }]);
}

- (void) testGetBookmarkChangesThrowsForNilCompletion{
    XCTAssertThrows([service getBookmarkChangesForItem:[BBALibraryItem new]
                                             afterDate:[NSDate new]
                                             typesMask:BBABookmarkTypeAll
                                                  user:[BBAUserDetails new]
                                            completion:nil]);
}

- (void) testGetBookmarksSetsDateParameterWhenPassedDateIsNonNil{

    [service setConnectionClass:[BBAMockConnection class]];

    [service getBookmarkChangesForItem:[BBALibraryItem new]
                             afterDate:[NSDate new]
                             typesMask:BBABookmarkTypeAll
                                  user:[BBAUserDetails new]
                            completion:^(NSArray *bookmarkChanges, NSDate *syncDate, NSError *error) {

                            }];

    XCTAssertEqual([BBAMockConnection mockedConnections].count, 1);

    BBAMockConnection *mockedConnection;
    mockedConnection = [[BBAMockConnection mockedConnections]firstObject];

    id passedDateParmater;
    passedDateParmater = [mockedConnection passedParameters][@"lastSyncDateTime"];
    XCTAssertNotNil(passedDateParmater);
}

- (void) testGetBookmarksDoesNotSetDateParameterWhenPassedDateIsNil{
    [service setConnectionClass:[BBAMockConnection class]];

    [service getBookmarkChangesForItem:[BBALibraryItem new]
                             afterDate:nil
                             typesMask:BBABookmarkTypeAll
                                  user:[BBAUserDetails new]
                            completion:^(NSArray *bookmarkChanges, NSDate *syncDate, NSError *error) {

                            }];

    XCTAssertEqual([BBAMockConnection mockedConnections].count, 1);

    BBAMockConnection *mockedConnection;
    mockedConnection = [[BBAMockConnection mockedConnections]firstObject];

    id passedDateParmater;
    passedDateParmater = [mockedConnection passedParameters][@"lastSyncDateTime"];
    XCTAssertNil(passedDateParmater);
}

- (void) testGetBookmarksSetsCorrectBookmarkTypeParametersForBookmarkTypeBitmaskBookmarkTypeAll{
    [service setConnectionClass:[BBAMockConnection class]];

    [service getBookmarkChangesForItem:[BBALibraryItem new]
                             afterDate:nil
                             typesMask:BBABookmarkTypeAll
                                  user:[BBAUserDetails new]
                            completion:^(NSArray *bookmarkChanges, NSDate *syncDate, NSError *error) {

                            }];

    XCTAssertEqual([BBAMockConnection mockedConnections].count, 1);

    BBAMockConnection *mockedConnection;
    mockedConnection = [[BBAMockConnection mockedConnections]firstObject];

    id passedBookmarkTypeParamater;
    passedBookmarkTypeParamater = [mockedConnection passedArrayParameters][@"bookmarkType"];
    XCTAssertTrue([passedBookmarkTypeParamater containsObject:@"BOOKMARK"]);
    XCTAssertTrue([passedBookmarkTypeParamater containsObject:@"HIGLIGHT"]);
    XCTAssertTrue([passedBookmarkTypeParamater containsObject:@"LAST_READ_POSITION"]);
    XCTAssertTrue([passedBookmarkTypeParamater containsObject:@"CROSS_REFERENCE"]);
    XCTAssertTrue([passedBookmarkTypeParamater containsObject:@"NOTE"]);
}

- (void) testGetBookmarksSetsCorrectBookmarkTypeParametersForBookmarkTypeBitmaskBookmarkTypeBookmark{
    [service setConnectionClass:[BBAMockConnection class]];

    [service getBookmarkChangesForItem:[BBALibraryItem new]
                             afterDate:nil
                             typesMask:BBABookmarkTypeBookmark
                                  user:[BBAUserDetails new]
                            completion:^(NSArray *bookmarkChanges, NSDate *syncDate, NSError *error) {

                            }];

    XCTAssertEqual([BBAMockConnection mockedConnections].count, 1);

    BBAMockConnection *mockedConnection;
    mockedConnection = [[BBAMockConnection mockedConnections]firstObject];

    NSArray *passedBookmarkTypeParamater;
    passedBookmarkTypeParamater = [mockedConnection passedArrayParameters][@"bookmarkType"];
    XCTAssertTrue([passedBookmarkTypeParamater containsObject:@"BOOKMARK"]);
    XCTAssertEqual(passedBookmarkTypeParamater.count, 1);
}

- (void) testGetBookmarksSetsCorrectBookmarkTypeParametersForBookmarkTypeBitmaskBookmarkTypeHighlight{
    [service setConnectionClass:[BBAMockConnection class]];

    [service getBookmarkChangesForItem:[BBALibraryItem new]
                             afterDate:nil
                             typesMask:BBABookmarkTypeHighlight
                                  user:[BBAUserDetails new]
                            completion:^(NSArray *bookmarkChanges, NSDate *syncDate, NSError *error) {

                            }];

    XCTAssertEqual([BBAMockConnection mockedConnections].count, 1);

    BBAMockConnection *mockedConnection;
    mockedConnection = [[BBAMockConnection mockedConnections]firstObject];

    NSArray *passedBookmarkTypeParamater;
    passedBookmarkTypeParamater = [mockedConnection passedArrayParameters][@"bookmarkType"];
    XCTAssertTrue([passedBookmarkTypeParamater containsObject:@"HIGHLIGHT"]);
    XCTAssertEqual(passedBookmarkTypeParamater.count, 1);
}

- (void) testGetBookmarksSetsCorrectBookmarkTypeParametersForBookmarkTypeBitmaskBookmarkTypeHighlightAndBookmark{
    [service setConnectionClass:[BBAMockConnection class]];

    [service getBookmarkChangesForItem:[BBALibraryItem new]
                             afterDate:nil
                             typesMask:BBABookmarkTypeHighlight | BBABookmarkTypeBookmark
                                  user:[BBAUserDetails new]
                            completion:^(NSArray *bookmarkChanges, NSDate *syncDate, NSError *error) {

                            }];

    XCTAssertEqual([BBAMockConnection mockedConnections].count, 1);

    BBAMockConnection *mockedConnection;
    mockedConnection = [[BBAMockConnection mockedConnections]firstObject];

    NSArray *passedBookmarkTypeParamater;
    passedBookmarkTypeParamater = [mockedConnection passedArrayParameters][@"bookmarkType"];
    XCTAssertTrue([passedBookmarkTypeParamater containsObject:@"HIGHLIGHT"]);
    XCTAssertTrue([passedBookmarkTypeParamater containsObject:@"BOOKMARK"]);
    XCTAssertEqual(passedBookmarkTypeParamater.count, 2);
}

- (void) testGetBookmarksDoesNotSetBookParameterForNilLibraryItem{
    [service setConnectionClass:[BBAMockConnection class]];

    [service getBookmarkChangesForItem:nil
                             afterDate:nil
                             typesMask:BBABookmarkTypeHighlight | BBABookmarkTypeBookmark
                                  user:[BBAUserDetails new]
                            completion:^(NSArray *bookmarkChanges, NSDate *syncDate, NSError *error) {

                            }];

    BBAMockConnection *mockedConnection;
    mockedConnection = [[BBAMockConnection mockedConnections]firstObject];

    NSArray *passedBookParamater;
    passedBookParamater = [mockedConnection passedArrayParameters][@"book"];
    XCTAssertNil(passedBookParamater);

}

- (void) testGetBookmarksSetsCorrectBookParameterForSpecifiedLibraryItem{
    [service setConnectionClass:[BBAMockConnection class]];

    BBALibraryItem *libraryItem;
    libraryItem = [BBALibraryItem new];
    libraryItem.isbn = @"isbn";

    [service getBookmarkChangesForItem:libraryItem
                             afterDate:nil
                             typesMask:BBABookmarkTypeHighlight | BBABookmarkTypeBookmark
                                  user:[BBAUserDetails new]
                            completion:^(NSArray *bookmarkChanges, NSDate *syncDate, NSError *error) {

                            }];

    BBAMockConnection *mockedConnection;
    mockedConnection = [[BBAMockConnection mockedConnections]firstObject];

    NSArray *passedBookParamater;
    passedBookParamater = [mockedConnection passedParameters][@"book"];
    XCTAssertEqualObjects(@"isbn", passedBookParamater);
}

- (void) testGetBookmarksReturnsBookmarkListGivenSuccessfulFetch{
    [self stubBookmarkRequestsEndpoint:@"/my/bookmarks"
                        withStatusCode:200
                      responseFromFile:@"get_my_bookmarks_success.json"];


    BBA_PREPARE_ASYNC_TEST();
    BBALibraryItem *libraryItem;
    libraryItem = [BBALibraryItem new];
    libraryItem.isbn = @"isbn";

    [service getBookmarkChangesForItem:libraryItem
                             afterDate:nil
                             typesMask:BBABookmarkTypeHighlight | BBABookmarkTypeBookmark
                                  user:[BBAUserDetails new]
                            completion:^(NSArray *bookmarkChanges, NSDate *syncDate, NSError *error) {
                                XCTAssertEqual(bookmarkChanges.count, 1);
                                XCTAssertNil(error);

                                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"GMT"]];
                                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
                                NSString *dateAsString = [formatter stringFromDate:syncDate];
                                XCTAssertEqualObjects(dateAsString, @"2014-12-08 14:24:19 +0000");
                                BBA_FLAG_ASYNC_TEST_COMPLETE();
                            }];
    
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testGetBookmarksReturnsErrorGivenInternalServiceError{
    [self stubBookmarkRequestsEndpoint:@"/my/bookmarks"
                        withStatusCode:500
                      responseFromFile:nil];
    BBA_PREPARE_ASYNC_TEST();

    BBALibraryItem *item = [BBALibraryItem new];
    BBAUserDetails *user = [BBAUserDetails new];
    [service getBookmarkChangesForItem:item
                             afterDate:nil
                             typesMask:BBABookmarkTypeAll
                                  user:user
                            completion:^(NSArray *bookmarkChanges, NSDate *syncDate, NSError *error) {
                                BBA_FLAG_ASYNC_TEST_COMPLETE();
                                XCTAssertNil(bookmarkChanges);
                                XCTAssertNil(syncDate);
                                XCTAssertEqual(error.code, BBAAPIServerError);
                            }];

    BBA_WAIT_FOR_ASYNC_TEST();

}



- (void) testGetBookmarksReturnsErrorGivenBadRequest{
    [self stubBookmarkRequestsEndpoint:@"/my/bookmarks"
                        withStatusCode:400
                      responseFromFile:nil];
    BBA_PREPARE_ASYNC_TEST();

    BBALibraryItem *item = [BBALibraryItem new];
    BBAUserDetails *user = [BBAUserDetails new];
    [service getBookmarkChangesForItem:item
                             afterDate:nil
                             typesMask:BBABookmarkTypeAll
                                  user:user
                            completion:^(NSArray *bookmarkChanges, NSDate *syncDate, NSError *error) {
                                BBA_FLAG_ASYNC_TEST_COMPLETE();
                                XCTAssertNil(bookmarkChanges);
                                XCTAssertNil(syncDate);
                                XCTAssertEqual(error.code, BBAAPIBadRequest);
                            }];

    BBA_WAIT_FOR_ASYNC_TEST();
}

#pragma mark - Test Helpers

- (void) stubBookmarkRequestsEndpoint:(NSString *)endpoint
                       withStatusCode:(int)statusCode
                     responseFromFile:(NSString *)responseFile{


    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        BOOL shouldStub = [request.URL.path isEqualToString:endpoint];
        return shouldStub;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        if (responseFile) {
            NSString* fixture = OHPathForFileInBundle(responseFile,nil);
            return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                    statusCode:statusCode
                                                       headers:@{@"Content-Type":@"application/json"}];
        }
        else {
            return [OHHTTPStubsResponse responseWithData:nil
                                              statusCode:statusCode
                                                 headers:@{@"Content-Type":@"application/json"}];
        }

    }];
}

@end