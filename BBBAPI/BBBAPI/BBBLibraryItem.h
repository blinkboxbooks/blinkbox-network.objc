//
//  BBBLibraryItem.h
//  BBBAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBBLibraryTypes.h"

@class BBBLibraryItemLink;

/**
 *  Object that represents Library Changes Object in the iOS Domain
 */
@interface BBBLibraryItem : NSObject

@property (nonatomic, copy) NSString *isbn;
@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, assign) BBBPurchaseStatus purchaseStatus;
@property (nonatomic, assign) BBBVisiblityStatus visibilityStatus;
@property (nonatomic, assign) BBBReadingStatus readingStatus;

@property (nonatomic, strong) NSDate *purchasedDate;
@property (nonatomic, strong) NSDate *sampledDate;
@property (nonatomic, strong) NSDate *archivedDate;
@property (nonatomic, strong) NSDate *deletedDate;

@property (nonatomic, assign) NSInteger maxNumberOfAuthorisedDevices;
@property (nonatomic, assign) NSInteger numberOfAuthorisedDevices;

/**
 *  Array of `BBBLibraryItemLink` objects
 */
@property (nonatomic, copy) NSArray *links;

@end
