//
//  BBABookmarkItem.m
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 05/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBABookmarkItem.h"
#import <FastEasyMapping/FastEasyMapping.h>
#import "BBAServerDateFormatter.h"
#import "BBALinkItem.h"

@implementation BBABookmarkItem

+ (BBAServerDateFormatter *)serverDateFormatter{
    static BBAServerDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [BBAServerDateFormatter new];
    });
    return formatter;
}

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
                                                                                  return [[BBABookmarkItem serverDateFormatter]dateFromString:value];
                                                                              }]];

                                   [mapping addAttribute:[FEMAttribute mappingOfProperty:@"updatedDate"
                                                                               toKeyPath:@"updatedDate"
                                                                                     map:^id(id value) {
                                                                                         if (value) {
                                                                                             return [[BBABookmarkItem serverDateFormatter]dateFromString:value];
                                                                                         }
                                                                                         else {
                                                                                             return nil;
                                                                                         }
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

+ (BBABookmarkItem *) bookmarkItemWithData:(NSData *)data{
    NSDictionary *JSONBookmark = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (!JSONBookmark) {
        return nil;
    }

    BBABookmarkItem *item;
    item = [BBABookmarkItem bookmarkItemWithJSON:JSONBookmark];

    return item;
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

- (NSDictionary *) dictionaryRepresentation{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    NSAssert(self.book != nil, @"book(isbn) is required");
    NSAssert(self.bookmarkType != nil, @"bookmarkType is required");
    NSAssert(self.position != nil, @"position is required");
    NSAssert(self.readingPercentage != nil, @"readingPercentage is required");

    if (!self.book || !self.bookmarkType || !self.position || !self.readingPercentage) {
        return nil;
    }

    dictionary[@"book"] = self.book;
    dictionary[@"bookmarkType"] = self.bookmarkType;
    dictionary[@"position"] = self.position;
    dictionary[@"readingPercentage"] = [self.readingPercentage stringValue];

    if (self.name) {
        dictionary[@"name"] = self.name;
    }
    if (self.annotation) {
        dictionary[@"annotation"] = self.annotation;
    }
    if (self.style) {
        dictionary[@"style"] = self.style;
    }
    if (self.colour) {
        dictionary[@"colour"] = self.colour;
    }
    if (self.preview) {
        dictionary[@"preview"] = self.preview;
    }

    return dictionary;
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
