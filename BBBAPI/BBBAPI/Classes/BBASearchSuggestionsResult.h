//
//  BBASearchSuggestionsResult.h
//  BBBAPI
//
//  Created by Owen Worley on 12/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FastEasyMapping/FastEasyMapping.h>

/**
 *  Represents data returned from the book search suggestions service (search/suggestions)
 */
@interface BBASearchSuggestionsResult : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSArray *items;

/**
 *  Describes the mapping of server search result data to `BBASearchSuggestionsResult`
 */
+ (FEMObjectMapping *) searchSuggestionsResultMapping;

@end
