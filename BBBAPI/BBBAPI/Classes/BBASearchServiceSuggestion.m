//
//  BBASearchServiceSuggestion.m
//  BBBAPI
//
//  Created by Owen Worley on 12/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBASearchServiceSuggestion.h"

@implementation BBASearchServiceSuggestion

+ (FEMObjectMapping *) objectMapping{
    FEMObjectMapping *mapping;
    mapping = [FEMObjectMapping mappingForClass:[BBASearchServiceSuggestion class]
                                            configuration:^(FEMObjectMapping *mapping) {
                                                [mapping addAttribute:[FEMAttribute mappingOfProperty:@"title"
                                                                                            toKeyPath:@"title"]];
                                                [mapping addAttribute:[FEMAttribute mappingOfProperty:@"type"
                                                                                            toKeyPath:@"type"]];
                                                [mapping addAttribute:[FEMAttribute mappingOfProperty:@"identifier"
                                                                                            toKeyPath:@"id"]];
                                                [mapping addAttribute:[FEMAttribute mappingOfProperty:@"authors"
                                                                                            toKeyPath:@"authors"]];
                                            }];
    return mapping;
}
@end
