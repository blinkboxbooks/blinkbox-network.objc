//
//  BBASearchService.h
//  BBANetworking
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 29/07/2014.
 

#import <Foundation/Foundation.h>

extern NSString *const BBASearchServiceErrorDomain;
extern NSString *const BBASearchServiceName;

typedef NS_ENUM(NSUInteger, BBASearchSortOrder) {
    BBASearchSortOrderRelevance,
    BBASearchSortOrderAuthor,
    BBASearchSortOrderPopularity,
    BBASearchSortOrderPrice,
    BBASearchSortOrderPublicationDate
};

typedef NS_ENUM(NSUInteger, BBASearchType) {
    BBASearchTypeSuggestions,
    BBASearchTypeSimiliar,
    BBASearchTypeBooks,
};

/**
 *  Provides access to the REST book search service
 */
@interface BBASearchService : NSObject
/**
 *  Query the search service for search results
 *
 *  @param searchTerm   The term to search for
 *  @param searchType   The type of search to perform, see `BBBSearchRequestType`
 *  @param resultCount  How many results to return
 *  @param resultOffset The result number to start from
 *  @param descending   Results are ordered descending
 *  @param sortOrder    The search order, see `BBBSearchServiceSortOrder`
 *  @param callback     The completion handler to call with results
 */
- (void) resultsForSearchTerm:(NSString*)searchTerm
                   searchType:(BBASearchType)searchType
                  resultCount:(NSUInteger)resultCount
                 resultOffset:(NSUInteger)resultOffset
                   descending:(BOOL)descending
                    sortOrder:(BBASearchSortOrder)sortOrder
                     callback:(void (^)(NSUInteger numResults, NSArray *results, NSError *error))callback;

/**
 *  Query the search service for search suggestions. 
 *  Results are returned as an array of `BBASuggestionItem`
 *
 *  @param searchTerm can't be `nil`
 *  @param completion can't be `nil`, called on the callers queue.
 *                    `results` contain only `BBASuggestionItem` object or is `nil`,
 *                    when `nil` request failed and `error` contains the reason of the problem
 */
- (void) searchSuggestionsForTerm:(NSString *)searchTerm
                       completion:(void (^)(NSArray *results, NSError *error))completion;
@end
