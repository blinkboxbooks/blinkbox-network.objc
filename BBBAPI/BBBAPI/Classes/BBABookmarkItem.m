//
//  BBABookmarkItem.m
//  BBBAPI
//
//  Created by Owen Worley on 05/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBABookmarkItem.h"
#import <FastEasyMapping/FastEasyMapping.h>
#import "BBADateHelper.h"
#import "BBALinkItem.h"

@implementation BBABookmarkItem

+ (FEMObjectMapping *) bookmarkMapping{
    return [FEMObjectMapping mappingForClass:[BBABookmarkItem class]
                               configuration:^(FEMObjectMapping *mapping) {
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"type"
                                                                               toKeyPath:@"type"]];
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"guid"
                                                                               toKeyPath:@"guid"]];
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"identifier"
                                                                               toKeyPath:@"id"]];
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"bookmarkType"
                                                                               toKeyPath:@"bookmarkType"]];
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"book"
                                                                               toKeyPath:@"book"]];
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"position"
                                                                               toKeyPath:@"position"]];
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"readingPercentage"
                                                                               toKeyPath:@"readingPercentage"]];
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"deleted"
                                                                               toKeyPath:@"deleted"]];
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"name"
                                                                               toKeyPath:@"name"]];
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"annotation"
                                                                               toKeyPath:@"annotation"]];
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"style"
                                                                               toKeyPath:@"style"]];
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"colour"
                                                                               toKeyPath:@"colour"]];
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"preview"
                                                                               toKeyPath:@"preview"]];
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"createdByClient"
                                                                               toKeyPath:@"createdByClient"]];
                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"updatedByClient"
                                                                               toKeyPath:@"updatedByClient"]];


                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"createdDate"
                                                                               toKeyPath:@"createdDate"
                                                                              map:^id(id value) {
                                                                                  return [BBADateHelper dateFromString:value];
                                                                              }]];

                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"updatedDate"
                                                                               toKeyPath:@"updatedDate"
                                                                                     map:^id(id value) {
                                                                                         return [BBADateHelper dateFromString:value];
                                                                                     }]];

                                   [mapping addToManyRelationshipMapping:[BBALinkItem linkItemMapping]
                                                             forProperty:@"links"
                                                                 keyPath:@"links"];
                               }];
}

+ (NSArray *) bookmarkItemsWithJSONArray:(NSArray *)array{
    NSArray *bookmarks;
    FEMObjectMapping *mapping;
    mapping = [BBABookmarkItem bookmarkMapping];
    bookmarks = [FEMObjectDeserializer deserializeCollectionExternalRepresentation:array
                                                                      usingMapping:mapping];
    return bookmarks;
}

+ (BBABookmarkItem *) bookmarkItemWithJSON:(NSDictionary *)dictionary{
    NSParameterAssert(dictionary);
    if (!dictionary) {
        return nil;
    }
    
    BBABookmarkItem *item;
    FEMObjectMapping *mapping;
    mapping = [BBABookmarkItem bookmarkMapping];
    item = [FEMObjectDeserializer deserializeObjectExternalRepresentation:dictionary
                                                             usingMapping:mapping];

    return item;
}

- (NSString *) description{
    return [NSString stringWithFormat:@"%@:%@\n%@:%@\n%@:%@\n%@:%@\n%@:%@\n%@:%@\n%@:%@\n%@:%@\n%@:%@\n%@:%@\n%@:%@\n%@:%@\n%@:%@\n%@:%@\n%@:%@\n%@:%@\n%@:%@\n",
            @"type", self.type,
            @"guid", self.guid,
            @"identifier(id)", self.identifier,
            @"bookmarkType", self.bookmarkType,
            @"book (isbn)", self.book,
            @"position", self.position,
            @"readingPercentage", self.readingPercentage,
            @"deleted", self.deleted,
            @"name", self.name,
            @"annotation", self.annotation,
            @"style", self.style,
            @"colour", self.colour,
            @"preview", self.preview,
            @"createdDate", self.createdDate,
            @"updatedDate", self.updatedDate,
            @"createdByClient", self.createdByClient,
            @"updatedByClient", self.updatedByClient
            ];
}

@end
