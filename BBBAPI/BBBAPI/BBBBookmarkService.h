//
//  BBBBookmarkService.h
//  BBBAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, BBBBookmarkType) {
    BBBBookmarkTypeAll = 0,
    BBBBookmarkTypeLastReadingPostion = 0 << 1,
    BBBBookmarkTypeBookmark = 0 << 2,
    BBBBookmarkTypeCrossReference = 0 << 3,
    BBBBookmarkTypeHighlight = 0 << 4,
};

@class BBBLibraryItem;
@class BBBBookmarkItem;
@class BBBUserDetails;

@interface BBBBookmarkService : NSObject

- (void) getBookmarkChangesForItem:(BBBLibraryItem *)item
                         afterDate:(NSDate *)date
                         typesMask:(BBBBookmarkType)types
                              user:(BBBUserDetails *)user
                        completion:(void (^)(NSArray *bookmarkChanges, NSData *syncDate, NSError *error))completion;


- (void) deleteBookmarksForItem:(BBBLibraryItem *)item
                      typesMask:(BBBBookmarkType)types
                           user:(BBBUserDetails *)user
                     completion:(void (^)(BOOL success, NSError *error))completion;

- (void) deleteBookmark:(BBBBookmarkItem *)item
                   user:(BBBUserDetails *)user
             completion:(void (^)(BOOL success, NSError *error))completion;

- (void) addBookMark:(BBBBookmarkItem *)item
             forItem:(BBBLibraryItem *)item
                user:(BBBUserDetails *)user
          completion:(void (^)(BBBBookmarkItem *bookmarkItem, NSError *error))completion;

- (void) updateBookMark:(BBBBookmarkItem *)item
                   user:(BBBUserDetails *)user
             completion:(void (^)(BBBBookmarkItem *bookmarkItem, NSError *error))completion;

@end
