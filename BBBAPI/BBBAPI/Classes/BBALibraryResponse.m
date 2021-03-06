//
//  BBALibraryResponse.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 05/08/2014.
 

#import "BBALibraryResponse.h"
#import "BBAResponseMapping.h"
#import "BBALibraryItem.h"
#import "BBALinkItem.h"
#import "BBALibraryItemMapper.h"
#import "BBAServerDateFormatter.h"


@interface BBALibraryResponse ()
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

@implementation BBALibraryResponse

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
            
            *error = [NSError errorWithDomain:BBAResponseMappingErrorDomain
                                         code:BBAResponseMappingErrorUnexpectedDataFormat
                                     userInfo:userInfo];
        }
        return NO;
    }
    
    NSMutableArray *libraryItems = [NSMutableArray new];
    NSDate *syncDate;
    
    BBALibraryItemMapper *mapper = [BBALibraryItemMapper new];
    
    if ([dictionary[kType] isEqualToString:kLibraryChangesType]) {
        NSString *lastSyncDateString = dictionary[kLastSyncDateTime];
        NSAssert(lastSyncDateString, @"lastSyncDateString shouldn't be nil");
        syncDate = [self.dateFormatter dateFromString:lastSyncDateString];
        NSAssert(syncDate, @"Sync date shouldn't be nil");
        
        NSDictionary *changeSet = dictionary[kLibraryChangesList];
        NSArray *changesArray = changeSet[kItems];
        
        
        for (NSDictionary *d in changesArray) {
            BBALibraryItem *item = [mapper itemFromDictionary:d];
            if (item) {
                [libraryItems addObject:item];
            }
        }
    }
    else if ([dictionary[kType] isEqualToString:kLibraryItemType]){
        BBALibraryItem *item = [mapper itemFromDictionary:dictionary];
        if (item) {
            [libraryItems addObject:item];
        }
    }
    else if ([dictionary[kType] isEqualToString:kLibraryListType]){
        NSArray *items = dictionary[kItems];
        for (NSDictionary *d in items) {
            BBALibraryItem *item = [mapper itemFromDictionary:d];
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
        _dateFormatter = [BBAServerDateFormatter new];
    }
    return _dateFormatter;
}

#pragma mark - Private

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



BBAPurchaseStatus BBAPurchaseStatusFromString(NSString *status){
    
    if ([status isEqualToString:@"PURCHASED"]) {
        return BBAPurchaseStatusPurchased;
    }
    else if ([status isEqualToString:@"SAMPLED"]) {
        return BBAPurchaseStatusSampled;
    }
    else{
        NSCAssert(NO, @"unexpected value of purchase status");
    }
    
    
    return BBAPurchaseStatusNothing;
    
}

BBAReadingStatus BBAReadingStatusFromString(NSString *status){
    if ([status isEqualToString:@"UNREAD"]) {
        return BBAReadingStatusUnread;
    }
    else if ([status isEqualToString:@"READING"]) {
        return BBAReadingStatusReading;
    }
    else if ([status isEqualToString:@"FINISHED"]) {
        return BBAReadingStatusRead;
    }
    else{
        NSCAssert(NO, @"unexpected value of reading status");
    }
    return BBAReadingStatusUnknown;
}

BBAVisiblityStatus BBAVisibiliyStatusFromString(NSString *status){
    if ([status isEqualToString:@"CURRENT"]) {
        return BBAVisiblityStatusCurrent;
    }
    else if ([status isEqualToString:@"ARCHIVED"]) {
        return BBAVisiblityStatusArchived;
    }
    else if ([status isEqualToString:@"DELETED"]) {
        return BBAVisiblityStatusDeleted;
    }
    else{
        NSCAssert(NO, @"unexpected value of visibility status");
    }
    
    return BBAVisiblityStatusUnknown;
}

NSString * BBANSStringFromReadingStatus(BBAReadingStatus status){
    
    switch (status) {
        case BBAReadingStatusReading:{
            return @"READING";
            break;
        }
            
        case BBAReadingStatusRead:{
            return @"FINISHED";
            break;
        }
        case BBAReadingStatusUnread:{
            return @"UNREAD";
            break;
        }
        default:{
            NSCAssert(NO, @"unknown reading status value: %ld", status);
            return @"";
            break;
        }
    }
}

NSString * BBANSStringFromPurchaseStatus(BBAPurchaseStatus status){
    
    switch (status) {
        case BBAPurchaseStatusNothing:{
            return @"Nothing";
            break;
        }
        case BBAPurchaseStatusSampled :{
            return @"SAMPLED";
            break;
        }
        case BBAPurchaseStatusPurchased:{
            return @"PURCHASED";
            break;
        }
        default:{
            NSCAssert(NO, @"unknown purchase status value :%ld", status);
            return @"";
            break;
        }
    }
}

NSString * BBANSStringFromVisibiliyStatus(BBAVisiblityStatus status){
    
    switch (status) {
        case BBAVisiblityStatusUnknown:{
            return @"Unknown";
            break;
        }
        case BBAVisiblityStatusCurrent:{
            return @"CURRENT";
            break;
        }
        case BBAVisiblityStatusArchived:{
            return @"ARCHIVED";
            break;
        }
        case BBAVisiblityStatusDeleted:{
            return @"DELETED";
            break;
        }
        default:{
            NSCAssert(NO, @"unknown visibility status value :%ld", status);
            return @"";
            break;
        }
            
    }
}
