//
//  BBALibraryItem.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBALibraryItem.h"
#import "BBALibraryResponse.h"
#import "BBALinkItem.h"

@implementation BBALibraryItem

- (id) init{
    self = [super init];
    if (self) {
        _readingStatus = BBAReadingStatusUnknown;
        _purchaseStatus =  BBAPurchaseStatusNothing;
        _visibilityStatus = BBAVisiblityStatusUnknown;
        _maxNumberOfAuthorisedDevices = -1;
        _numberOfAuthorisedDevices = -1;
        
    }
    return self;
}

- (BOOL) isEqual:(id)object{
    if (![object isKindOfClass:[BBALibraryItem class]]) {
        return NO;
    }
    
    BBALibraryItem *item = (BBALibraryItem *)object;
    BOOL isbnsAreEqual = [self.isbn isEqualToString:item.isbn];
    BOOL idsAreEqual = [self.identifier isEqualToString:item.identifier];
    return isbnsAreEqual && idsAreEqual;
}

- (NSUInteger) hash{
    return [self.isbn integerValue];
}

- (NSString *) description{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:(NSDateFormatterFullStyle)];
    [formatter setTimeStyle:(NSDateFormatterFullStyle)];
    NSMutableString *string = [[NSMutableString alloc] init];
    NSString *newLine = @"\n";
    [string appendFormat:@"----------------------------------------%@", newLine];
    [string appendFormat:@"%@ isbn: %@, id: %@%@", [super description], self.isbn, self.identifier, newLine];
    [string appendFormat:@"purchase status: %@", BBANSStringFromPurchaseStatus(self.purchaseStatus)];
    
    if(self.purchaseStatus == BBAPurchaseStatusPurchased){
        [string appendFormat:@" purchased at: %@%@", [formatter stringFromDate:self.purchasedDate], newLine];
    }
    else if(self.purchaseStatus == BBAPurchaseStatusSampled){
        [string appendFormat:@" sampled at: %@%@", [formatter stringFromDate:self.sampledDate], newLine];
    }
    else{
        [string appendFormat:@"%@", newLine];
    }
    
    [string appendFormat:@"visibility status: %@", BBANSStringFromVisibiliyStatus(self.visibilityStatus)];
    
    if(self.visibilityStatus == BBAVisiblityStatusArchived){
        [string appendFormat:@" archived date: %@%@",[formatter stringFromDate:self.archivedDate], newLine];
    }
    else if(self.visibilityStatus == BBAVisiblityStatusDeleted){
        [string appendFormat:@" deleted date: %@%@",[formatter stringFromDate:self.deletedDate], newLine];
    }
    else{
        [string appendString:newLine];
    }
    
    [string appendFormat:@"reading status : %@%@", BBANSStringFromReadingStatus(self.readingStatus), newLine];
    
    if(self.numberOfAuthorisedDevices > 0 && self.maxNumberOfAuthorisedDevices > 0){
        [string appendFormat:@"authorized devices : (%ld out of %ld)%@",
         self.numberOfAuthorisedDevices, self.maxNumberOfAuthorisedDevices, newLine];
    }
    
    if (self.links.count > 0) {
        for (NSInteger i = 0; i < self.links.count; i++) {
            BBALinkItem *link = self.links[i];
            [string appendFormat:@"link: %ld%@%@%@", i, newLine, [link description], newLine];
        }
    }
    
    [string appendFormat:@"----------------------------------------%@", newLine];
    
    return string;
}

- (NSString *) linkWithRelationshop:(NSString *)relation{
    NSParameterAssert(relation);
    if (!relation) {
        return nil;
    }
    
    NSString *fullRelation = [NSString stringWithFormat:@"urn:blinkboxbooks:schema:%@",relation];
    
    for (BBALinkItem *link in self.links) {
        if([link.rel isEqualToString:fullRelation]){
            return link.href;
        }
    }
    
    return nil;
}

- (NSString *) fullMediaURL{
    return [self linkWithRelationshop:@"fullmedia"];
}

- (NSString *) mediaKeyURL{
    return [self linkWithRelationshop:@"mediakey"];
}

- (NSString *) sampleMediaURL{
    return [self linkWithRelationshop:@"samplemedia"];
}

@end
