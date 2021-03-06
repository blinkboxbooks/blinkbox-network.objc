//
//  BBABookmarkService.h
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 30/07/2014.
 

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, BBABookmarkType) {
    BBABookmarkTypeAll = 0,
    BBABookmarkTypeLastReadingPostion = 1 << 1,
    BBABookmarkTypeBookmark = 1 << 2,
    BBABookmarkTypeCrossReference = 1 << 3,
    BBABookmarkTypeHighlight = 1 << 4,
    BBABookmarkTypeNote = 1 << 5,
};

extern NSString *const kBBABookmarkServiceErrorDomain;

@class BBALibraryItem;
@class BBABookmarkItem;
@class BBAUserDetails;

/**
 *  The BBABookmarkService provides methods to fetch, create, delete and update bookmarks on the server.
 */
@interface BBABookmarkService : NSObject

/**
 *  Fetch a list of bookmarks from the server.
 *
 *  @param item       The `BBALibraryItem` for which to fetch bookmarks. (Optional).
 *                    If item is specified, bookmarks for this book will be returned. 
 *                    If not, all bookmarks for all books are returned.
 *  @param date       An optional `NSDate` which, if specified, will limit the returned bookmarks to 
 *                    those created AFTER this date.
 *  @param types      `BBABookmarkType` bitmask specifying which bookmarks to fetch (Required)
 *  @param user       `BBAUserDetails` specifying which user to fetch bookmarks for (Optional).
 *                    If not specified, the current user will be used.
 *  @param completion Block invoked on completion of the fetch (Required).
 *                    Completion will return an `NSArray` of `BBABookmarkItem` and an `NSDate`
 *                    describing the time of this bookmark sync, or an `NSError` describing the reason
 *                    for failure
 */
- (void) getBookmarkChangesForItem:(BBALibraryItem *)item
                         afterDate:(NSDate *)date
                         typesMask:(BBABookmarkType)types
                              user:(BBAUserDetails *)user
                        completion:(void (^)(NSArray *bookmarkChanges, NSDate *syncDate, NSError *error))completion;

/**
 *  Delete all bookmarks from the server for this book.
 *
 *  @param item       The `BBALibraryItem` for which to delete bookmarks (Required)
 *  @param types      `BBABookmarkType` bitmask specifying which bookmarks to fetch (Required)
 *  @param user       `BBAUserDetails` specifying which user to fetch bookmarks for (Optional).
 *                    If not specified, the current user will be used.
 *  @param completion Block invoked on completion of the fetch (Required).
 *                    Completion will return a `BOOL` success, if success is `NO` an `NSError` is
 *                    returned detailing the reason for failure
 */
- (void) deleteBookmarksForItem:(BBALibraryItem *)item
                      typesMask:(BBABookmarkType)types
                           user:(BBAUserDetails *)user
                     completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Delete a bookmark from the server.
 *
 *  @param item       The `BBABookmarkItem` which to delete (Required)
 *  @param user       `BBAUserDetails` specifying which user to delete bookmarks for (Optional).
 *                    If not specified, the current user will be used.
 *  @param completion Block invoked on completion of the fetch (Required).
 *                    Completion will return a `BOOL` success, if success is `NO` an `NSError` is
 *                    returned detailing the reason for failure
 */
- (void) deleteBookmark:(BBABookmarkItem *)item
                   user:(BBAUserDetails *)user
             completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Create a bookmark on the server.
 *
 *  @param bookmark   `BBABookmarkItem` to create on the server. (Required)
 *  @param item       `BBALibraryItem` representing the book that these bookmarks are part of (Required)
 *  @param user       `BBAUserDetails` specifying which user to create the bookmark for (Optional).
 *                    If not specified, the current user will be used.
 *  @param completion Block invoked on completion of the fetch (Required).
 *                    Completion will return a `BBABookmarkItem` if successful, or an `NSError` is
 *                    returned detailing the reason for failure
 */
- (void) addBookMark:(BBABookmarkItem *)bookmark
             forItem:(BBALibraryItem *)item
                user:(BBAUserDetails *)user
          completion:(void (^)(BBABookmarkItem *bookmarkItem, NSError *error))completion;

/**
 *  Update a bookmark on the server, for example, changing the colour of a higlight.
 *
 *  @param item       `BBABookmarkItem` to update on the server. (Required)
 *  @param user       `BBAUserDetails` specifying which user to update the bookmark for (Optional).
 *                    If not specified, the current user will be used.
 *  @param completion Block invoked on completion of the fetch (Required).
 *                    Completion will return a `BOOL` success, if success is `NO` an `NSError` is
 *                    returned detailing the reason for failure
 */
- (void) updateBookMark:(BBABookmarkItem *)item
                   user:(BBAUserDetails *)user
             completion:(void (^)(BOOL success, NSError *error))completion;

@end
