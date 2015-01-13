//
//  BBASearchSuggestionsResult.m
//  BBBAPI
//
//  Created by Owen Worley on 12/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBASearchSuggestionsResult.h"
#import "BBASearchServiceSuggestion.h"
#import <FastEasyMapping/FastEasyMapping.h>

@implementation BBASearchSuggestionsResult

+ (FEMObjectMapping *) searchSuggestionsResultMapping{
    return [FEMObjectMapping mappingForClass:[BBASearchSuggestionsResult class]
                               configuration:^(FEMObjectMapping *mapping) {
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"type"
                                                                               toKeyPath:@"type"]];

                                   [mapping addToManyRelationshipMapping:[BBASearchServiceSuggestion objectMapping]
                                                             forProperty:@"items"
                                                                 keyPath:@"items"];

                               }];
}
@end
