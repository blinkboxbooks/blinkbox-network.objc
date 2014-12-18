//
//  BBALibraryItemTests.m
//
//
//  Created by Tomek Kuźma on 16/12/2014.
//
//

#import "BBALibraryItem.h"
#import "BBALibraryItemLink.h"

@interface BBALibraryItemTests : XCTestCase{
    BBALibraryItem *item;
}

@end

@implementation BBALibraryItemTests

#pragma mark - Setup/Teardown

- (void) setUp{
    [super setUp];
    item = [BBALibraryItem new];
    BBALibraryItemLink *link1 = [BBALibraryItemLink new];
    link1.relationship = @"urn:blinkboxbooks:schema:fullmedia";
    link1.address = @"full link";
    BBALibraryItemLink *link2 = [BBALibraryItemLink new];
    link2.relationship = @"urn:blinkboxbooks:schema:mediakey";
    link2.address = @"media key link";
    BBALibraryItemLink *link3 = [BBALibraryItemLink new];
    link3.relationship = @"urn:blinkboxbooks:schema:samplemedia";
    link3.address = @"sample link";
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
