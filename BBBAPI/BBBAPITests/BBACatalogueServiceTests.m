//
//  BBBCatalogueServiceTests.m
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 11/12/2014.
  

#import "BBACatalogueService.h"
#import "BBABookItem.h"
#import "BBACatalogueResponseMapper.h"
#import "BBATestHelper.h"
#import "BBAConnection.h"
#import <OCMock.h>
#import <OHHTTPStubs.h>
#import "BBASwizzlingHelper.h"
#import "BBACatalogueServiceTestHelper.h"

@interface NSString (TestHelper)
- (BOOL) bba_containsString:(NSString *)string;
@end
@implementation NSString (TestHelper)
- (BOOL) bba_containsString:(NSString *)string{
    if (!string) {
        return NO;
    }
    return [self rangeOfString:string].location != NSNotFound;
}
@end

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

- (void) setUp{
    [super setUp];
    service = [BBACatalogueService new];
    
    
}

- (void) tearDown{
    service = nil;
    [OHHTTPStubs removeAllStubs];
    [super tearDown];
}

- (void) enableConnectionMock{
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

- (void) disableConnectionMock{
    Class class = [BBAConnection class];
    SEL selector = @selector(initWithDomain:relativeURL:);
    Method originalMethod = class_getInstanceMethod(class,selector);
    class_replaceMethod(class, selector, oldImplementation, method_getTypeEncoding(originalMethod));
    initBlock = nil;
    
}

#pragma mark - Tests

- (void) testInit{
    XCTAssertNotNil(service);
}


- (void) testSynoposisThrowsOnNoLibraryItem{
    [self enableConnectionMock];
    XCTAssertThrows([service getSynopsisForBookItem:nil completion:^(BBABookItem *itemWithSynposis, NSError *error) {}]);
    [self disableConnectionMock];
}

- (void) testSynposisThrowsOnLibraryItemWithoutISBN{
    [self enableConnectionMock];
    XCTAssertThrows([service getSynopsisForBookItem:[BBABookItem new]
                                         completion:^(BBABookItem *itemWithSynposis, NSError *e) {}]);
    [self disableConnectionMock];
}

- (void) testSynopsisThrowsOnNoCompletion{
    [self enableConnectionMock];
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"abc";
    XCTAssertThrows([service getSynopsisForBookItem:item
                                         completion:nil]);
    [self disableConnectionMock];
}

- (void) testSynopsisDontThrowOnGoodParameters{
    [self enableConnectionMock];
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"isbn";
    XCTAssertNoThrow([service getSynopsisForBookItem:item
                                          completion:^(BBABookItem *itemWithSynposis, NSError *error) {}]);
    [self disableConnectionMock];
}

- (void) testSynopsisInitsConnectionWithProperDomainAndEndpoint{
    [self enableConnectionMock];
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"591283912";
    [service getSynopsisForBookItem:item
                         completion:^(BBABookItem *itemWithSynposis, NSError *error) {}];
    
    XCTAssertEqualObjects(passedRelativeURLString, @"catalogue/books/591283912/synopsis");
    XCTAssertEqual(passedDomain, BBAAPIDomainREST);
    [self disableConnectionMock];
}

- (void) testSynopsisMakesUnauthenticatedConnection{
    [self enableConnectionMock];
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"isbn";
    OCMExpect([mockConnection setRequiresAuthentication:NO]);
    [service getSynopsisForBookItem:item
                         completion:^(BBABookItem *itemWithSynposis, NSError *error) {}];
    [self disableConnectionMock];
    OCMVerifyAll(mockConnection);
}

- (void) testSynopsisReturnsCopyOfBookItemWithSynopsisAssigned{
    [self enableConnectionMock];
    BBACatalogueResponseMapper *mapper = [BBACatalogueResponseMapper new];
    BBABookItem *book = [mapper responseFromData:[self sampleSynposisData]
                                        response:nil
                                           error:nil];
    [self expectPerformGETWithDataToReturn:book error:nil callCompletion:YES];
    __block BOOL wasCalled = NO;
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"isbn";
    [service getSynopsisForBookItem:item
                         completion:^(BBABookItem *itemWithSynposis, NSError *error) {
                             wasCalled = YES;
                             XCTAssertEqualObjects(itemWithSynposis.synopsis, [self expectedSynopsis]);
                             XCTAssertNil(error);
                         }];
    
    XCTAssertTrue(wasCalled);
    OCMVerifyAll(mockConnection);
    [self disableConnectionMock];
}

- (void) testSynposisReturnsNilLibraryItemAndErrorPassedFromConnection{
    [self enableConnectionMock];
    NSError *errorToReturn = [NSError errorWithDomain:@"domain"
                                                 code:123
                                             userInfo:nil];
    [self expectPerformGETWithDataToReturn:nil error:errorToReturn callCompletion:YES];
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
    [self disableConnectionMock];
}




- (void) testRelatedThrowsOnNilItem{
    [self enableConnectionMock];
    XCTAssertThrows([service getRelatedBooksForBookItem:nil
                                                  count:10
                                             completion:^(NSArray *i, NSError *e) {}]);
    [self disableConnectionMock];
}

- (void) testRelatedThrowsOnItemWithoutISBN{
    [self enableConnectionMock];
    XCTAssertThrows([service getRelatedBooksForBookItem:[BBABookItem new]
                                                  count:10
                                             completion:^(NSArray *i, NSError *e) {}]);
    [self disableConnectionMock];
}

- (void) testRelatedThrowsOnNoCompletion{
    [self enableConnectionMock];
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"isbn";
    XCTAssertThrows([service getRelatedBooksForBookItem:item
                                                  count:10
                                             completion:nil]);
    [self disableConnectionMock];
}

- (void) testRelatedInitsConnectionWithGoodEndpoint{
    [self enableConnectionMock];
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"591283912";
    [service getRelatedBooksForBookItem:item
                                  count:10
                         completion:^(NSArray *libraryItems, NSError *error) {}];
    
    XCTAssertEqualObjects(passedRelativeURLString, @"catalogue/books/591283912/related");
    XCTAssertEqual(passedDomain, BBAAPIDomainREST);
    [self disableConnectionMock];
}

- (void) testRelatedMakesUnauthenticatedConnection{
    [self enableConnectionMock];
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"isbn";
    OCMExpect([mockConnection setRequiresAuthentication:NO]);
    [service getRelatedBooksForBookItem:item
                                  count:10
                             completion:^(NSArray *libraryItems, NSError *error) {}];
    [self disableConnectionMock];
    OCMVerifyAll(mockConnection);
}

- (void) testRelatedPassesCountToConnection{
    [self enableConnectionMock];
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"isbn";
    OCMExpect([mockConnection addParameterWithKey:[OCMArg isEqual:@"count"]
                                            value:@"10"]);
    [service getRelatedBooksForBookItem:item
                                  count:10
                             completion:^(NSArray *libraryItems, NSError *error) {}];
    [self disableConnectionMock];
    OCMVerifyAll(mockConnection);
}

- (void) testRelatedPassesCount1ToConnectionIfPassed0AsParameter{
    [self enableConnectionMock];
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"isbn";
    OCMExpect([mockConnection addParameterWithKey:[OCMArg isEqual:@"count"]
                                            value:@"1"]);
    [service getRelatedBooksForBookItem:item
                                  count:0
                             completion:^(NSArray *libraryItems, NSError *error) {}];
    [self disableConnectionMock];
    OCMVerifyAll(mockConnection);
}



- (void) testDetailsThrowOnNilArray{
    [self enableConnectionMock];
    XCTAssertThrows([service getRelatedBooksForBookItem:nil
                                                  count:10
                                             completion:^(NSArray *detailItems, NSError *e) {}]);
    [self disableConnectionMock];
}

- (void) testDetailsThrowOnArrayWithWrongObjectsIn{
    [self enableConnectionMock];
    XCTAssertThrows([service getDetailsForBookItems:@[@"string"]
                                         completion:^(NSArray *detailItems, NSError *e) {}]);
    [self disableConnectionMock];
}

- (void) testDetailsThrowsOnArrayWithLibraryItemsWithoutISBNS{
    [self enableConnectionMock];
    XCTAssertThrows([service getDetailsForBookItems:@[[BBABookItem new]]
                                         completion:^(NSArray *detailItems, NSError *e) {}]);
    [self disableConnectionMock];
}

- (void) testDetailsDoesntThrowsOnArrayWithLibraryItemsWithoutISBNS{
    [self enableConnectionMock];
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"isbn";
    XCTAssertNoThrow([service getDetailsForBookItems:@[item]
                                          completion:^(NSArray *detailItems, NSError *e) {}]);
    [self disableConnectionMock];
}

- (void) testDetailsThrowsWithoutCompletion{
    [self enableConnectionMock];
    BBABookItem *item = [BBABookItem new];
    item.identifier = @"isbn";
    XCTAssertThrows([service getDetailsForBookItems:@[item]
                                         completion:nil]);
    [self disableConnectionMock];
}

- (void) testDetailsSendsThreeRequestsFor150BookItems{
    
    NSArray *array = [BBACatalogueServiceTestHelper sampleBigFakeItems];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        BOOL contains = [request.URL.absoluteString bba_containsString:@"catalogue/books?"];
        return contains;
    }
                        withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                            return [self vaildResponseForRequest:request];
                        }];
    
    __weak XCTestExpectation *expect = [self expectationWithDescription:@"send3RequestsFor150Books"];
    [service getDetailsForBookItems:array
                         completion:^(NSArray *detailItems, NSError *error) {
                             [expect fulfill];
                             XCTAssertEqualObjects([array valueForKeyPath:@"identifier"],
                                                   [detailItems valueForKeyPath:@"identifier"]);
                         }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void) testDetailsReturnsErrorWhenAnyRequestFails{
    NSArray *array = [BBACatalogueServiceTestHelper sampleBigFakeItems];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        BOOL contains = [request.URL.absoluteString bba_containsString:@"catalogue/books?"];
        return contains;
    }
                        withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                            return [self unvaildResponseForRequest:request];
                        }];
    
    __weak XCTestExpectation *expect = [self expectationWithDescription:@"send3RequestsFor150Books"];
    [service getDetailsForBookItems:array
                         completion:^(NSArray *detailItems, NSError *error) {
                             [expect fulfill];
                             XCTAssertNil(detailItems);
                             BBAAssertErrorHasCodeAndDomain(error,
                                                            BBAResponseMappingErrorNotFound,
                                                            BBAResponseMappingErrorDomain);
                         }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


#pragma mark - Helpers

- (OHHTTPStubsResponse *) vaildResponseForRequest:(NSURLRequest *)request{
    NSString *pars = [request.URL absoluteString];
    NSInteger location;
    if ([pars bba_containsString:@"id=1&"]) {
        location = 1;
    }
    else if ([pars bba_containsString:@"id=51&"]) {
        location = 51;
    }
    else if ([pars bba_containsString:@"id=101&"]) {
        location = 101;
    }
    
    NSRange range = NSMakeRange(location, 50);
    NSDictionary *obj = [BBACatalogueServiceTestHelper sampleBigFakeResponseForRange:range];
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
    return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
}

- (OHHTTPStubsResponse *) unvaildResponseForRequest:(NSURLRequest *)request{
    NSString *pars = [request.URL absoluteString];
    NSInteger location;
    if ([pars bba_containsString:@"id=1&"]) {
        location = 1;
    }
    else if ([pars bba_containsString:@"id=51&"]) {
        location = 51;
    }
    else if ([pars bba_containsString:@"id=101&"]) {
        return [OHHTTPStubsResponse responseWithData:nil statusCode:404 headers:nil];
    }
    
    NSRange range = NSMakeRange(location, 50);
    NSDictionary *obj = [BBACatalogueServiceTestHelper sampleBigFakeResponseForRange:range];
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
    return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
}

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

- (void) expectPerformGETWithDataToReturn:(id)data error:(NSError *)error callCompletion:(BOOL)call{
    
    void (^completion)(NSInvocation *) = ^(NSInvocation *i){
        
        if (!call) {
            return ;
        }
        
        void (^completion)(id data, NSError *);
        [i getArgument:&completion atIndex:3];
        completion(data, error);
    };
    
    OCMExpect([mockConnection perform:(BBAHTTPMethodGET)
                           completion:[OCMArg isNotNil]]).andDo(completion);
}

@end
