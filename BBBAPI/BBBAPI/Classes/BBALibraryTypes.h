//
//  BBALibraryTypes.h
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#ifndef BBAAPI_BBALibraryTypes_h
#define BBAAPI_BBALibraryTypes_h

typedef NS_ENUM(NSInteger, BBAReadingStatus) {
    BBAReadingStatusUnknown = 0,
    BBAReadingStatusReading = 1,
    BBAReadingStatusUnread = 2,
    BBAReadingStatusRead = 3,
};

typedef NS_ENUM(NSInteger, BBAPurchaseStatus) {
    BBAPurchaseStatusNothing = -1,
    BBAPurchaseStatusSampled = 0,
    BBAPurchaseStatusPurchased = 1
};

typedef NS_ENUM(NSInteger, BBAVisiblityStatus) {
    BBAVisiblityStatusUnknown = -1,
    BBAVisiblityStatusCurrent = 0,
    BBAVisiblityStatusArchived = 1,
    BBAVisiblityStatusDeleted = 2
};

typedef NS_ENUM(NSInteger, BBAItemAction) {
    BBAItemActionNoAction = 0,
    BBAItemActionDelete = 1,
    BBAItemActionArchive = 2,
    BBAItemActionUnarchive = 3,
};


#endif
