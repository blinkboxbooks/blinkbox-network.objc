//
//  BBALibraryItem.m
//  BBAAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBALibraryItem.h"
#import "BBALibraryResponse.h"
#import "BBALibraryItemLink.h"

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
    [string appendFormat:@"----------------------------------------\r"];
    [string appendFormat:@"%@ isbn: %@, id: %@\r", [super description], self.isbn, self.identifier];
    [string appendFormat:@"purchase status: %@", BBANSStringFromPurchaseStatus(self.purchaseStatus)];
    
    if(self.purchaseStatus == BBAPurchaseStatusPurchased){
        [string appendFormat:@" purchased at: %@\r", [formatter stringFromDate:self.purchasedDate]];
    }
    else if(self.purchaseStatus == BBAPurchaseStatusSampled){
        [string appendFormat:@" sampled at: %@\r", [formatter stringFromDate:self.sampledDate]];
    }
    else{
        [string appendString:@"\r"];
    }
    
    [string appendFormat:@"visibility status: %@", BBANSStringFromVisibiliyStatus(self.visibilityStatus)];
    
    if(self.visibilityStatus == BBAVisiblityStatusArchived){
        [string appendFormat:@" archived date: %@\r",[formatter stringFromDate:self.archivedDate]];
    }
    else if(self.visibilityStatus == BBAVisiblityStatusDeleted){
        [string appendFormat:@" deleted date: %@\r",[formatter stringFromDate:self.deletedDate]];
    }
    else{
        [string appendString:@"\r"];
    }
    
    [string appendFormat:@"reading status : %@\r", BBANSStringFromReadingStatus(self.readingStatus)];
    
    if(self.numberOfAuthorisedDevices > 0 && self.maxNumberOfAuthorisedDevices > 0){
        [string appendFormat:@"authorized devices : (%ld out of %ld)\r",
         self.numberOfAuthorisedDevices, self.maxNumberOfAuthorisedDevices];
    }
    
    if (self.links.count > 0) {
        for (NSInteger i = 0; i < self.links.count; i++) {
            BBALibraryItemLink *link = self.links[i];
            [string appendFormat:@"link: %ld\r%@\r", i, [link description]];
        }
    }
    
    [string appendFormat:@"----------------------------------------\r"];
    
    return string;
}

@end
