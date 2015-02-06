//
//  BBASearchServiceResult.m
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 12/01/2015.
  

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
