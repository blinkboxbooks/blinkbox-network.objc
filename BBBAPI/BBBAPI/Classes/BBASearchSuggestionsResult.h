//
//  BBASearchSuggestionsResult.h
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 12/01/2015.
  

#import <Foundation/Foundation.h>
@class FEMObjectMapping;

/**
 *  Represents data returned from the book search suggestions service (search/suggestions)
 */
@interface BBASearchSuggestionsResult : NSObject

/**
 *  Servers type name for this result.
 *  Currently this can be either:
 *  `urn:blinkboxbooks:schema:suggestion:book` or `urn:blinkboxbooks:schema:suggestion:contributor`
 */
@property (nonatomic, copy) NSString *type;
/**
 *  Contains `BBASuggestionItem` objects
 */
@property (nonatomic, copy) NSArray *items;

/**
 *  Describes the mapping of server search result data to `BBASearchSuggestionsResult`
 */
+ (FEMObjectMapping *) searchSuggestionsResultMapping;

@end
