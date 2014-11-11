//
//  BBABookmarkService.m
//  BBAAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBABookmarkService.h"

@implementation BBABookmarkService
- (void) getBookmarkChangesForItem:(BBALibraryItem *)item
                         afterDate:(NSDate *)date
                         typesMask:(BBABookmarkType)types
                              user:(BBAUserDetails *)user
                        completion:(void (^)(NSArray *bookmarkChanges, NSData *syncDate, NSError *error))completion{
    
}


- (void) deleteBookmarksForItem:(BBALibraryItem *)item
                      typesMask:(BBABookmarkType)types
                           user:(BBAUserDetails *)user
                     completion:(void (^)(BOOL success, NSError *error))completion{
    
}

- (void) deleteBookmark:(BBABookmarkItem *)item
                   user:(BBAUserDetails *)user
             completion:(void (^)(BOOL success, NSError *error))completion{
    
}

- (void) addBookMark:(BBABookmarkItem *)bookmark
             forItem:(BBALibraryItem *)item
                user:(BBAUserDetails *)user
          completion:(void (^)(BBABookmarkItem *bookmarkItem, NSError *error))completion{
    
}

- (void) updateBookMark:(BBABookmarkItem *)item
                   user:(BBAUserDetails *)user
             completion:(void (^)(BBABookmarkItem *bookmarkItem, NSError *error))completion{
    
}
@end
