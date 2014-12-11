//
//  BBALinkItem.m
//  BBBAPI
//
//  Created by Owen Worley on 09/12/2014.
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
