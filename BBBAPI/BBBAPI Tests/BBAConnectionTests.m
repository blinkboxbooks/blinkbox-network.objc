//
//  BBAConnectionTests.m
//  BBAAPI
//
//  Created by Tomek Kuźma on 13/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAConnection.h"

extern NSString * BBANSStringFromBBAContentType(BBAContentType type);

@interface BBAConnectionTests : XCTestCase

@end

@implementation BBAConnectionTests

- (void) testContentTypeStringMappingFunctionWorkForProperTypes{
    XCTAssertEqualObjects(BBANSStringFromBBAContentType(BBAContentTypeJSON),
                          @"application/vnd.blinkboxbooks.data.v1+json",
                          @"JSON content type name should be equal");
    XCTAssertEqualObjects(BBANSStringFromBBAContentType(BBAContentTypeURLEncodedForm),
                          @"application/x-www-form-urlencoded",
                          @"JSON content type name should be equal");
}

- (void) testContentTypeStringMappingFunctionThrowsForUnknownType{
    XCTAssertThrows(BBANSStringFromBBAContentType(-12), @"should throw on wrong encoding type");
}

@end
