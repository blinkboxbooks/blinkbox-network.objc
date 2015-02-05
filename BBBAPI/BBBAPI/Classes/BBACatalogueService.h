//
//  BBACatalogueService.h
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const BBACatalogueErrorDomain;

@class BBABookItem;

/**
 *  The `BBACatalogueService` implements `Book Service`:
 *  (http://jira.blinkbox.local/confluence/display/PT/Book+Service+REST+Service+API+Guide)
 *  in the iOS Objective-C domain
 */
@interface BBACatalogueService : NSObject

/**
 *  Fetches the HTML synopsis of a given book item and assigned it to `synopsis` property
 *
 *  @param item       must not be `nil` and must have not-`nil` `identifier` (ISBN) field
 *  @param completion must not be `nil`, called upon completion on the main thread. `itemWithSynopsis` 
 *                    have the `synopsis` property assigned or `itemWithSynopsis` is equal to `nil`
 *                    if error occured
 */
- (void) getSynopsisForBookItem:(BBABookItem *)item
                     completion:(void (^)(BBABookItem *itemWithSynposis, NSError *error))completion;

/**
 *  Fetches book items related to given book
 *
 *  @param item       must not be `nil` and must have not-`nil` `identifier` (ISBN) field
 *  @param count      number of books to return, must be greater than `0`. If 0 is passed in, request
 *                    is sent with `count` set to `1`.
 *  @param completion must not be `nil`, called upon completion on the main thread. `libraryItems` 
 *                    array contains `BBABookItem` objects with all properties populated.
 *                    If an error occurs, `libraryItems` is `nil` and `error` should contain problem
 *                    description.
 */
- (void) getRelatedBooksForBookItem:(BBABookItem *)item
                              count:(NSUInteger)count
                         completion:(void (^)(NSArray *libraryItems, NSError *error))completion;

/**
 *  Fills properties like `image`, `link`, `title` etc for all passed in objects
 *  If `items` array contain more than `50` objects, multiple request will be made to 
 *  the server and `completion` will be called after all of them are finished.
 *  Each request will ask server for `50` results.
 *  The order of results passed in the `detailItems` is the same as in the `items` if all
 *  `isbn's` exist on the server.
 *  If any of the requests fails, this method fails alltogether and returns `nil` as `detailItems`
 *  and may contain non-`nil` `error` with problem description
 *
 *  @param items      must not be `nil` and must contain `BBABookItem` objects with non-`nil` identifier
 *                    properties
 *  @param completion must not be `nil`, called upon all request are fisnished on the main thread.
 *                    `detailItems` will be `nil` when any request faild or will containt `BBABookItem` 
 *                    objects.
 */
- (void) getDetailsForBookItems:(NSArray *)items
                     completion:(void (^)(NSArray *detailItems, NSError *error))completion;
@end
