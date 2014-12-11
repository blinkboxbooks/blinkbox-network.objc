//
//  BBABookmarkItemTests.m
//  BBBAPI
//
//  Created by Owen Worley on 09/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BBABookmarkItem.h"
#import "BBALinkItem.h"
#import "BBATestHelper.h"

@interface BBABookmarkItemTests : XCTestCase

@end

@implementation BBABookmarkItemTests

- (void) testThrowsWithNilJSON{
    XCTAssertThrows([BBABookmarkItem bookmarkItemWithJSON:nil]);
}

- (void) testBookmarkMapsJSONDictionary{
    BBABookmarkItem *item;
    item = [BBABookmarkItem bookmarkItemWithJSON:[self JSONBookmark]];
    XCTAssertNotNil(item);
    XCTAssertEqualObjects(item.book, @"9781615930005");
    XCTAssertEqualObjects(item.bookmarkType, @"HIGHLIGHT");
    XCTAssertEqualObjects(item.colour, @"test24t");
    XCTAssertEqualObjects(item.createdByClient, @"51764");

    NSInteger timeInterval = [item.createdDate timeIntervalSince1970];
    NSInteger expectedTimeInterval = 1413900197;
    XCTAssertEqual(timeInterval, expectedTimeInterval);

    XCTAssertEqualObjects(item.deleted, @0);
    XCTAssertEqualObjects(item.guid, @"urn:blinkboxbooks:id:bookmark:145548");
    XCTAssertEqualObjects(item.identifier, @"145548");
    XCTAssertEqualObjects(item.position, @"epubcfi(/6/18!/4/44/7:24)");
    XCTAssertEqualObjects(item.readingPercentage, @79);
    XCTAssertEqualObjects(item.type, @"urn:blinkboxbooks:schema:bookmark");

    XCTAssertEqual(item.links.count, 1);
    BBALinkItem *linkItem = [item.links firstObject];
    XCTAssertEqualObjects(linkItem.rel, @"urn:blinkboxbooks:schema:book");
    XCTAssertEqualObjects(linkItem.href, @"https://api.blinkboxbooks.com/service/catalogue/books/9781615930005");
    XCTAssertEqualObjects(linkItem.targetGuid, @"urn:blinkboxbooks:id:book:9781615930005");
    XCTAssertEqualObjects(linkItem.title, @"Book");

}

#pragma mark - Helpers
- (NSDictionary *) JSONBookmark{
    NSString *fileName = @"bookmark_item.json";
    NSString *path;
    path = [[NSBundle bundleForClass:self.class] pathForResource:[fileName stringByDeletingPathExtension]
                                                          ofType:[fileName pathExtension]];


    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                               options:0
                                                                 error:nil];

    return dictionary;

}
@end
