//
//  BBALibraryItem.m
//  BBAAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBALibraryItem.h"

@implementation BBALibraryItem

- (id) init{
    self = [super init];
    if (self) {
        self.readingStatus = BBAReadingStatusUnknown;
        self.purchaseStatus =  BBAPurchaseStatusNothing;
        self.visibilityStatus = BBAVisiblityStatusUnknown;
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

@end
