//
//  BBASearchServiceResult.h
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 12/01/2015.
  

#import <Foundation/Foundation.h>
@class FEMObjectMapping;
/**
 *  Represents data provided from the search service when searching for books
 */
@interface BBASearchServiceResult : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *identifier;
/**
 *  Array of `BBALibraryItemLink` objects
 */
@property (nonatomic, copy) NSArray *links;
@property (nonatomic, assign) NSInteger numberOfResults;
@property (nonatomic, copy) NSArray *books;

/**
 *  Object mapping to convert server search result to `BBASearchServiceResult`
 */
+ (FEMObjectMapping *) searchServiceResultMapping;
@end
