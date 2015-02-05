//
//  BBASearchSuggestionsResult.m
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 12/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBASearchSuggestionsResult.h"
#import "BBASuggestionItem.h"
#import <FastEasyMapping/FastEasyMapping.h>

@implementation BBASearchSuggestionsResult

+ (FEMObjectMapping *) searchSuggestionsResultMapping{
    return [FEMObjectMapping mappingForClass:[BBASearchSuggestionsResult class]
                               configuration:^(FEMObjectMapping *mapping) {
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"type"
                                                                               toKeyPath:@"type"]];

                                   [mapping addToManyRelationshipMapping:[BBASuggestionItem objectMapping]
                                                             forProperty:@"items"
                                                                 keyPath:@"items"];

                               }];
}
@end
