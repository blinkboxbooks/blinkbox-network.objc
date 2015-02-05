//
//  BBACatalogueResponseMapperTests.m
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 11/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBACatalogueResponseMapper.h"
#import "BBATestHelper.h"
#import "BBABookItem.h"

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

- (void) testThrowsOnNotParsableResponse{
    NSData *data = [@"asd:{]" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertThrows([mapper responseFromData:data response:nil error:nil]);
}

- (void) testReturnsNilOnNotParsableResponse{
    BBA_DISABLE_ASSERTIONS();
    NSData *data = [@"asd:{]" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNil([mapper responseFromData:data response:nil error:nil]);
    BBA_ENABLE_ASSERTIONS();
}

- (void) testReturnsNotFoundErrorWhenResponseIsNotFound{
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:nil
                                                              statusCode:404
                                                             HTTPVersion:@"2.0"
                                                            headerFields:nil];
    NSError *error = nil;
    id data = [mapper responseFromData:[NSData new]
                              response:response
                                 error:&error];
    XCTAssertNil(data);
    BBAAssertErrorHasCodeAndDomain(error,
                                   BBAResponseMappingErrorNotFound,
                                   BBAResponseMappingErrorDomain);
}

- (void) testReturnsNotFoundErrorWhenReponseIsServerError{
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:nil
                                                              statusCode:500
                                                             HTTPVersion:@"2.0"
                                                            headerFields:nil];
    NSError *error = nil;
    id data = [mapper responseFromData:[NSData new]
                              response:response
                                 error:&error];
    XCTAssertNil(data);
    BBAAssertErrorHasCodeAndDomain(error,
                                   BBAResponseMappingErrorNotFound,
                                   BBAResponseMappingErrorDomain);
}

- (void) testThrowsOnWrongDataType{
    NSData *data = [@"(\"1\", \"2\")" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertThrows([mapper responseFromData:data response:nil error:nil]);
}

- (void) testReturnsNilOnWrongDataType{
    BBA_DISABLE_ASSERTIONS();
    NSData *data = [@"(\"1\", \"2\")" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNil([mapper responseFromData:data response:nil error:nil]);
    BBA_ENABLE_ASSERTIONS();
}

- (void) testThrowsOnWrongSchema{
    NSData *data = [@"{\"type\" : \"wrong type\"}" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertThrows([mapper responseFromData:data response:nil error:nil]);
}

- (void) testReturnsNilOnWrongSchema{
    BBA_DISABLE_ASSERTIONS();
    NSData *data = [@"{\"type\" : \"wrong type\"}" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNil([mapper responseFromData:data response:nil error:nil]);
    BBA_ENABLE_ASSERTIONS();
}

- (void) testResponseReturnsBookItemWithSynopsisForSynopsisData{
    BBABookItem *response = [mapper responseFromData:[self sampleSynposisData]
                                            response:nil
                                               error:nil];
    XCTAssert([response isKindOfClass:[BBABookItem class]]);
    XCTAssertEqualObjects(response.synopsis, [self expectedSynopsis]);
    XCTAssertEqualObjects(response.identifier, @"9780857670687");
}

- (void) testResponseReturnsArrayOfBooksForRelatedResponse{
    NSArray *response = [mapper responseFromData:[self sampleRelatedData]
                                        response:nil
                                           error:nil];;
    XCTAssert([response isKindOfClass:[NSArray class]]);
    Class cls = [BBABookItem class];
    BBAAssertArrayHasElementsOfClass(response, cls);
    
}

- (void) testResponseReturnsArrayOfBooksForBooksResponse{
    NSArray *response = [mapper responseFromData:[self sampleBookData]
                                        response:nil
                                           error:nil];;
    XCTAssert([response isKindOfClass:[NSArray class]]);
    Class cls = [BBABookItem class];
    BBAAssertArrayHasElementsOfClass(response, cls);
}

#pragma mark - Helpers

- (NSData *) sampleSynposisData{
    return [BBATestHelper dataForTestBundleFileNamed:@"sample_synopsis.json"
                                        forTestClass:[self class]];
}

- (NSData *) sampleRelatedData{
    return [BBATestHelper dataForTestBundleFileNamed:@"sample_related.json"
                                        forTestClass:[self class]];
}

- (NSData *) sampleBookData{
    return [BBATestHelper dataForTestBundleFileNamed:@"sample_book.json"
                                        forTestClass:[self class]];
}

- (NSString *) expectedSynopsis{
    NSData *data = [self sampleSynposisData];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                               options:0
                                                                 error:nil];
    return dictionary[@"text"];
}

@end
