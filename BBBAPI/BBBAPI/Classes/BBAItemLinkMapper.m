//
//  BBAItemLinkMapper.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 12/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBAItemLinkMapper.h"
#import "BBAItemLink.h"

@implementation BBAItemLinkMapper

- (BBAItemLink *) linkFromDictionary:(NSDictionary *)dictionary{
    BBAItemLink *link = [BBAItemLink new];
    link.address = dictionary[@"href"];
    link.relationship = dictionary[@"rel"];
    link.title = dictionary[@"title"];
    return link;
}

@end
