//
//  BBASearchSuggestionsResult.h
//  BBBAPI
//
//  Created by Owen Worley on 12/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

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
 *  Contains `BBASearchServiceSuggestion` objects
 */
@property (nonatomic, copy) NSArray *items;

/**
 *  Describes the mapping of server search result data to `BBASearchSuggestionsResult`
 */
+ (FEMObjectMapping *) searchSuggestionsResultMapping;

@end
