//
//  BBASearchItem.m
//  BBBAPI
//
//  Created by Owen Worley on 09/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <FastEasyMapping/FastEasyMapping.h>
#import "BBASearchItem.h"


@implementation BBASearchItem

+ (FEMObjectMapping *) objectMapping{
    FEMObjectMapping *searchBookMapping;
    searchBookMapping = [FEMObjectMapping mappingForClass:[BBASearchItem class]
                                            configuration:^(FEMObjectMapping *mapping) {
                                                [mapping addAttribute:[FEMAttribute mappingOfProperty:@"title"
                                                                                            toKeyPath:@"title"]];
                                                [mapping addAttribute:[FEMAttribute mappingOfProperty:@"identifier"
                                                                                            toKeyPath:@"id"]];
                                                [mapping addAttribute:[FEMAttribute mappingOfProperty:@"authors"
                                                                                            toKeyPath:@"authors"]];
                                            }];
    return searchBookMapping;
}
@end
