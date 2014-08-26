//
//  BBBLibraryTypes.h
//  BBBAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#ifndef BBBAPI_BBBLibraryTypes_h
#define BBBAPI_BBBLibraryTypes_h

typedef NS_ENUM(NSInteger, BBBReadingStatus) {
    BBBReadingStatusUnknown = 0,
    BBBReadingStatusReading = 1,
    BBBReadingStatusUnread = 2,
    BBBReadingStatusRead = 3,
};

typedef NS_ENUM(NSInteger, BBBPurchaseStatus) {
    BBBPurchaseStatusNothing = -1,
    BBBPurchaseStatusSampled = 0,
    BBBPurchaseStatusPurchased = 1
};

typedef NS_ENUM(NSInteger, BBBVisiblityStatus) {
    BBBVisiblityStatusUnknown = -1,
    BBBVisiblityStatusCurrent = 0,
    BBBVisiblityStatusArchived = 1,
    BBBVisiblityStatusDeleted = 2
};

typedef NS_ENUM(NSInteger, BBBItemAction) {
    BBBItemActionNoAction = 0,
    BBBItemActionDelete = 1,
    BBBItemActionArchive = 2,
    BBBItemActionUnarchive = 3,
};


#endif
