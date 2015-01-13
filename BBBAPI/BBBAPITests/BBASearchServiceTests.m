//
//  BBASearchServiceTests.m
//  BBBAPI
//
//  Created by Owen Worley on 09/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BBASearchService.h"
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "BBATestMacros.h"
#import "BBAAPIErrors.h"
#import "BBASearchItem.h"
#import "BBASearchServiceResult.h"
#import "BBASuggestionItem.h"
#import "BBAMockConnection.h"

@interface BBASearchService(Testing)
@property (nonatomic, strong) Class connectionClass;
@end

@interface BBASearchServiceTests : XCTestCase{
    BBASearchService *service;
}
@end

@implementation BBASearchServiceTests

- (void) setUp{
    [super setUp];
    service = [BBASearchService new];
}

- (void) tearDown{
    service = nil;
    [[BBAMockConnection mockedConnections] removeAllObjects];
    [super tearDown];
}

- (void) testInit{
    XCTAssertNotNil(service);
}

- (void) testResultsForSearchTermThrowsForSearchTypeSimiliar{
XCTAssertThrows([service resultsForSearchTerm:@"term"
                                   searchType:BBASearchTypeSimiliar
                                  resultCount:100
                                 resultOffset:0
                                   descending:YES
                                    sortOrder:BBASearchSortOrderRelevance
                                     callback:^(NSUInteger numResults, NSArray *results, NSError *error) {

                                     }]);
}

- (void) testResultsForSearchTermThrowsForUnknownSearchType{
    XCTAssertThrows([service resultsForSearchTerm:@"term"
                                       searchType:666
                                      resultCount:100
                                     resultOffset:0
                                       descending:YES
                                        sortOrder:BBASearchSortOrderRelevance
                                         callback:^(NSUInteger numResults, NSArray *results, NSError *error) {

                                         }]);
}

- (void) testSearchSuggestionsForTermThrowsWithNilSearchTerm{
    XCTAssertThrows([service searchSuggestionsForTerm:nil
                                           completion:^(NSArray *results, NSError *error) {

    }]);
}

- (void) testSearchSuggestionsForTermThrowsWithNilCompletion{
    XCTAssertThrows([service searchSuggestionsForTerm:@"term"
                                           completion:nil]);
}

- (void) testSearchSuggestionsReturnsExpectedSuggestionsForTerm{

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        BOOL shouldStub = ([request.URL.path rangeOfString:@"search/suggestions"].location != NSNotFound);
        return shouldStub;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFileInBundle(@"SuggestionsResponse.json",nil);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200
                                                   headers:@{@"Content-Type":@"application/json"}];
    }];


    BBA_PREPARE_ASYNC_TEST();

    [service searchSuggestionsForTerm:@"italo"
                           completion:^(NSArray *results, NSError *error) {

                               XCTAssertEqual(results.count, 2);
                               XCTAssertNil(error);
                               BBASuggestionItem *firstSuggestion;
                               firstSuggestion = results[0];
                               XCTAssertEqualObjects(firstSuggestion.identifier, @"9781136730597");
                               XCTAssertEqualObjects(firstSuggestion.title, @"Italo Calvino's Architecture of Lightness");
                               XCTAssertEqualObjects(firstSuggestion.type, @"urn:blinkboxbooks:schema:suggestion:book");
                               XCTAssertEqual(firstSuggestion.authors.count, 1);
                               XCTAssertEqualObjects(firstSuggestion.authors[0], @"Letizia Modena");

                               BBASuggestionItem *secondSuggestion;
                               secondSuggestion = results[1];
                               XCTAssertEqualObjects(secondSuggestion.identifier, @"9d7f706e68b16daafe4ea499fda450c32417421a");
                               XCTAssertEqualObjects(secondSuggestion.title, @"Italo Calvino");
                               XCTAssertEqualObjects(secondSuggestion.type, @"urn:blinkboxbooks:schema:suggestion:contributor");
                               XCTAssertNil(secondSuggestion.authors);
                               BBA_FLAG_ASYNC_TEST_COMPLETE();
                           }];
    
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testSearchSuggestionsReturnsCorrectErrorForStatusCode400{

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        BOOL shouldStub = ([request.URL.path rangeOfString:@"search/suggestions"].location != NSNotFound);
        return shouldStub;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:nil
                                                statusCode:400
                                                   headers:@{@"Content-Type":@"application/json"}];
    }];


    BBA_PREPARE_ASYNC_TEST();

    [service searchSuggestionsForTerm:@"italo"
                           completion:^(NSArray *results, NSError *error) {

                               BBBAssertErrorHasCodeAndDomain(error,
                                                              BBAAPIErrorBadRequest,
                                                              BBASearchServiceErrorDomain);

                               BBA_FLAG_ASYNC_TEST_COMPLETE();
                           }];
    
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testSearchSuggestionsReturnsCorrectErrorForStatusCode500{

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        BOOL shouldStub = ([request.URL.path rangeOfString:@"search/suggestions"].location != NSNotFound);
        return shouldStub;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:nil
                                          statusCode:500
                                             headers:@{@"Content-Type":@"application/json"}];
    }];


    BBA_PREPARE_ASYNC_TEST();

    [service searchSuggestionsForTerm:@"italo"
                           completion:^(NSArray *results, NSError *error) {
                               XCTAssertNil(results);
                               BBBAssertErrorHasCodeAndDomain(error,
                                                              BBAAPIServerError,
                                                              BBASearchServiceErrorDomain);
                               BBA_FLAG_ASYNC_TEST_COMPLETE();
                           }];

    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testResultsForSearchTermThrowsWithNilSearchTerm{
XCTAssertThrows([service resultsForSearchTerm:nil
                                   searchType:BBASearchTypeBooks
                                  resultCount:100
                                 resultOffset:0
                                   descending:YES
                                    sortOrder:BBASearchSortOrderRelevance
                                     callback:^(NSUInteger numResults, NSArray *results, NSError *error) {

                                     }]);
}

- (void) testResultsForSearchTermThrowsWithNilCompletion{
    XCTAssertThrows([service resultsForSearchTerm:@"term"
                                       searchType:BBASearchTypeBooks
                                      resultCount:100
                                     resultOffset:0
                                       descending:YES
                                        sortOrder:BBASearchSortOrderRelevance
                                         callback:nil]);
}

- (void) testResultsForSearchTermReturnsExpectedResultsForTerm{

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        BOOL shouldStub = ([request.URL.path rangeOfString:@"search/books"].location != NSNotFound);
        return shouldStub;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* fixture = OHPathForFileInBundle(@"BookSearchResponse.json",nil);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:200
                                                   headers:@{@"Content-Type":@"application/json"}];
    }];


    BBA_PREPARE_ASYNC_TEST();

    [service resultsForSearchTerm:@"dickens"
                       searchType:BBASearchTypeBooks
                      resultCount:200
                     resultOffset:0
                       descending:YES
                        sortOrder:BBASearchSortOrderRelevance
                         callback:^(NSUInteger numResults, NSArray *results, NSError *error) {
                             XCTAssertEqual(numResults, 310);
                             XCTAssertEqual(results.count, 2);

                             BBASearchItem *firstBook = results[0];
                             XCTAssertEqualObjects(firstBook.identifier, @"9780141974132");
                             XCTAssertEqualObjects(firstBook.title, @"Nicholas Nickleby");
                             XCTAssertEqual(firstBook.authors.count, 1);
                             XCTAssertEqualObjects(firstBook.authors[0], @"Charles Dickens");

                             BBASearchItem *secondBook = results[1];
                             XCTAssertEqualObjects(secondBook.identifier, @"9780141974149");
                             XCTAssertEqualObjects(secondBook.title, @"Our Mutual Friend");
                             XCTAssertEqual(secondBook.authors.count, 1);
                             XCTAssertEqualObjects(secondBook.authors[0], @"Charles Dickens");
                             
                             BBA_FLAG_ASYNC_TEST_COMPLETE();
                         }];

    
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testResultsForSearchTermReturnsCorrectErrorForStatusCode400{

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        BOOL shouldStub = ([request.URL.path rangeOfString:@"search/books"].location != NSNotFound);
        return shouldStub;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:nil
                                          statusCode:400
                                             headers:@{@"Content-Type":@"application/json"}];
    }];


    BBA_PREPARE_ASYNC_TEST();

    [service resultsForSearchTerm:@"dickens"
                       searchType:BBASearchTypeBooks
                      resultCount:100
                     resultOffset:0
                       descending:YES
                        sortOrder:BBASearchSortOrderRelevance
                         callback:^(NSUInteger numResults, NSArray *results, NSError *error) {
                             XCTAssertNil(results);

                             BBBAssertErrorHasCodeAndDomain(error,
                                                            BBAAPIErrorBadRequest,
                                                            BBASearchServiceErrorDomain);

                             BBA_FLAG_ASYNC_TEST_COMPLETE();
                         }];


    BBA_WAIT_FOR_ASYNC_TEST();

}

- (void) testResultsForSearchTermReturnsCorrectErrorForStatusCode500{

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        BOOL shouldStub = ([request.URL.path rangeOfString:@"search/books"].location != NSNotFound);
        return shouldStub;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:nil
                                          statusCode:500
                                             headers:@{@"Content-Type":@"application/json"}];
    }];


    BBA_PREPARE_ASYNC_TEST();

    [service resultsForSearchTerm:@"dickens"
                       searchType:BBASearchTypeBooks
                      resultCount:100
                     resultOffset:0
                       descending:YES
                        sortOrder:BBASearchSortOrderRelevance
                         callback:^(NSUInteger numResults, NSArray *results, NSError *error) {
                             XCTAssertNil(results);
                             BBBAssertErrorHasCodeAndDomain(error,
                                                            BBAAPIServerError,
                                                            BBASearchServiceErrorDomain);
                             BBA_FLAG_ASYNC_TEST_COMPLETE();
                         }];
    
    
    BBA_WAIT_FOR_ASYNC_TEST();
}

- (void) testResultsForSearchTermPopulatesSearchQuery{

    [service setConnectionClass:[BBAMockConnection class]];


    [service resultsForSearchTerm:@"search_term"
                       searchType:BBASearchTypeBooks
                      resultCount:100
                     resultOffset:0
                       descending:YES
                        sortOrder:BBASearchSortOrderRelevance
                         callback:^(NSUInteger numResults, NSArray *results, NSError *error) {

                         }];

    XCTAssertEqual([BBAMockConnection mockedConnections].count, 1);

    BBAMockConnection *mockedConnection;
    mockedConnection = [[BBAMockConnection mockedConnections]firstObject];

    NSArray *passedQueryParameter;
    passedQueryParameter = [mockedConnection passedParameters][@"q"];

    XCTAssertEqualObjects(passedQueryParameter, @"search_term");
}

- (void) testResultsForSearchTermPopulatesSearchType{

    [service setConnectionClass:[BBAMockConnection class]];


    [service resultsForSearchTerm:@"search_term"
                       searchType:BBASearchTypeBooks
                      resultCount:100
                     resultOffset:0
                       descending:YES
                        sortOrder:BBASearchSortOrderRelevance
                         callback:^(NSUInteger numResults, NSArray *results, NSError *error) {

                         }];

    XCTAssertEqual([BBAMockConnection mockedConnections].count, 1);

    BBAMockConnection *mockedConnection;
    mockedConnection = [[BBAMockConnection mockedConnections]firstObject];

    NSArray *passedQueryParameter;
    passedQueryParameter = [mockedConnection passedParameters][@"order"];

    XCTAssertEqualObjects(passedQueryParameter, @"RELEVANCE");
}

- (void) testResultsForSearchTermPopulatesDescending{

    [service setConnectionClass:[BBAMockConnection class]];


    [service resultsForSearchTerm:@"search_term"
                       searchType:BBASearchTypeBooks
                      resultCount:100
                     resultOffset:0
                       descending:YES
                        sortOrder:BBASearchSortOrderRelevance
                         callback:^(NSUInteger numResults, NSArray *results, NSError *error) {

                         }];

    XCTAssertEqual([BBAMockConnection mockedConnections].count, 1);

    BBAMockConnection *mockedConnection;
    mockedConnection = [[BBAMockConnection mockedConnections]firstObject];

    NSArray *passedQueryParameter;
    passedQueryParameter = [mockedConnection passedParameters][@"desc"];

    XCTAssertEqualObjects(passedQueryParameter, @"true");
}

- (void) testResultsForSearchTermPopulatesOffset{

    [service setConnectionClass:[BBAMockConnection class]];


    [service resultsForSearchTerm:@"search_term"
                       searchType:BBASearchTypeBooks
                      resultCount:100
                     resultOffset:666
                       descending:YES
                        sortOrder:BBASearchSortOrderRelevance
                         callback:^(NSUInteger numResults, NSArray *results, NSError *error) {

                         }];

    XCTAssertEqual([BBAMockConnection mockedConnections].count, 1);

    BBAMockConnection *mockedConnection;
    mockedConnection = [[BBAMockConnection mockedConnections]firstObject];

    NSArray *passedQueryParameter;
    passedQueryParameter = [mockedConnection passedParameters][@"offset"];

    XCTAssertEqualObjects(passedQueryParameter, @"666");
}

- (void) testResultsForSearchTermPopulatesCount{

    [service setConnectionClass:[BBAMockConnection class]];


    [service resultsForSearchTerm:@"search_term"
                       searchType:BBASearchTypeBooks
                      resultCount:666
                     resultOffset:0
                       descending:YES
                        sortOrder:BBASearchSortOrderRelevance
                         callback:^(NSUInteger numResults, NSArray *results, NSError *error) {

                         }];

    XCTAssertEqual([BBAMockConnection mockedConnections].count, 1);

    BBAMockConnection *mockedConnection;
    mockedConnection = [[BBAMockConnection mockedConnections]firstObject];

    NSArray *passedQueryParameter;
    passedQueryParameter = [mockedConnection passedParameters][@"count"];

    XCTAssertEqualObjects(passedQueryParameter, @"666");
}

- (void) testSearchSuggestionsForTermPopulatesQuery{

    [service setConnectionClass:[BBAMockConnection class]];


    [service searchSuggestionsForTerm:@"term"
                           completion:^(NSArray *results, NSError *error) {

                           }];

    XCTAssertEqual([BBAMockConnection mockedConnections].count, 1);

    BBAMockConnection *mockedConnection;
    mockedConnection = [[BBAMockConnection mockedConnections]firstObject];

    NSArray *passedQueryParameter;
    passedQueryParameter = [mockedConnection passedParameters][@"q"];

    XCTAssertEqualObjects(passedQueryParameter, @"term");
}

- (void) testSearchSuggestionsForSearchTermPopulatesLimitWithDefaultValue{

    [service setConnectionClass:[BBAMockConnection class]];


    [service searchSuggestionsForTerm:@"term"
                           completion:^(NSArray *results, NSError *error) {

                           }];

    XCTAssertEqual([BBAMockConnection mockedConnections].count, 1);

    BBAMockConnection *mockedConnection;
    mockedConnection = [[BBAMockConnection mockedConnections]firstObject];

    NSArray *passedQueryParameter;
    passedQueryParameter = [mockedConnection passedParameters][@"limit"];
    
    XCTAssertEqualObjects(passedQueryParameter, @"25");
}

@end
