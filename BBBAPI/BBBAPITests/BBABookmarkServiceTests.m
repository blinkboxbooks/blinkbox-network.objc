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
#import "BBAConnection.h"
#import "BBANetworkConfiguration.h"

#import "BBAUserDetails.h"
#import "BBALibraryItem.h"
#import "BBALibraryItem.h"
#import "BBABookmarkItem.h"
#import "BBAAPIErrors.h"

#import "BBAConnectionTestsMocks.h"
#import "BBAMockConnection.h"

#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OCMock/OCMock.h>

@interface BBABookmarkService (Testing)
@property (nonatomic, strong) Class connectionClass;
@end

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
    [[BBAMockConnection mockedConnections] removeAllObjects];
    [super tearDown];
}

#pragma mark - Get Multiple Bookmarks Tests

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
                                XCTAssertNotNil(syncDate);
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
                                XCTAssertEqual(error.code, BBAAPIErrorBadRequest);
                            }];

    BBA_WAIT_FOR_ASYNC_TEST();
}

#pragma mark - Delete Multiple Bookmarks Tests

- (void) testDeleteBookmarksForItemThrowsWithNilUser{
    XCTAssertThrows([service deleteBookmarksForItem:[BBALibraryItem new]
                                          typesMask:BBABookmarkTypeAll
                                               user:nil
                                         completion:^(BOOL success, NSError *error) {

                                         }]);
}

- (void) testDeleteBookmarksForItemThrowsWithNilItem{
    XCTAssertThrows([service deleteBookmarksForItem:nil
                                          typesMask:BBABookmarkTypeAll
                                               user:[BBAUserDetails new]
                                         completion:^(BOOL success, NSError *error) {

                                         }]);
}

- (void) testDeleteBookmarksForItemThrowsWithNilCompletion{
    XCTAssertThrows([service deleteBookmarksForItem:[BBALibraryItem new]
                                          typesMask:BBABookmarkTypeAll
                                               user:[BBAUserDetails new]
                                         completion:nil]);
}

- (void) testDeleteBookmarksSetsCorrectBookmarkTypeParametersForBookmarkTypeBitmaskBookmarkTypeHighlight{
    [service setConnectionClass:[BBAMockConnection class]];

    BBALibraryItem *item = [BBALibraryItem new];
    item.isbn = @"isbn";
    [service deleteBookmarksForItem:item
                          typesMask:BBABookmarkTypeBookmark
                               user:[BBAUserDetails new]
                         completion:^(BOOL success, NSError *error) {

                         }];

    XCTAssertEqual([BBAMockConnection mockedConnections].count, 1);

    BBAMockConnection *mockedConnection;
    mockedConnection = [[BBAMockConnection mockedConnections]firstObject];

    NSArray *passedBookmarkTypeParamater;
    passedBookmarkTypeParamater = [mockedConnection passedArrayParameters][@"bookmarkType"];
    XCTAssertTrue([passedBookmarkTypeParamater containsObject:@"BOOKMARK"]);
    XCTAssertEqual(passedBookmarkTypeParamater.count, 1);
}

- (void) testDeleteBookmarksSetsCorrectBookParamater{
    [service setConnectionClass:[BBAMockConnection class]];

    BBALibraryItem *item = [BBALibraryItem new];
    item.isbn = @"isbn";
    [service deleteBookmarksForItem:item
                          typesMask:BBABookmarkTypeBookmark
                               user:[BBAUserDetails new]
                         completion:^(BOOL success, NSError *error) {

                         }];

    XCTAssertEqual([BBAMockConnection mockedConnections].count, 1);

    BBAMockConnection *mockedConnection;
    mockedConnection = [[BBAMockConnection mockedConnections]firstObject];

    NSArray *passedBookParamater;
    passedBookParamater = [mockedConnection passedParameters][@"book"];

    XCTAssertEqualObjects(passedBookParamater, @"isbn");
}

- (void) testDeleteBookmarksReturnsSuccessWithSuccessfulResponse{
    [self assertDeleteBookmarksSucceeds:YES
                          withErrorCode:0
                         withStatusCode:204
                       responseFromFile:@"delete_bookmarks_success.json"];
}

- (void) testDeleteBookmarksReturnsErrorWithBookmarkNotFoundResponse{
    [self assertDeleteBookmarksSucceeds:NO
                          withErrorCode:BBAAPIErrorNotFound
                         withStatusCode:200
                       responseFromFile:nil];
}

- (void) testDeleteBookmarksReturnsErrorWithForbiddenResponse{
    [self assertDeleteBookmarksSucceeds:NO
                          withErrorCode:BBAAPIErrorForbidden
                         withStatusCode:403
                       responseFromFile:nil];
}

- (void) testDeleteBookmarksReturnsErrorWithBadRequestResponse{
    [self assertDeleteBookmarksSucceeds:NO
                          withErrorCode:BBAAPIErrorBadRequest
                         withStatusCode:400
                       responseFromFile:nil];
}

- (void) testDeleteBookmarksReturnsErrorWithServiceErrorResponse{
    [self assertDeleteBookmarksSucceeds:NO
                          withErrorCode:BBAAPIServerError
                         withStatusCode:500
                       responseFromFile:nil];
}

#pragma mark - Delete Single Bookmark Tests

- (void) testDeleteBookmarkThrowsWithNilBookmarkItem{
    XCTAssertThrows([service deleteBookmark:nil
                                       user:[BBAUserDetails new]
                                 completion:^(BOOL success, NSError *error) {

                                 }]);

}

- (void) testDeleteBookmarkThrowsWithNilCompletion{
    XCTAssertThrows([service deleteBookmark:[BBABookmarkItem new]
                                       user:[BBAUserDetails new]
                                 completion:nil]);

}

- (void) testDeleteBookmarkCreatesConnectionWithItemIdentifierInURL{
    BBABookmarkItem *item = [BBABookmarkItem new];
    item.identifier = @"1";
    [service setConnectionClass:[BBAMockConnection class]];

    [service deleteBookmark:item
                       user:[BBAUserDetails new]
                 completion:^(BOOL success, NSError *error) {

                 }];

    XCTAssertEqual([BBAMockConnection mockedConnections].count, 1);
    BBAMockConnection *mockedConnection = [BBAMockConnection mockedConnections][0];
    NSString *expectedPath = [NSString stringWithFormat:@"/my/bookmarks/%@", item.identifier];
    XCTAssertEqualObjects([mockedConnection.URL path], expectedPath);
}

- (void) testDeleteBookmarkReturnsSuccessGivenSuccessResponse{
    [self assertDeleteBookmarkSucceeds:YES
                         withErrorCode:0
                        withStatusCode:204
                      responseFromFile:nil];
}

- (void) testDeleteBookmarkReturnsErrorGiveNotFoundResponse{
    [self assertDeleteBookmarkSucceeds:NO
                         withErrorCode:BBAAPIErrorNotFound
                        withStatusCode:404
                      responseFromFile:nil];
}

- (void) testDeleteBookmarkReturnsErrorGivenForbiddenResponse{
    [self assertDeleteBookmarkSucceeds:NO
                         withErrorCode:BBAAPIErrorForbidden
                        withStatusCode:403
                      responseFromFile:nil];
}

- (void) testDeleteBookmarkReturnsErrorGivenServerErrorResponse{
    [self assertDeleteBookmarkSucceeds:NO
                         withErrorCode:BBAAPIServerError
                        withStatusCode:500
                      responseFromFile:nil];
}

#pragma mark - Create Bookmark Tests

- (void) testCreateBookmarkThrowsWithNilBookmark{
    XCTAssertThrows([service addBookMark:nil
                                 forItem:[BBALibraryItem new]
                                    user:[BBAUserDetails new]
                              completion:^(BBABookmarkItem *bookmarkItem, NSError *error) {

                              }]);
}

- (void) testCreateBookmarkThrowsWithNilItem{
    XCTAssertThrows([service addBookMark:[BBABookmarkItem new]
                                 forItem:nil
                                    user:[BBAUserDetails new]
                              completion:^(BBABookmarkItem *bookmarkItem, NSError *error) {

                              }]);
}

- (void) testCreateBookmarkThrowsWithNilUser{
    XCTAssertThrows([service addBookMark:[BBABookmarkItem new]
                                 forItem:[BBALibraryItem new]
                                    user:nil
                              completion:^(BBABookmarkItem *bookmarkItem, NSError *error) {

                              }]);
}

- (void) testCreateBookmarkThrowsWithNilCompletion{
    XCTAssertThrows([service addBookMark:[BBABookmarkItem new]
                                 forItem:[BBALibraryItem new]
                                    user:[BBAUserDetails new]
                              completion:nil]);
}

- (void) testCreateBookmarkSetsBookmarkParamater{
    BBABookmarkItem *bookmarkItem = [BBABookmarkItem new];
    bookmarkItem.book = @"isbn";
    bookmarkItem.bookmarkType = @"HIGHLIGHT";
    bookmarkItem.position = @"a cfi";
    bookmarkItem.readingPercentage = @99;

    BBALibraryItem *libraryItem = [BBALibraryItem new];
    libraryItem.isbn = @"isbn";

    [service setConnectionClass:[BBAMockConnection class]];

    [service addBookMark:bookmarkItem
                 forItem:libraryItem
                    user:[BBAUserDetails new]
              completion:^(BBABookmarkItem *bookmarkItem, NSError *error) {

              }];


    XCTAssertEqual([BBAMockConnection mockedConnections].count, 1);
    BBAMockConnection *mockedConnection = [BBAMockConnection mockedConnections][0];
    XCTAssertEqualObjects(mockedConnection.passedParameters[@"book"], bookmarkItem.book);
    XCTAssertEqualObjects(mockedConnection.passedParameters[@"bookmarkType"], bookmarkItem.bookmarkType);
    XCTAssertEqualObjects(mockedConnection.passedParameters[@"position"], bookmarkItem.position);
    XCTAssertEqualObjects(mockedConnection.passedParameters[@"readingPercentage"], [bookmarkItem.readingPercentage stringValue]);
}

- (void) testCreateBookmarkReturnsBookmarkForSuccessfulResponse{
    [self stubBookmarkRequestsEndpoint:@"/my/bookmarks"
                        withStatusCode:201
                      responseFromFile:@"create_bookmark_success.json"];


    BBA_PREPARE_ASYNC_TEST();

    BBABookmarkItem *bookmarkItem = [BBABookmarkItem new];
    bookmarkItem.book = @"isbn";
    bookmarkItem.bookmarkType = @"HIGHLIGHT";
    bookmarkItem.position = @"a cfi";
    bookmarkItem.readingPercentage = @99;

    BBALibraryItem *libraryItem;
    libraryItem = [BBALibraryItem new];
    libraryItem.isbn = @"isbn";

    [service addBookMark:bookmarkItem
                 forItem:libraryItem
                    user:[BBAUserDetails new]
              completion:^(BBABookmarkItem *bookmarkItem, NSError *error) {

                  XCTAssertEqualObjects(bookmarkItem.type, @"urn:blinkboxbooks:schema:bookmark");
                  XCTAssertEqualObjects(bookmarkItem.guid, @"urn:blinkboxbooks:id:bookmark:238630");
                  XCTAssertEqualObjects(bookmarkItem.identifier, @"238630");
                  XCTAssertEqualObjects(bookmarkItem.bookmarkType, @"LAST_READ_POSITION");
                  XCTAssertEqualObjects(bookmarkItem.book, @"9781615930005");
                  XCTAssertEqualObjects(bookmarkItem.position, @"epubcfi(/6/18!/4/44/7:24)");
                  XCTAssertEqualObjects(bookmarkItem.readingPercentage, @79);
                  XCTAssertEqualObjects(bookmarkItem.deleted, @0);
                  XCTAssertNil(error);
                  BBA_FLAG_ASYNC_TEST_COMPLETE();
              }];
    
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testCreateBookmarkReturnsErrorForForbiddenResponse{
    [self assertCreateBookmarkFailsWithErrorCode:BBAAPIErrorForbidden
                                  withStatusCode:403
                                responseFromFile:nil];
}

- (void) testCreateBookmarkReturnsErrorForConflictResponse{
    [self assertCreateBookmarkFailsWithErrorCode:BBAAPIErrorConflict
                                  withStatusCode:409
                                responseFromFile:nil];
}

- (void) testCreateBookmarkReturnsErrorForBadRequestResponse{
    [self assertCreateBookmarkFailsWithErrorCode:BBAAPIErrorBadRequest
                                  withStatusCode:400
                                responseFromFile:nil];
}

- (void) testCreateBookmarkReturnsErrorForServerErrorResponse{
    [self assertCreateBookmarkFailsWithErrorCode:BBAAPIServerError
                                  withStatusCode:500
                                responseFromFile:nil];
}

#pragma mark - Update Bookmark Tests

- (void) testUpdateBookmarkThrowsWithNilItem{
    XCTAssertThrows([service updateBookMark:nil
                                       user:[BBAUserDetails new]
                                 completion:^(BOOL success, NSError *error) {

                                 }]);
}

- (void) testUpdateBookmarkThrowsWithNilUser{
    XCTAssertThrows([service updateBookMark:[BBABookmarkItem new]
                                       user:nil
                                 completion:^(BOOL success, NSError *error) {

                                 }]);
}

- (void) testUpdateBookmarkThrowsWithNilCompletion{
    XCTAssertThrows([service updateBookMark:[BBABookmarkItem new]
                                       user:[BBAUserDetails new]
                                 completion:nil]);
}

- (void) testUpdateBookmarkSetsBookmarkParamater{
    BBABookmarkItem *bookmarkItem = [BBABookmarkItem new];
    bookmarkItem.book = @"isbn";
    bookmarkItem.bookmarkType = @"HIGHLIGHT";
    bookmarkItem.position = @"a cfi";
    bookmarkItem.readingPercentage = @99;
    bookmarkItem.identifier = @"1";

    BBALibraryItem *libraryItem = [BBALibraryItem new];
    libraryItem.isbn = @"isbn";

    [service setConnectionClass:[BBAMockConnection class]];

    [service updateBookMark:bookmarkItem
                    user:[BBAUserDetails new]
              completion:^(BOOL success, NSError *error) {

              }];


    XCTAssertEqual([BBAMockConnection mockedConnections].count, 1);
    BBAMockConnection *mockedConnection = [BBAMockConnection mockedConnections][0];
    XCTAssertEqualObjects(mockedConnection.passedParameters[@"book"], bookmarkItem.book);
    XCTAssertEqualObjects(mockedConnection.passedParameters[@"bookmarkType"], bookmarkItem.bookmarkType);
    XCTAssertEqualObjects(mockedConnection.passedParameters[@"position"], bookmarkItem.position);
    XCTAssertEqualObjects(mockedConnection.passedParameters[@"readingPercentage"], [bookmarkItem.readingPercentage stringValue]);
}

- (void) testUpdateBookmarkReturnsBookmarkItemWithSuccesfulResponse{
    [self stubBookmarkRequestsEndpoint:@"/my/bookmarks/1"
                        withStatusCode:200
                      responseFromFile:@"update_bookmark_success.json"];


    BBA_PREPARE_ASYNC_TEST();

    BBABookmarkItem *bookmarkItem = [BBABookmarkItem new];
    bookmarkItem.book = @"isbn";
    bookmarkItem.bookmarkType = @"HIGHLIGHT";
    bookmarkItem.position = @"a cfi";
    bookmarkItem.readingPercentage = @99;
    bookmarkItem.identifier = @"1";

    BBALibraryItem *libraryItem;
    libraryItem = [BBALibraryItem new];
    libraryItem.isbn = @"isbn";

    [service updateBookMark:bookmarkItem
                       user:[BBAUserDetails new]
                 completion:^(BOOL success, NSError *error) {
                     XCTAssertTrue(success);
                     XCTAssertNil(error);
                     BBA_FLAG_ASYNC_TEST_COMPLETE();
                 }];

    
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testUpdateBookmarkReturnsErrorWithBadRequestResponse{
    [self assertUpdateBookmarkFailsWithErrorCode:BBAAPIErrorBadRequest
                                  withStatusCode:400
                                responseFromFile:nil];
}

- (void) testUpdateBookmarkReturnsErrorWithForbiddenResponse{
    [self assertUpdateBookmarkFailsWithErrorCode:BBAAPIErrorForbidden
                                  withStatusCode:403
                                responseFromFile:nil];
}

- (void) testUpdateBookmarkReturnsErrorWithNotFoundResponse{
    [self assertUpdateBookmarkFailsWithErrorCode:BBAAPIErrorNotFound
                                  withStatusCode:404
                                responseFromFile:nil];
}

- (void) testUpdateBookmarkReturnsErrorWithServerErrorResponse{
    [self assertUpdateBookmarkFailsWithErrorCode:BBAAPIServerError
                                  withStatusCode:500
                                responseFromFile:nil];
}

#pragma mark - Test Helpers

- (void) assertUpdateBookmarkFailsWithErrorCode:(NSInteger)errorCode
                                 withStatusCode:(int)statusCode
                               responseFromFile:(NSString *)responseFile{

    BBABookmarkItem *bookmarkItem = [BBABookmarkItem new];
    bookmarkItem.book = @"isbn";
    bookmarkItem.identifier = @"1";
    bookmarkItem.bookmarkType = @"HIGHLIGHT";
    bookmarkItem.position = @"a cfi";
    bookmarkItem.readingPercentage = @99;
    [self stubBookmarkRequestsEndpoint:@"/my/bookmarks/1"
                        withStatusCode:statusCode
                      responseFromFile:responseFile];

    BBA_PREPARE_ASYNC_TEST();
    [service updateBookMark:bookmarkItem
                       user:[BBAUserDetails new]
                 completion:^(BOOL success, NSError *error) {
                     XCTAssertFalse(success);
                     XCTAssertEqual(error.code, errorCode);
                     BBA_FLAG_ASYNC_TEST_COMPLETE();
                 }];


    BBA_WAIT_FOR_ASYNC_TEST();
    
}

- (void) assertCreateBookmarkFailsWithErrorCode:(NSInteger)errorCode
                                 withStatusCode:(int)statusCode
                               responseFromFile:(NSString *)responseFile{
    BBALibraryItem *libraryItem = [BBALibraryItem new];
    libraryItem.isbn = @"isbn";

    BBABookmarkItem *bookmarkItem = [BBABookmarkItem new];
    bookmarkItem.book = @"isbn";
    bookmarkItem.bookmarkType = @"HIGHLIGHT";
    bookmarkItem.position = @"a cfi";
    bookmarkItem.readingPercentage = @99;
    [self stubBookmarkRequestsEndpoint:@"/my/bookmarks"
                        withStatusCode:statusCode
                      responseFromFile:responseFile];

    BBA_PREPARE_ASYNC_TEST();
    [service addBookMark:bookmarkItem
                 forItem:libraryItem
                    user:[BBAUserDetails new]
              completion:^(BBABookmarkItem *bookmarkItem, NSError *error) {
                  BBA_FLAG_ASYNC_TEST_COMPLETE();
                  XCTAssertNil(bookmarkItem);
                  XCTAssertEqual(error.code, errorCode);
              }];
    BBA_WAIT_FOR_ASYNC_TEST();

}


- (void) assertDeleteBookmarksSucceeds:(BOOL)shouldSucceed
                         withErrorCode:(NSInteger)errorCode
                        withStatusCode:(int)statusCode
                      responseFromFile:(NSString *)responseFile{

    BBALibraryItem *item = [BBALibraryItem new];
    item.isbn = @"isbn";

    [self stubBookmarkRequestsEndpoint:@"/my/bookmarks"
                        withStatusCode:statusCode
                      responseFromFile:responseFile];

    BBA_PREPARE_ASYNC_TEST();
    [service deleteBookmarksForItem:item
                          typesMask:BBABookmarkTypeAll
                               user:[BBAUserDetails new]
                         completion:^(BOOL success, NSError *error) {
                             BBA_FLAG_ASYNC_TEST_COMPLETE();
                             XCTAssertEqual(success, shouldSucceed);
                             XCTAssertEqual(error.code, errorCode);
                         }];
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) assertDeleteBookmarkSucceeds:(BOOL)shouldSucceed
                        withErrorCode:(NSInteger)errorCode
                       withStatusCode:(int)statusCode
                     responseFromFile:(NSString *)responseFile{

    BBABookmarkItem *item = [BBABookmarkItem new];
    item.identifier = @"1";

    [self stubBookmarkRequestsEndpoint:@"/my/bookmarks"
                        withStatusCode:statusCode
                      responseFromFile:responseFile];

    BBA_PREPARE_ASYNC_TEST();
    [service deleteBookmark:item
                       user:[BBAUserDetails new]
                 completion:^(BOOL success, NSError *error) {
                     BBA_FLAG_ASYNC_TEST_COMPLETE();
                     XCTAssertEqual(success, shouldSucceed);
                     XCTAssertEqual(error.code, errorCode);
                 }];
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) stubBookmarkRequestsEndpoint:(NSString *)endpoint
                       withStatusCode:(int)statusCode
                     responseFromFile:(NSString *)responseFile{
    
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        BOOL shouldStub = ([request.URL.path rangeOfString:endpoint].location != NSNotFound);
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