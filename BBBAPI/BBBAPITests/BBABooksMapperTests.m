//
//  BBABooksMapperTests.m
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 12/12/2014.
  

#import "BBABooksMapper.h"
#import "BBABookItem.h"
#import "BBALinkItem.h"
#import "BBAImageItem.h"
#import <NSArray+Functional.h>
#import "BBATestHelper.h"

@interface BBABooksMapperTests : XCTestCase{
    BBABooksMapper *mapper;
}

@end

@implementation BBABooksMapperTests

#pragma mark - Setup/Teardown

- (void) setUp{
    [super setUp];
    mapper = [BBABooksMapper new];
}

- (void) tearDown{
    mapper = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void) testInit{
    XCTAssertNotNil(mapper);
}

- (void) testThrowsOnWrongType{
    XCTAssertThrows([mapper itemFromDictionary:@{@"type" : @"wrong type"}]);
}

- (void) testThrowsOnWrongClass{
    XCTAssertThrows([mapper itemFromDictionary:(NSDictionary *)@[]]);
}

- (void) testThrowsOnNil{
    XCTAssertThrows([mapper itemFromDictionary:nil]);
}

- (void) testReturnsNilOnNil{
    BBA_DISABLE_ASSERTIONS();
    XCTAssertNil([mapper itemFromDictionary:nil]);
    BBA_ENABLE_ASSERTIONS();
}

- (void) testReturnsNilOnWrongType{
    BBA_DISABLE_ASSERTIONS();
    XCTAssertNil([mapper itemFromDictionary:(NSDictionary *)@[]]);
    BBA_ENABLE_ASSERTIONS();
}

- (void) testReturnsNilOnWrongsClass{
    BBA_DISABLE_ASSERTIONS();
    XCTAssertNil([mapper itemFromDictionary:@{@"type" : @"wrong type"}]);
    BBA_ENABLE_ASSERTIONS();
}

- (void) testMappingTitleIdAndGuid{
    BBABookItem *item = [mapper itemFromDictionary:[self sampleBookDicitonary]];
    XCTAssertEqualObjects(item.title, @"Nixland");
    XCTAssertEqualObjects(item.identifier, @"9780988415119");
    XCTAssertEqualObjects(item.guid, @"urn:blinkboxbooks:id:book:9780988415119");
}

- (void) testMappingLinks{
    BBABookItem *item = [mapper itemFromDictionary:[self sampleBookDicitonary]];
    NSArray *linksTitles = [[self sampleBookDicitonary][@"links"] valueForKeyPath:@"title"];
    XCTAssert(linksTitles.count == item.links.count);
    for (NSInteger i = 0; i < item.links.count; i++ ) {
        BBALinkItem *link = item.links[i];
        XCTAssertEqualObjects(link.title, linksTitles[i]);
    }
}

- (void) testMappingImages{
    BBABookItem *item = [mapper itemFromDictionary:[self sampleBookDicitonary]];
    NSArray *imageURLs = [[self sampleBookDicitonary][@"images"] valueForKeyPath:@"src"];
    NSArray *urls = [imageURLs mapUsingBlock:^id(id obj) {
        return [NSURL URLWithString:obj];
    }];
    XCTAssertEqual(urls.count, item.images.count);
    for (NSInteger i = 0; i < item.images.count; i++ ) {
        BBAImageItem *image = item.images[i];
        XCTAssertEqualObjects(image.url, urls[i]);
    }
}

- (void) testMappingSampleEligibility{
    BBABookItem *item = [mapper itemFromDictionary:[self sampleBookDicitonary]];
    XCTAssertTrue(item.sampleEligible);
}

#pragma mark - Helpers

- (NSDictionary *) sampleBookDicitonary{
    NSData *data = [BBATestHelper dataForTestBundleFileNamed:@"book.json"
                                                forTestClass:[self class]];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}


@end
