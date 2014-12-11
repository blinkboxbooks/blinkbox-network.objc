//
//  BBACatalogueResponseMapperTests.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 11/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBACatalogueResponseMapper.h"

@interface BBACatalogueResponseMapperTests : XCTestCase{
    BBACatalogueResponseMapper *mapper;
}

@end

@implementation BBACatalogueResponseMapperTests

#pragma mark - Setup/Teardown

- (void) setUp{
    [super setUp];
    mapper = [BBACatalogueResponseMapper new];

}

- (void) tearDown{
    mapper = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void) testInit{
    XCTAssertNotNil(mapper);
}

@end
