//
//  BBABookmarkResponseTests.m
//  BBBAPI
//
//  Created by Owen Worley on 05/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BBABookmarkResponseMapper.h"
#import "BBABookmarkItem.h"

@implementation BBABookmarkResponseTests

- (void) testInitWithJSONParsesBookmarkListResponseAsBookmarkList{
    BBABookmarkResponse *response;
    response = [[BBABookmarkResponse alloc] initWithJSON:[self bookmarkListResponse]];

    XCTAssertEqual(response.bookmarks.count, 1);
    BBABookmarkItem *item = [response.bookmarks firstObject];
    XCTAssertEqualObjects(item.identifier, self.bookmarkListResponse[@"bookmarks"][0][@"id"]);
    XCTAssertEqualObjects(item.type, self.bookmarkListResponse[@"bookmarks"][0][@"type"]);

}

- (void) testInitWithJSONParsesBookmarkItemResponseAsBookmarkItem{
    BBABookmarkResponse *response;
    response = [[BBABookmarkResponse alloc] initWithJSON:[self bookmarkItemResponse]];

    XCTAssertEqual(response.bookmarks.count, 1);
    BBABookmarkItem *item = [response.bookmarks firstObject];
    XCTAssertEqualObjects(item.identifier, [self bookmarkItemResponse][@"id"]);
    XCTAssertEqualObjects(item.type, [self bookmarkItemResponse][@"type"]);
}

- (void) testInitWithJSONParsesUnknownTypeResponseWithEmptyBookmarkList{
    BBABookmarkResponse *response;
    response = [[BBABookmarkResponse alloc] initWithJSON:[self unknownTypeBookmarkResponse]];

    XCTAssertEqual(response.bookmarks.count, 0);
}


- (NSDictionary *) bookmarkListResponse{
    NSMutableDictionary *response = [NSMutableDictionary new];

    NSDictionary *bookmark = [self bookmarkItemResponse];

    response[@"type"] = @"urn:blinkboxbooks:schema:list";
    response[@"numberOfResults"] =  @1;
    response[@"lastSyncDateTime"]= @"2013-09-06T16:40:34.775Z";
    response[@"bookmarks"] = @[bookmark];

    return response;
}

- (NSDictionary *) bookmarkItemResponse{
    NSMutableDictionary *response = [NSMutableDictionary new];

    response[@"type"] = @"urn:blinkboxbooks:schema:bookmark";
    response[@"guid"] = @"urn:blinkboxbooks:id:bookmark:3";
    response[@"id"] = @(3);
    response[@"bookmarkType"] = @"BOOKMARK";
    response[@"book"] = @"1234567890123";
    response[@"position"] = @"/6/4[chap04ref]!/3:10,/6:18";
    response[@"readingPercentage"] = @(50);
    response[@"deleted"] = @(NO);
    response[@"name"] = @"some optional name";
    response[@"annotation"] = @"some optional annotation";
    response[@"style"] = @"nice optional style";
    response[@"colour"] = @"optional colour red";
    response[@"preview"] = @"optional preview text for BOOKMARK";
    response[@"createdDate"] = @"2013-08-16T10:25:04Z";
    response[@"updatedDate"] = @"2013-08-16T13:37:40Z";
    response[@"createdByClient"] = @"19384";
    response[@"updatedByClient"] = @"19374";
    response[@"links"] = @[
                           @{
                               @"rel" : @"urn:blinkboxbooks:schema:book",
                               @"href" : @"http://qa.mobcastdev.com/service/catalogue/books/1234567890123",
                               @"targetGuid": @"urn:blinkboxbooks:id:book:1234567890123",
                               @"title": @"Book"
                               }
                           ];

    return response;
}

- (NSDictionary *) unknownTypeBookmarkResponse{
    NSMutableDictionary *response = [NSMutableDictionary new];

    response[@"type"] = @"urn:blinkboxbooks:schema:someothertype";

    return response;
}
@end
