//
//  BBBCatalogueServiceTests.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 11/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBACatalogueService.h"
#import "BBABookItem.h"
#import "BBATestHelper.h"
#import "BBAConnection.h"
#import <OCMock.h>
#import "BBASwizzlingHelper.h"

@interface BBACatalogueServiceTests : XCTestCase{
    BBACatalogueService *service;
    id mockConnection;
    IMP oldImplementation;
    id (^initBlock)(id, BBAAPIDomain, NSString *);
    __block NSString *passedRelativeURLString;
    __block BBAAPIDomain passedDomain;
}

@end

@implementation BBACatalogueServiceTests

#pragma mark - Setup / Teardown

- (void)setUp {
    [super setUp];
    service = [BBACatalogueService new];
    
    mockConnection = OCMClassMock([BBAConnection class]);
    
    __weak id weakMockConnection = mockConnection;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
    
    initBlock = ^id(id instance, BBAAPIDomain domain, NSString *relative){
        passedRelativeURLString = relative;
        passedDomain = domain;
        return weakMockConnection;
    };
#pragma clang diagnostic pop
    
    Class class = [BBAConnection class];
    SEL selector = @selector(initWithDomain:relativeURL:);
    Method originalMethod = class_getInstanceMethod(class,selector);
    IMP newImplementation = imp_implementationWithBlock(initBlock);
    oldImplementation = class_replaceMethod(class, selector, newImplementation,
                                            method_getTypeEncoding(originalMethod));
}

- (void)tearDown {
    
    Class class = [BBAConnection class];
    SEL selector = @selector(initWithDomain:relativeURL:);
    Method originalMethod = class_getInstanceMethod(class,selector);
    class_replaceMethod(class, selector, oldImplementation, method_getTypeEncoding(originalMethod));
    initBlock = nil;
    service = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void) testInit{
    XCTAssertNotNil(service);
}


- (void) testSynoposisThrowsOnNoLibraryItem{
    XCTAssertThrows([service getSynopsisForBookItem:nil completion:^(BBABookItem *itemWithSynposis, NSError *error) {}]);
}

- (void) testSynposisThrowsOnLibraryItemWithoutISBN{
    XCTAssertThrows([service getSynopsisForBookItem:[BBABookItem new]
                                         completion:^(BBABookItem *itemWithSynposis, NSError *e) {}]);
}

- (void) testSynopsisThrowsOnNoCompletion{
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"abc";
    XCTAssertThrows([service getSynopsisForBookItem:item
                                         completion:nil]);
}

- (void) testSynopsisDontThrowOnGoodParameters{
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"isbn";
    XCTAssertNoThrow([service getSynopsisForBookItem:item
                                             completion:^(BBABookItem *itemWithSynposis, NSError *error) {}]);
}

- (void) testSynopsisInitsConnectionWithProperDomainAndEndpoint{
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"isbn";
    [service getSynopsisForBookItem:item
                         completion:^(BBABookItem *itemWithSynposis, NSError *error) {}];
    
    XCTAssertEqualObjects(passedRelativeURLString, @"books/");
    XCTAssertEqual(passedDomain, BBAAPIDomainREST);
    
}

- (void) testSynopsisMakesUnauthenticatedConnection{
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"isbn";
    OCMExpect([mockConnection setRequiresAuthentication:NO]);
    [service getSynopsisForBookItem:item
                         completion:^(BBABookItem *itemWithSynposis, NSError *error) {}];
    
}

- (void) testSynopsisReturnsCopyOfLibraryItemWithSynopsisAssigned{
    
    [self expectPerformGETWithDataToReturn:[self sampleSynposisData] error:nil];
    __block BOOL wasCalled = NO;
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"isbn";
    [service getSynopsisForBookItem:item
                         completion:^(BBABookItem *itemWithSynposis, NSError *error) {
                             wasCalled = YES;
                             XCTAssertEqual(itemWithSynposis.synopsis, [self expectedSynopsis]);
                             XCTAssertNil(error);
                         }];
    
    XCTAssertTrue(wasCalled);
    OCMVerifyAll(mockConnection);
}

- (void) testSynposisReturnsNilLibraryItemAndErrorPassedFromConnection{
    NSError *errorToReturn = [NSError errorWithDomain:@"domain"
                                                 code:123
                                             userInfo:nil];
    [self expectPerformGETWithDataToReturn:nil error:errorToReturn];
    __block BOOL wasCalled = NO;
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"isbn";
    [service getSynopsisForBookItem:item
                         completion:^(BBABookItem *itemWithSynposis, NSError *error) {
                             wasCalled = YES;
                             XCTAssertEqual(error.code, 123);
                             XCTAssertEqualObjects(error.domain, @"domain");
                             XCTAssertNil(itemWithSynposis);
                         }];
    
    XCTAssertTrue(wasCalled);
}




- (void) testRelatedThrowsOnNilItem{
    XCTAssertThrows([service getRelatedBooksForBookItem:nil
                                             completion:^(NSArray *i, NSError *e) {}]);
}

- (void) testRelatedThrowsOnItemWithoutISBN{
    XCTAssertThrows([service getRelatedBooksForBookItem:[BBABookItem new]
                                             completion:^(NSArray *i, NSError *e) {}]);
}

- (void) testRelatedThrowsOnNoCompletion{
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"isbn";
    XCTAssertThrows([service getRelatedBooksForBookItem:item
                                             completion:nil]);
}


- (void) testDetailsThrowOnNilArray{
    XCTAssertThrows([service getRelatedBooksForBookItem:nil
                                             completion:^(NSArray *detailItems, NSError *e) {}]);
}

- (void) testDetailsThrowOnArrayWithWrongObjectsIn{
    XCTAssertThrows([service getDetailsForBookItems:@[@"string"]
                                         completion:^(NSArray *detailItems, NSError *e) {}]);
}

- (void) testDetailsThrowsOnArrayWithLibraryItemsWithoutISBNS{
    XCTAssertThrows([service getDetailsForBookItems:@[[BBABookItem new]]
                                         completion:^(NSArray *detailItems, NSError *e) {}]);
}

- (void) testDetailsDoesntThrowsOnArrayWithLibraryItemsWithoutISBNS{
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"isbn";
    XCTAssertNoThrow([service getDetailsForBookItems:@[item]
                                             completion:^(NSArray *detailItems, NSError *e) {}]);
}

- (void) testDetailsThrowsWithoutCompletion{
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"isbn";
    XCTAssertThrows([service getDetailsForBookItems:@[item]
                                            completion:nil]);
}

#pragma mark - Helpers

- (NSData *) sampleSynposisData{
    return [BBATestHelper dataForTestBundleFileNamed:@"sample_synopsis.json"
                                        forTestClass:[self class]];
}

- (NSString *) expectedSynopsis{
    NSData *data = [self sampleSynposisData];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                               options:0
                                                                 error:nil];
    return dictionary[@"text"];
}

- (void) expectPerformGETWithDataToReturn:(id)data error:(NSError *)error{
    void (^completion)(NSInvocation *) = ^(NSInvocation *i){
        
        void (^completion)(id data, NSError *);
        [i getArgument:&completion atIndex:3];
        completion(data, error);
    };
    
    OCMExpect([mockConnection perform:(BBAHTTPMethodGET)
                           completion:[OCMArg isNotNil]]).andDo(completion);
}

@end
