//
//  BBACatalogue_IntegrationTests.m
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 09/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BBACatalogueService.h"
#import "BBAResponseMapping.h"
#import "BBABookItem.h"
#import "BBATestMacros.h"
#import "BBATestHelper.h"
#import "BBACatalogueServiceTestHelper.h"

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
    __weak XCTestExpectation *expect = [self expectationWithDescription:@"relatedForFakeISBN"];
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

#pragma mark - Tests (Details)

- (void) testDetailsOfBookReturnFilledBookForGoodISBN{
    
    __weak XCTestExpectation *expect = [self expectationWithDescription:@"detailsForGoodISBN"];
    
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"9780007574360";
    [service getDetailsForBookItems:@[item]
                         completion:^(NSArray *detailItems, NSError *error) {
                             [expect fulfill];
                             XCTAssertEqual(detailItems.count, 1);
                             BBABookItem *result = [detailItems firstObject];
                             XCTAssertEqualObjects(result.identifier, item.identifier);
                             XCTAssertTrue(result.links.count > 0);
                             XCTAssertTrue(result.images.count > 0);
                             XCTAssertNotNil(result.publicationDate);
                             XCTAssertNotNil(result.title);
                             XCTAssertNotNil(result.guid);
                             
                         }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void) testDetailsOfBigArrayOfBooksFetchesDataForAllBooksInCorrectOrder{
    __weak XCTestExpectation *expect = [self expectationWithDescription:@"detailsForBulkISBNs"];
    
    NSArray *sample = [BBACatalogueServiceTestHelper sampleBigRealItems];
    [service getDetailsForBookItems:sample
                         completion:^(NSArray *detailItems, NSError *error) {
                             [expect fulfill];
                             XCTAssertEqualObjects([sample valueForKeyPath:@"identifier"],
                                                   [detailItems valueForKeyPath:@"identifier"]);
                             
                         }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


@end
