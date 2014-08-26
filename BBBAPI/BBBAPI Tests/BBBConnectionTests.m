//
//  BBBConnectionTests.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 13/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBConnection.h"

extern NSString * BBBNSStringFromBBBContentType(BBBContentType type);

@interface BBBConnectionTests : XCTestCase

@end

@implementation BBBConnectionTests

- (void) testContentTypeStringMappingFunctionWorkForProperTypes{
    XCTAssertEqualObjects(BBBNSStringFromBBBContentType(BBBContentTypeJSON),
                          @"application/vnd.blinkboxbooks.data.v1+json",
                          @"JSON content type name should be equal");
    XCTAssertEqualObjects(BBBNSStringFromBBBContentType(BBBContentTypeURLEncodedForm),
                          @"application/x-www-form-urlencoded",
                          @"JSON content type name should be equal");
}

- (void) testContentTypeStringMappingFunctionThrowsForUnknownType{
    XCTAssertThrows(BBBNSStringFromBBBContentType(-12), @"should throw on wrong encoding type");
}

@end
