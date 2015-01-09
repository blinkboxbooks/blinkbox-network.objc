//
//  BBALibraryItem.h
//  BBAAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBALibraryTypes.h"

@class BBAItemLink;

/**
 *  Object that represents Library Changes Object in the iOS Domain
 */
@interface BBALibraryItem : NSObject

@property (nonatomic, copy) NSString *isbn;
@property (nonatomic, copy) NSString *guid;
@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, assign) BBAPurchaseStatus purchaseStatus;
@property (nonatomic, assign) BBAVisiblityStatus visibilityStatus;
@property (nonatomic, assign) BBAReadingStatus readingStatus;

@property (nonatomic, strong) NSDate *purchasedDate;
@property (nonatomic, strong) NSDate *sampledDate;
@property (nonatomic, strong) NSDate *archivedDate;
@property (nonatomic, strong) NSDate *deletedDate;

@property (nonatomic, assign) NSInteger maxNumberOfAuthorisedDevices;
@property (nonatomic, assign) NSInteger numberOfAuthorisedDevices;

@property (nonatomic, copy) NSString *synopsis;

/**
 *  Array of `BBALibraryItemLink` objects
 */
@property (nonatomic, copy) NSArray *links;

/**
 *  Method below enumarate `link` array to find link related to given item
 */
@property (nonatomic, copy, readonly) NSString *fullMediaURL;
@property (nonatomic, copy, readonly) NSString *mediaKeyURL;
@property (nonatomic, copy, readonly) NSString *sampleMediaURL;

@end
