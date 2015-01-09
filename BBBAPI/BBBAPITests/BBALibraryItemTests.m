//
//  BBALibraryItemTests.m
//
//
//  Created by Tomek Kuźma on 16/12/2014.
//
//

#import "BBALibraryItem.h"
#import "BBAItemLink.h"

@interface BBALibraryItemTests : XCTestCase{
    BBALibraryItem *item;
}

@end

@implementation BBALibraryItemTests

#pragma mark - Setup/Teardown

- (void) setUp{
    [super setUp];
    item = [BBALibraryItem new];
    BBAItemLink *link1 = [BBAItemLink new];
    link1.relationship = @"urn:blinkboxbooks:schema:fullmedia";
    link1.address = @"full link";
    BBAItemLink *link2 = [BBAItemLink new];
    link2.relationship = @"urn:blinkboxbooks:schema:mediakey";
    link2.address = @"media key link";
    BBAItemLink *link3 = [BBAItemLink new];
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
