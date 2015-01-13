//
//  BBASearchServiceResult.m
//  BBBAPI
//
//  Created by Owen Worley on 12/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBASearchServiceResult.h"
#import "BBASearchItem.h"
#import "BBALinkItem.h"
#import <FastEasyMapping/FastEasyMapping.h>

@implementation BBASearchServiceResult

+ (FEMObjectMapping *) searchServiceResultMapping{
    return [FEMObjectMapping mappingForClass:[BBASearchServiceResult class]
                               configuration:^(FEMObjectMapping *mapping) {
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"type"
                                                                               toKeyPath:@"type"]];
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"identifier"
                                                                               toKeyPath:@"id"]];
                                   [mapping addToManyRelationshipMapping:[BBASearchItem objectMapping]
                                                             forProperty:@"books"
                                                                 keyPath:@"books"];
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"numberOfResults"
                                                                               toKeyPath:@"numberOfResults"]];
                                   [mapping addToManyRelationshipMapping:[BBALinkItem linkItemMapping]
                                                             forProperty:@"links"
                                                                 keyPath:@"links"];

                               }];
}

@end
