//
//  BBABooksResponseMapper.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 11/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBABooksResponseMapper.h"
#import "BBALibraryTypes.h"
#import "BBALibraryItem.h"
#import "BBALibraryItemLink.h"
#import "BBAServerDateFormatter.h"

static NSString *const kBookSchema = @"urn:blinkboxbooks:schema:book";
static NSString *const kLibraryItemSchema = @"urn:blinkboxbooks:schema:libraryitem";

BBAReadingStatus BBAReadingStatusFromString(NSString *status);
BBAPurchaseStatus BBAPurchaseStatusFromString(NSString *status);
BBAVisiblityStatus BBAVisibiliyStatusFromString(NSString *status);

@interface BBABooksResponseMapper ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation BBABooksResponseMapper

#pragma mark - Getters

- (NSDateFormatter *) dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter = [BBAServerDateFormatter new];
    }
    return _dateFormatter;
}

#pragma mark - Public

- (BBALibraryItem *) itemFromDictionary:(NSDictionary *)dictionary{
    
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSString *type = dictionary[@"type"];
    
    if (![type isEqualToString:kBookSchema] && ![type isEqualToString:kLibraryItemSchema]) {
        return nil;
    }
    
    BBALibraryItem *item = [BBALibraryItem new];
    NSString *isbn = dictionary[@"isbn"];
    NSAssert(isbn, @"isbn must be not nil");
    
    item.isbn = isbn;
    
    NSString *identifier = dictionary[@"id"];
    NSAssert(identifier, @"id mustn't be nil");
    item.identifier = identifier;
    
    item.visibilityStatus = BBAVisibiliyStatusFromString(dictionary[@"visibilityStatus"]);
    item.readingStatus = BBAReadingStatusFromString(dictionary[@"readingStatus"]);
    item.purchaseStatus = BBAPurchaseStatusFromString(dictionary[@"purchaseStatus"]);
    
    NSString *purchasedDateString = dictionary[@"purchasedDate"];
    if (purchasedDateString) {
        item.purchasedDate = [self.dateFormatter dateFromString:purchasedDateString];
    }
    
    NSString *deletedDateString = dictionary[@"deletedDate"];
    if (deletedDateString) {
        item.deletedDate = [self.dateFormatter dateFromString:deletedDateString];
    }
    
    NSString *sampledDateString = dictionary[@"sampledDate"];
    if (sampledDateString) {
        item.sampledDate = [self.dateFormatter dateFromString:sampledDateString];
    }
    
    NSString *archivedDateString = dictionary[@"archivedDate"];
    if (archivedDateString) {
        item.archivedDate = [self.dateFormatter dateFromString:archivedDateString];
    }
    
    if (item.visibilityStatus != BBAVisiblityStatusDeleted && !item.sampledDate) {
        NSNumber *maxNumberOfAuthorisedDevices = dictionary[@"maxNumberOfAuthorisedDevices"];
        NSNumber *numberOfAuthorisedDevices = dictionary[@"numberOfAuthorisedDevices"];
        NSAssert(maxNumberOfAuthorisedDevices, @"maxNumberOfAuthorisedDevices mustn't be nil");
        NSAssert(numberOfAuthorisedDevices, @"numberOfAuthorisedDevices mustn't be nil");
        
        Class cls = [NSNumber class];
        NSAssert([maxNumberOfAuthorisedDevices isKindOfClass:cls], @"max Number must be number");
        NSAssert([numberOfAuthorisedDevices isKindOfClass:cls], @"number must be number");
        
        item.maxNumberOfAuthorisedDevices = [maxNumberOfAuthorisedDevices integerValue];
        item.numberOfAuthorisedDevices = [numberOfAuthorisedDevices integerValue];
    }
    
    
    NSMutableArray *linksArray = [NSMutableArray new];
    NSArray *links = dictionary[@"links"];
    for (NSDictionary *d in links) {
        BBALibraryItemLink *link = [self linkFromDictionary:d];
        if (link) {
            [linksArray addObject:link];
        }
    }
    
    item.links = [NSArray arrayWithArray:linksArray];
    
    return item;
}

#pragma mark - Private

- (BBALibraryItemLink *) linkFromDictionary:(NSDictionary *)dictionary{
    BBALibraryItemLink *link = [BBALibraryItemLink new];
    link.address = dictionary[@"href"];
    link.relationship = dictionary[@"rel"];
    link.title = dictionary[@"title"];
    return link;
}

@end
