//
//  BBBLibraryServiceTests.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 01/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBLibraryService.h"
#import <XCTest/XCTest.h>
@interface BBBLibraryServiceTests : XCTestCase{
    BBBLibraryService *libraryService;
}
@end

@implementation BBBLibraryServiceTests

- (void)setUp{
    [super setUp];
    libraryService = [BBBLibraryService new];
    
}

- (void)tearDown{
    libraryService = nil;
    [super tearDown];
}

- (void)testInit{
    XCTAssertNotNil(libraryService);
}

@end
