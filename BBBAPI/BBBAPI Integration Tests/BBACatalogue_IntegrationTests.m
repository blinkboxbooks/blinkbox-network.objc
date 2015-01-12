//
//  BBACatalogue_IntegrationTests.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 09/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BBACatalogueService.h"
#import "BBAResponseMapping.h"
#import "BBABookItem.h"
#import "BBATestMacros.h"

@interface BBACatalogue_IntegrationTests : XCTestCase{
    BBACatalogueService *service;
}

@end

@implementation BBACatalogue_IntegrationTests

#pragma mark - Setup/Teardown

- (void) setUp{
    service = [BBACatalogueService new];
    [super setUp];
}

- (void) tearDown{
    service = nil;
    [super tearDown];
}

#pragma mark - Tests (Synopsis)

- (void) testGettingSynopsisForExistingBookReturnsTheSameBookWithNonEmptySynopsis{
    __weak XCTestExpectation *expect = [self expectationWithDescription:@"realBookSynopis"];
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"9780297859406";
    
    [service getSynopsisForBookItem:item
                         completion:^(BBABookItem *itemWithSynposis, NSError *error) {
                             [expect fulfill];
                             XCTAssertEqualObjects(item.identifier, itemWithSynposis.identifier);
                             XCTAssertTrue(itemWithSynposis.synopsis.length > 0);
                             
                         }];
    
    [self waitForExpectationsWithTimeout:5.0
                                 handler:nil];
}

- (void) testGettingSynopsisForNotExistingBookReturnsError{
    __weak XCTestExpectation *expect = [self expectationWithDescription:@"fakeBookSynopis"];
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"97802978592323406";
    
    [service getSynopsisForBookItem:item
                         completion:^(BBABookItem *itemWithSynposis, NSError *error) {
                             [expect fulfill];
                             XCTAssertNil(itemWithSynposis);
                             BBAAssertErrorHasCodeAndDomain(error,
                                                            BBAResponseMappingErrorNotFound,
                                                            BBAResponseMappingErrorDomain);
                         }];
    
    [self waitForExpectationsWithTimeout:5.0
                                 handler:nil];
}

#pragma mark - Tests (Related)

- (void) testRelatedBooksReturnsSomeBooksForProperISBN{
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"9780141345642";
    __weak XCTestExpectation *expect = [self expectationWithDescription:@"relatedForGoodISBN"];
    [service getRelatedBooksForBookItem:item
                                  count:10
                             completion:^(NSArray *libraryItems, NSError *error) {
                                 [expect fulfill];
                                 BBAAssertArrayHasElementsOfClass(libraryItems, [BBABookItem class]);
                                 XCTAssertEqual(libraryItems.count, 10);
                             }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void) testRelatedBookReturnsEmptyArrayForFakeISBN{
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"978014134564212312312";
    __weak XCTestExpectation *expect = [self expectationWithDescription:@"relatedForGoodISBN"];
    [service getRelatedBooksForBookItem:item
                                  count:10
                             completion:^(NSArray *libraryItems, NSError *error) {
                                 [expect fulfill];
                                 XCTAssertNil(libraryItems);
                                 BBAAssertErrorHasCodeAndDomain(error,
                                                                BBAResponseMappingErrorNotFound,
                                                                BBAResponseMappingErrorDomain);

                             }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

@end
