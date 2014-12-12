//
//  BBABooksResponseMapper.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 11/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBABooksMapper.h"
#import "BBABookItem.h"
#import "BBAItemLink.h"
#import "BBAItemLinkMapper.h"
#import "BBAServerDateFormatter.h"

static NSString *const kBookSchema = @"urn:blinkboxbooks:schema:book";


@interface BBABooksMapper ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation BBABooksMapper

#pragma mark - Getters

- (NSDateFormatter *) dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter = [BBAServerDateFormatter new];
    }
    return _dateFormatter;
}

#pragma mark - Public

- (BBABookItem *)itemFromDictionary:(NSDictionary *)dictionary{
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSString *type = dictionary[@"type"];
    
    if (![type isEqualToString:kBookSchema]) {
        return nil;
    }
    
    BBABookItem *item = [BBABookItem new];
    
    return item;
}

#pragma mark - Private

@end
