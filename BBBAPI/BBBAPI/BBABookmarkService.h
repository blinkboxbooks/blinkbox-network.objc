//
//  BBABookmarkService.h
//  BBAAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, BBABookmarkType) {
    BBABookmarkTypeAll = 0,
    BBABookmarkTypeLastReadingPostion = 0 << 1,
    BBABookmarkTypeBookmark = 0 << 2,
    BBABookmarkTypeCrossReference = 0 << 3,
    BBABookmarkTypeHighlight = 0 << 4,
};

@class BBALibraryItem;
@class BBABookmarkItem;
@class BBAUserDetails;

@interface BBABookmarkService : NSObject

- (void) getBookmarkChangesForItem:(BBALibraryItem *)item
                         afterDate:(NSDate *)date
                         typesMask:(BBABookmarkType)types
                              user:(BBAUserDetails *)user
                        completion:(void (^)(NSArray *bookmarkChanges, NSData *syncDate, NSError *error))completion;


- (void) deleteBookmarksForItem:(BBALibraryItem *)item
                      typesMask:(BBABookmarkType)types
                           user:(BBAUserDetails *)user
                     completion:(void (^)(BOOL success, NSError *error))completion;

- (void) deleteBookmark:(BBABookmarkItem *)item
                   user:(BBAUserDetails *)user
             completion:(void (^)(BOOL success, NSError *error))completion;

- (void) addBookMark:(BBABookmarkItem *)item
             forItem:(BBALibraryItem *)item
                user:(BBAUserDetails *)user
          completion:(void (^)(BBABookmarkItem *bookmarkItem, NSError *error))completion;

- (void) updateBookMark:(BBABookmarkItem *)item
                   user:(BBAUserDetails *)user
             completion:(void (^)(BBABookmarkItem *bookmarkItem, NSError *error))completion;

@end
