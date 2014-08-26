//
//  BBBLibraryItem.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBLibraryItem.h"

@implementation BBBLibraryItem

- (id) init{
    self = [super init];
    if (self) {
        self.readingStatus = BBBReadingStatusUnknown;
        self.purchaseStatus =  BBBPurchaseStatusNothing;
        self.visibilityStatus = BBBVisiblityStatusUnknown;
    }
    return self;
}

- (BOOL) isEqual:(id)object{
    if (![object isKindOfClass:[BBBLibraryItem class]]) {
        return NO;
    }
    
    BBBLibraryItem *item = (BBBLibraryItem *)object;
    BOOL isbnsAreEqual = [self.isbn isEqualToString:item.isbn];
    BOOL idsAreEqual = [self.identifier isEqualToString:item.identifier];
    return isbnsAreEqual && idsAreEqual;
}

- (NSUInteger) hash{
    return [self.isbn integerValue];
}

@end
