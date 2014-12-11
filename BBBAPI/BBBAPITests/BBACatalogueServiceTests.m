//
//  BBBCatalogueServiceTests.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 11/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBACatalogueService.h"
#import "BBALibraryItem.h"


@interface BBACatalogueServiceTests : XCTestCase{
    BBACatalogueService *service;
}

@end

@implementation BBACatalogueServiceTests

#pragma mark - Setup / Teardown

- (void)setUp {
    [super setUp];
    service = [BBACatalogueService new];
}

- (void)tearDown {
    service = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void) testInit{
    XCTAssertNotNil(service);
}


- (void) testSynoposisThrowsOnNoLibraryItem{
    XCTAssertThrows([service getSynopsisForLibraryItem:nil completion:^(BBALibraryItem *itemWithSynposis, NSError *error) {}]);
}

- (void) testSynposisThrowsOnLibraryItemWithoutISBN{
    XCTAssertThrows([service getSynopsisForLibraryItem:[BBALibraryItem new]
                                            completion:^(BBALibraryItem *itemWithSynposis, NSError *e) {}]);
}

- (void) testSynopsisThrowsOnNoCompletion{
    BBALibraryItem *item = [BBALibraryItem new];
    item.isbn = @"abc";
    XCTAssertThrows([service getSynopsisForLibraryItem:item
                                            completion:nil]);
}


- (void) testRelatedThrowsOnNilItem{
    XCTAssertThrows([service getRelatedBooksForLibraryItem:nil
                                                completion:^(NSArray *i, NSError *e) {}]);
}

- (void) testRelatedThrowsOnItemWithoutISBN{
    XCTAssertThrows([service getRelatedBooksForLibraryItem:[BBALibraryItem new]
                                                completion:^(NSArray *i, NSError *e) {}]);
}

- (void) testRelatedThrowsOnNoCompletion{
    BBALibraryItem *item = [BBALibraryItem new];
    item.isbn = @"isbn";
    XCTAssertThrows([service getRelatedBooksForLibraryItem:item
                                                completion:nil]);
}


- (void) testDetailsThrowOnNilArray{
    XCTAssertThrows([service getDetailsForLibraryItems:nil
                                            completion:^(NSArray *detailItems, NSError *e) {}]);
}

- (void) testDetailsThrowOnArrayWithWrongObjectsIn{
    XCTAssertThrows([service getDetailsForLibraryItems:@[@"string"]
                                            completion:^(NSArray *detailItems, NSError *e) {}]);
}

- (void) testDetailsThrowsOnArrayWithLibraryItemsWithoutISBNS{
    XCTAssertThrows([service getDetailsForLibraryItems:@[[BBALibraryItem new]]
                                            completion:^(NSArray *detailItems, NSError *e) {}]);
}

- (void) testDetailsDoesntThrowsOnArrayWithLibraryItemsWithoutISBNS{
    BBALibraryItem *item = [BBALibraryItem new];
    item.isbn = @"isbn";
    XCTAssertNoThrow([service getDetailsForLibraryItems:@[item]
                                             completion:^(NSArray *detailItems, NSError *e) {}]);
}

- (void) testDetailsThrowsWithoutCompletion{
    BBALibraryItem *item = [BBALibraryItem new];
    item.isbn = @"isbn";
    XCTAssertThrows([service getDetailsForLibraryItems:@[item]
                                            completion:nil]);
}

@end
