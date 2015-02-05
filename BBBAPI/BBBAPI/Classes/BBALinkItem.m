//
//  BBALinkItem.m
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 09/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBALinkItem.h"
#import <FastEasyMapping/FastEasyMapping.h>

@implementation BBALinkItem
+ (FEMObjectMapping *) linkItemMapping{
    return [FEMObjectMapping mappingForClass:[BBALinkItem class]
                               configuration:^(FEMObjectMapping *mapping) {
                                   [mapping addAttributeWithProperty:@"rel" keyPath:@"rel"];
                                   [mapping addAttributeWithProperty:@"href" keyPath:@"href"];
                                   [mapping addAttributeWithProperty:@"targetGuid" keyPath:@"targetGuid"];
                                   [mapping addAttributeWithProperty:@"title" keyPath:@"title"];
                               }];
}

@end
