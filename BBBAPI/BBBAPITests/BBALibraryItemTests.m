//
//  BBALibraryItemTests.m
//
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 16/12/2014.
//
//

#import "BBALibraryItem.h"
#import "BBALinkItem.h"

@interface BBALibraryItemTests : XCTestCase{
    BBALibraryItem *item;
}

@end

@implementation BBALibraryItemTests

#pragma mark - Setup/Teardown

- (void) setUp{
    [super setUp];
    item = [BBALibraryItem new];
    BBALinkItem *link1 = [BBALinkItem new];
    link1.rel = @"urn:blinkboxbooks:schema:fullmedia";
    link1.href = @"full link";
    BBALinkItem *link2 = [BBALinkItem new];
    link2.rel = @"urn:blinkboxbooks:schema:mediakey";
    link2.href = @"media key link";
    BBALinkItem *link3 = [BBALinkItem new];
    link3.rel = @"urn:blinkboxbooks:schema:samplemedia";
    link3.href = @"sample link";
    item.links = @[link1, link2, link3];
}

- (void) tearDown{
    item = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void) testInit{
    XCTAssertNotNil(item);
}


- (void) testSampleMediaURLReturnsCorrectValueIfExistInTheLinksArray{
    XCTAssertEqualObjects(item.sampleMediaURL, @"sample link");
}

- (void) testSampleMediaURLReturnsNilValueIfDoesntExistInTheLinksArray{
    item.links = @[];
    XCTAssertNil(item.sampleMediaURL);
}


- (void) testFullMediaURLReturnsCorrectValueIfExistInTheLinksArray{
    XCTAssertEqualObjects(item.fullMediaURL, @"full link");
}

- (void) testFullMediaURLReturnsNilValueIfDoesntExistInTheLinksArray{
    item.links = @[];
    XCTAssertNil(item.fullMediaURL);
}


- (void) testMediaKeyURLReturnsCorrectValueIfExistInTheLinksArray{
    XCTAssertEqualObjects(item.mediaKeyURL, @"media key link");
}

- (void) testMediaKeyURLReturnsNilValueIfDoesntExistInTheLinksArray{
    item.links = @[];
    XCTAssertNil(item.mediaKeyURL);
}



@end
