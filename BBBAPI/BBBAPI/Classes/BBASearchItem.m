//
//  BBASearchItem.m
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 09/01/2015.
  

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
