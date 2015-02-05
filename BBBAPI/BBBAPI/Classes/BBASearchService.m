//
//  BBASearchService.m
//  BBANetworking
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBASearchService.h"
#import "BBAConnection.h"
#import "BBAAPIErrors.h"
#import "BBANetworkConfiguration.h"
#import "BBASearchServiceResult.h"
#import "BBASearchSuggestionsResult.h"

NSString *const BBASearchServiceErrorDomain = @"com.BBA.searchservice";
NSString *const BBASearchServiceName = @"com.BBA.searchService";

@interface BBASearchService ()
/**
 *  The class to use for communication with the server. This defaults to BBAConnection.
 */
@property (nonatomic, strong) Class connectionClass;
@property (nonatomic, strong) BBANetworkConfiguration *configuration;
@end

@implementation BBASearchService

#pragma mark - Public Methods

- (void) searchSuggestionsForTerm:(NSString *)searchTerm
                       completion:(void (^)(NSArray *results, NSError *error))completion{

    NSAssert(completion != nil, @"completion is required.");

    if(completion == nil) {
        return;
    }

    NSAssert(searchTerm != nil, @"searchTerm is required.");
    if (!searchTerm) {
        completion(nil,  [NSError errorWithDomain:BBASearchServiceErrorDomain
                                             code:BBAAPIWrongUsage
                                         userInfo:nil]);
        return;
    }

    NSString *endPoint = [self endPointForSearchType:BBASearchTypeSuggestions];
    NSAssert(endPoint, @"Undefined endpoint for");
    if (!endPoint) {
        completion(nil,  [NSError errorWithDomain:BBASearchServiceErrorDomain
                                             code:BBAAPIWrongUsage
                                         userInfo:nil]);
        return;
    }
    BBAConnection *connection = [[self.connectionClass alloc] initWithDomain:BBAAPIDomainREST
                                                                 relativeURL:endPoint];

    connection.responseMapper = [self.configuration newResponseMapperForServiceName:BBASearchServiceName];

    connection.requiresAuthentication = NO;

    [connection addParameterWithKey:@"q" value:searchTerm];
    [connection addParameterWithKey:@"limit" value:@"25"];

    [connection perform:BBAHTTPMethodGET
             completion:^(BBASearchSuggestionsResult *response, NSError *error) {
                 completion(response.items, error);
             }];
}

- (void) resultsForSearchTerm:(NSString*)searchTerm
                   searchType:(BBASearchType)searchType
                  resultCount:(NSUInteger)resultCount
                 resultOffset:(NSUInteger)resultOffset
                   descending:(BOOL)descending
                    sortOrder:(BBASearchSortOrder)sortOrder
                     callback:(void (^)(NSUInteger numResults, NSArray *results, NSError *error))callback {

    NSAssert(callback != nil, @"With no callback this method can never return any details.");

    if(callback == nil) {
        return;
    }

    NSAssert(searchTerm != nil, @"searchTerm is required.");
    if (!searchTerm) {
        callback(0, nil,  [NSError errorWithDomain:BBASearchServiceErrorDomain
                                              code:BBAAPIWrongUsage
                                          userInfo:nil]);
        return;
    }

    NSString *endPoint = [self endPointForSearchType:searchType];
    NSAssert(endPoint, @"Undefined endpoint for search type %@", @(searchType));
    if (!endPoint) {
        callback(0, nil,  [NSError errorWithDomain:BBASearchServiceErrorDomain
                                              code:BBAAPIWrongUsage
                                          userInfo:nil]);
        return;
    }
    BBAConnection *connection = [[self.connectionClass alloc] initWithDomain:BBAAPIDomainREST
                                                                 relativeURL:endPoint];

    connection.responseMapper = [self.configuration newResponseMapperForServiceName:BBASearchServiceName];

    connection.requiresAuthentication = NO;

    [connection addParameterWithKey:@"q" value:searchTerm];
    [connection addParameterWithKey:@"order" value:[self serverSortOrder:sortOrder]];
    [connection addParameterWithKey:@"desc" value:descending?@"true" : @"false"];
    NSString *offset = [NSString stringWithFormat:@"%@", @(resultOffset)];
    [connection addParameterWithKey:@"offset" value:offset];
    NSString *count = [NSString stringWithFormat:@"%@", @(resultCount)];
    [connection addParameterWithKey:@"count" value:count];

    [connection perform:BBAHTTPMethodGET
             completion:^(BBASearchServiceResult *response, NSError *error) {
                 callback(response.numberOfResults, response.books, error);
             }];

}

#pragma mark - Private Methods

- (NSString *) endPointForSearchType:(BBASearchType)type{

    if (type == BBASearchTypeBooks) {
        return @"search/books";
    }
    else if (type == BBASearchTypeSuggestions){
        return @"search/suggestions";
    }

    NSAssert(false,@"Unsupported search type");

    return @"";
}

- (NSString *) serverSortOrder:(BBASearchSortOrder)sortOrder{
    switch (sortOrder) {
        case BBASearchSortOrderRelevance:
            return @"RELEVANCE";
        case BBASearchSortOrderAuthor:
            return @"AUTHOR";
        case BBASearchSortOrderPopularity:
            return @"POPULARITY";
        case BBASearchSortOrderPrice:
            return @"PRICE";
        case BBASearchSortOrderPublicationDate:
            return @"PUBLICATION_DATE";

        default:
            NSAssert(false, @"Unknown sort order");
            return @"";
    }
}

#pragma mark Getters

- (Class) connectionClass{
    if (_connectionClass == Nil) {
        _connectionClass = [BBAConnection class];
    }

    return _connectionClass;
}

- (BBANetworkConfiguration *) configuration{
    if (!_configuration) {
        _configuration = [BBANetworkConfiguration defaultConfiguration];
    }

    return _configuration;
}

@end
