//
//  BBABookItem.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 12/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBABookItem.h"
#import "BBALinkItem.h"

@implementation BBABookItem

#pragma mark - NSObject

- (NSString *) description{
    
    return [NSString stringWithFormat:@"%@, isbn:%@\rtitle:%@\rsynopsis:%@",
            [super description], self.identifier, self.title, self.synopsis];
}

#pragma mark - Public

- (NSString *) sampleLink{
    return [[self linkWithType:@"urn:blinkboxbooks:schema:samplemedia"] href];
}

- (NSString *) publisherName{
    return [[self linkWithType:@"urn:blinkboxbooks:schema:publisher"] title];
}

- (NSString *) authorName{
    return [[self linkWithType:@"urn:blinkboxbooks:schema:contributor"] title];
}

- (NSString *) authorGUID{
    return [[self linkWithType:@"urn:blinkboxbooks:schema:contributor"] targetGuid];
}

#pragma mark - Private

- (BBALinkItem *) linkWithType:(NSString *)type{
    for (BBALinkItem *item in self.links) {
        if ([item.rel isEqualToString:type]) {
            return item;
        }
    }
    
    return nil;
}

@end
