//
//  BBBLibraryResponse.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 05/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBLibraryResponse.h"
#import "BBBResponseMapping.h"
#import "BBBLibraryItem.h"
#import "BBBLibraryItemLink.h"
#import "BBBServerDateFormatter.h"

BBBReadingStatus BBBReadingStatusFromString(NSString *status);
BBBPurchaseStatus BBBPurchaseStatusFromString(NSString *status);
BBBVisiblityStatus BBBVisibiliyStatusFromString(NSString *status);

@interface BBBLibraryResponse ()
@property (nonatomic, strong) NSDate *syncDate;
@property (nonatomic, copy) NSArray *changes;
@property (nonatomic, copy) NSDateFormatter *dateFormatter;
@end

static NSString *const kLibraryChangesType = @"urn:blinkboxbooks:schema:librarychanges";
static NSString *const kLibraryItemType = @"urn:blinkboxbooks:schema:libraryitem";
static NSString *const kLibraryListType = @"urn:blinkboxbooks:schema:list";

static NSString *const kLibraryChangesList = @"libraryChangesList";
static NSString *const kType = @"type";
static NSString *const kItems = @"items";
static NSString *const kLastSyncDateTime = @"lastSyncDateTime";

@implementation BBBLibraryResponse

#pragma mark - Public 

- (BOOL) parseJSON:(NSDictionary *)dictionary error:(NSError **)error{
    NSDictionary *userInfo;
    
    BOOL validData = [self isDataValid:dictionary];
    NSAssert(validData, @"we should get valid data here");
    if (!validData) {
        self.changes = nil;
        self.syncDate = nil;
        NSAssert(error, @"must be writable");
        if (error != nil) {
            
            if ([dictionary description]) {
                userInfo = @{NSLocalizedFailureReasonErrorKey : [dictionary description]};
            }
            
            *error = [NSError errorWithDomain:BBBResponseMappingErrorDomain
                                         code:BBBResponseMappingErrorUnexpectedDataFormat
                                     userInfo:userInfo];
        }
        return NO;
    }
    
    NSMutableArray *libraryItems = [NSMutableArray new];
    NSDate *syncDate;
    
    if ([dictionary[kType] isEqualToString:kLibraryChangesType]) {
        NSString *lastSyncDateString = dictionary[kLastSyncDateTime];
        NSAssert(lastSyncDateString, @"lastSyncDateString shouldn't be nil");
        syncDate = [self.dateFormatter dateFromString:lastSyncDateString];
        NSAssert(syncDate, @"Sync date shouldn't be nil");
        
        NSDictionary *changeSet = dictionary[kLibraryChangesList];
        NSArray *changesArray = changeSet[kItems];
        
        
        for (NSDictionary *d in changesArray) {
            BBBLibraryItem *item = [self itemFromDictionary:d];
            if (item) {
                [libraryItems addObject:item];
            }
        }
    }
    else if ([dictionary[kType] isEqualToString:kLibraryItemType]){
        BBBLibraryItem *item = [self itemFromDictionary:dictionary];
        if (item) {
            [libraryItems addObject:item];
        }
    }
    else if ([dictionary[kType] isEqualToString:kLibraryListType]){
        NSArray *items = dictionary[kItems];
        for (NSDictionary *d in items) {
            BBBLibraryItem *item = [self itemFromDictionary:d];
            if (item) {
                [libraryItems addObject:item];
            }
        }
    }
    else{
        NSAssert(NO, @"unexpected data type");
        self.changes = nil;
        self.syncDate = nil;
        return NO;
    }
    
    self.changes = [NSArray arrayWithArray:libraryItems];
    self.syncDate = syncDate;
    
    return YES;
}

#pragma mark - Getters

- (NSDateFormatter *) dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter = [BBBServerDateFormatter new];
    }
    return _dateFormatter;
}

#pragma mark - Private

- (BBBLibraryItem *) itemFromDictionary:(NSDictionary *)dictionary{
    BBBLibraryItem *item = [BBBLibraryItem new];
    NSString *isbn = dictionary[@"isbn"];
    NSAssert(isbn, @"isbn must be not nil");
    
    item.isbn = isbn;
    
    NSString *identifier = dictionary[@"id"];
    NSAssert(identifier, @"id mustn't be nil");
    item.identifier = identifier;
    
    item.visibilityStatus = BBBVisibiliyStatusFromString(dictionary[@"visibilityStatus"]);
    item.readingStatus = BBBReadingStatusFromString(dictionary[@"readingStatus"]);
    item.purchaseStatus = BBBPurchaseStatusFromString(dictionary[@"purchaseStatus"]);
    
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
    
    if (item.visibilityStatus != BBBVisiblityStatusDeleted) {
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
        BBBLibraryItemLink *link = [self linkFromDictionary:d];
        if (link) {
            [linksArray addObject:link];
        }
    }
    
    item.links = [NSArray arrayWithArray:linksArray];
    
    return item;
}

- (BBBLibraryItemLink *) linkFromDictionary:(NSDictionary *)dictionary{
    BBBLibraryItemLink *link = [BBBLibraryItemLink new];
    link.address = dictionary[@"href"];
    link.relationship = dictionary[@"rel"];
    link.title = dictionary[@"title"];
    return link;
}

- (BOOL) isDataValid:(id)data{
    BOOL correctClass = [data isKindOfClass:[NSDictionary class]];
    
    if (!correctClass) {
        return NO;
    }
    
    NSDictionary *dictionary = (NSDictionary *)data;
    NSArray *acceptedTypes = @[kLibraryChangesType, kLibraryItemType, kLibraryListType];
    BOOL correctType = NO;
    
    for (NSString *type in acceptedTypes) {
        if ([dictionary[kType] isEqualToString:type]) {
            correctType = YES;
            break;
        }
    }
    
    if (!correctType) {
        return NO;
    }
    
    return [self validateResponse:data ofType:dictionary[kType]];
    
}

- (BOOL) validateResponse:(id)data ofType:(NSString *)type{
    if ([type isEqualToString:kLibraryChangesType]) {
        return [self validateLibraryChangesList:data];
    }
    else if ([type isEqualToString:kLibraryItemType]){
        return [self validateLibraryItemType:data];
    }
    else if ([type isEqualToString:kLibraryListType]){
        return [self validateLibraryList:data];
    }
    else{
        NSAssert(NO, @"unexpect data type %@", [data description]);
        return NO;
    }
}

- (BOOL) validateLibraryItemType:(NSDictionary *)item{
    BOOL validClass = [item isKindOfClass:[NSDictionary class]];
    NSAssert(validClass, @"library item should be a dictionary");
    if (!validClass) {
        return NO;
    }
    
    NSArray *obligatoryKeys = (@[
                                 @"guid",
                                 @"id",
                                 @"isbn",
                                 @"purchaseStatus",
                                 @"visibilityStatus",
                                 @"readingStatus",
                                 @"maxNumberOfAuthorisedDevices",
                                 @"numberOfAuthorisedDevices"
                                 ]);

    for (NSString *key in obligatoryKeys) {
        if (!item[key]) {
            NSAssert(NO, @"library item %@ should have value for key : %@", item, key);
            return NO;
        }
    }
    
    return YES;
}

- (BOOL) validateLibraryChangesList:(NSDictionary *)dictionary{
    
    BOOL validClass = [dictionary isKindOfClass:[NSDictionary class]];
    NSAssert(validClass, @"library changes list should be a dictionary");
    if (!validClass) {
        return NO;
    }
    
    NSString *dateString = dictionary[kLastSyncDateTime];
    NSAssert(dateString.length > 0, @"must be not zero length");
    
    if (dateString.length == 0) {
        return NO;
    }
    
    
    NSDictionary *changesList = dictionary[kLibraryChangesList];
    BOOL isDictionary  = [changesList isKindOfClass:[NSDictionary class]];
    NSAssert(isDictionary, @"Should be an dictionary");
    if (!isDictionary) {
        return NO;
    }
    
    BOOL listIsEmpty = changesList[kItems] == nil;
    
    if (listIsEmpty) {
        return YES;
    }
    
    
    BOOL isArray = [changesList[kItems] isKindOfClass:[NSArray class]];
    NSAssert(isArray,@"must be array if exists");
    if (!isArray) {
        return NO;
    }
    
    for (NSDictionary *d in changesList[kItems]) {
        BOOL itemValid = [self validateLibraryItemType:d];
        if (!itemValid) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL) validateLibraryList:(NSDictionary *)dictionary{
    BOOL validClass = [dictionary isKindOfClass:[NSDictionary class]];
    NSAssert(validClass, @"library changes list should be a dictionary");
    if (!validClass) {
        return NO;
    }
    
    
    return YES;
}

@end



BBBPurchaseStatus BBBPurchaseStatusFromString(NSString *status){
    
    if ([status isEqualToString:@"PURCHASED"]) {
        return BBBPurchaseStatusPurchased;
    }
    else if ([status isEqualToString:@"SAMPLED"]) {
        return BBBPurchaseStatusSampled;
    }
    else{
        NSCAssert(NO, @"unexpected value of purchase status");
    }
    
    
    return BBBPurchaseStatusNothing;
    
}

BBBReadingStatus BBBReadingStatusFromString(NSString *status){
    if ([status isEqualToString:@"UNREAD"]) {
        return BBBReadingStatusUnread;
    }
    else if ([status isEqualToString:@"READING"]) {
        return BBBReadingStatusReading;
    }
    else if ([status isEqualToString:@"FINISHED"]) {
        return BBBReadingStatusRead;
    }
    else{
        NSCAssert(NO, @"unexpected value of reading status");
    }
    return BBBReadingStatusUnknown;
}

BBBVisiblityStatus BBBVisibiliyStatusFromString(NSString *status){
    if ([status isEqualToString:@"CURRENT"]) {
        return BBBVisiblityStatusCurrent;
    }
    else if ([status isEqualToString:@"ARCHIVED"]) {
        return BBBVisiblityStatusArchived;
    }
    else if ([status isEqualToString:@"DELETED"]) {
        return BBBVisiblityStatusDeleted;
    }
    else{
        NSCAssert(NO, @"unexpected value of visibility status");
    }
    
    return BBBVisiblityStatusUnknown;
}

NSString * BBBNSStringFromBBBReadingStatus(BBBReadingStatus status){

    switch (status) {
        case BBBReadingStatusReading:{
            return @"READING";
            break;
        }
            
        case BBBReadingStatusRead:{
            return @"FINISHED";
            break;
        }
        case BBBReadingStatusUnread:{
            return @"UNREAD";
            break;
        }
        default:{
            NSCAssert(NO, @"unknown reading status value");
            return nil;
            break;
        }
    }
}