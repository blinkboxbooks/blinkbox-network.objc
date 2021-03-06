//
//  BBALibraryItemMapper.m
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 12/12/2014.
  

#import "BBALibraryItemMapper.h"
#import "BBALibraryItem.h"
#import "BBALinkItem.h"
#import "BBAServerDateFormatter.h"
#import <FastEasyMapping.h>

BBAReadingStatus BBAReadingStatusFromString(NSString *status);
BBAPurchaseStatus BBAPurchaseStatusFromString(NSString *status);
BBAVisiblityStatus BBAVisibiliyStatusFromString(NSString *status);

static NSString *const kLibraryItemSchema = @"urn:blinkboxbooks:schema:libraryitem";

@interface BBALibraryItemMapper ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) FEMObjectMapping *linksMapper;

@end


@implementation BBALibraryItemMapper

#pragma mark - Public

- (BBALibraryItem *) itemFromDictionary:(NSDictionary *)dictionary{
    
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSString *type = dictionary[@"type"];
    
    if (![type isEqualToString:kLibraryItemSchema]) {
        return nil;
    }
    
    BBALibraryItem *item = [BBALibraryItem new];
    NSString *isbn = dictionary[@"isbn"];
    NSAssert(isbn, @"isbn must be not nil");
    
    item.isbn = isbn;
    item.guid = dictionary[@"guid"];
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
    
    NSArray *links = dictionary[@"links"];
    
    item.links = [FEMObjectDeserializer deserializeCollectionExternalRepresentation:links
                                                                       usingMapping:self.linksMapper];
    
    return item;
}

#pragma mark - Getters

- (NSDateFormatter *) dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter = [ BBAServerDateFormatter new];
    }
    return _dateFormatter;
}

- (FEMObjectMapping *) linksMapper{
    if (!_linksMapper) {
        _linksMapper = [BBALinkItem linkItemMapping];
    }
    return _linksMapper;
}

@end
