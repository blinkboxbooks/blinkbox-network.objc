//
//  BBACatalogueServiceTestHelper.m
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 12/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBACatalogueServiceTestHelper.h"
#import "BBATestHelper.h"
#import "BBABookItem.h"

@implementation BBACatalogueServiceTestHelper

+ (NSArray *) sampleBigRealItems{
    /*
     search_sample_data.json containts array of 300 isbns
     */
    NSData *data = [BBATestHelper dataForTestBundleFileNamed:@"search_sample_data.json"
                                                forTestClass:[self class]];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSArray *isbns = [array valueForKeyPath:@"id"];
    
    NSMutableArray *books = [NSMutableArray new];
    
    for (NSString *isbn in isbns) {
        BBABookItem *item = [BBABookItem new];
        item.identifier = isbn;
        [books addObject:item];
    }
    return books;
}

+ (NSArray *) sampleBigFakeItems{
    NSMutableArray *array = [NSMutableArray new];
    for (NSInteger i = 0; i < 150; i++) {
        BBABookItem *item = [BBABookItem new];
        item.identifier = [@(i+1) description];
        [array addObject:item];
    }
    return array;
}

+ (NSDictionary *) sampleBigFakeResponseForRange:(NSRange)range{
    
    NSMutableDictionary *dictionary = [@{
                                         @"type": @"urn:blinkboxbooks:schema:list",
                                         @"numberOfResults": @(range.length * 3),
                                         @"offset": @0,
                                         @"count": @(range.length),
                                         } mutableCopy];
    
    NSMutableArray *array = [NSMutableArray new];
    for (NSInteger i = range.location; i < range.location + range.length; i ++) {
        
        NSDictionary *item = @{
                               @"type": @"urn:blinkboxbooks:schema:book",
                               @"guid": @"urn:blinkboxbooks:id:book:9780988415119",
                               @"id": [@(i) description],
                               @"title": [NSString stringWithFormat:@"Title%@",@(i)],
                               @"publicationDate": @"2012-09-25",
                               @"sampleEligible": @"true",
                               @"images": @[
                                       @{
                                           @"rel": @"urn:blinkboxbooks:image:cover",
                                           @"src": @"http://media.blinkboxbooks.com/9780/988/415/119/714601535c5fe85bb1fc0870cfb26586.png"
                                           }
                                       ],
                               @"links": @[
                                       @{
                                           @"rel": @"urn:blinkboxbooks:schema:contributor",
                                           @"href": @"/service/catalogue/contributors/c04bed97708775a22550e1f91658fad8f8cd1ce6",
                                           @"title": @"Tom Nix",
                                           @"targetGuid": @"urn:blinkboxbooks:id:contributor:c04bed97708775a22550e1f91658fad8f8cd1ce6"
                                           }
                                       ]
                               };
        
        [array addObject:item];
        
    }
    
    dictionary[@"items"] = array;
    
    return dictionary;
}

@end
