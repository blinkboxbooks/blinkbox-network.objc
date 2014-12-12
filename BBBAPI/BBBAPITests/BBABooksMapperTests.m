//
//  BBABooksMapperTests.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 12/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBABooksMapper.h"

@interface BBABooksMapperTests : XCTestCase{
    BBABooksMapper *mapper;
}

@end

@implementation BBABooksMapperTests

- (void)setUp {
    [super setUp];
    mapper = [BBABooksMapper new];
}

- (void)tearDown {
    mapper = nil;
    [super tearDown];
}

- (void)testInit{
    XCTAssertNotNil(mapper);
}



@end
