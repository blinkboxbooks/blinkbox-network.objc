//
//  BBBLibraryService.h
//  BBBAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBBLibraryTypes.h"

@class BBBLibraryItem;
@class BBBUserDetails;

@interface BBBLibraryService : NSObject

- (void)getChangesAfterDate:(NSDate *)date
                       item:(NSArray *)items
                       user:(BBBUserDetails *)user
                 completion:(void (^)(NSArray *items, NSDate *syncDate, NSError *error))completion;

- (void)getChangesAfterDate:(NSDate *)date
                       user:(BBBUserDetails *)user
                 completion:(void (^)(NSArray *items, NSDate *syncDate, NSError *error))completion;

- (void)getItem:(BBBLibraryItem *)item
           user:(BBBUserDetails *)user
     completion:(void (^)(BBBLibraryItem *updatedItem, NSError *error))completion;

- (void)setReadingStatus:(BBBReadingStatus)status
                    item:(BBBLibraryItem *)item
                    user:(BBBUserDetails *)user
              completion:(void (^)(BOOL success, NSError *error))completion;

- (void)deleteItem:(BBBLibraryItem *)item
              user:(BBBUserDetails *)user
        completion:(void (^)(BOOL success, NSError *error))completion;

- (void)addSampleItem:(BBBLibraryItem *)item
                 user:(BBBUserDetails *)user
           completion:(void (^)(BOOL success, NSError *error))completion;

- (void)archiveItem:(BBBLibraryItem *)item
               user:(BBBUserDetails *)user
         completion:(void (^)(BOOL success, NSError *error))completion;

- (void)unarchiveItem:(BBBLibraryItem *)item
                 user:(BBBUserDetails *)user
           completion:(void (^)(BOOL success, NSError *error))completion;

- (void)getArchivedItemsForUser:(BBBUserDetails *)user
                     completion:(void (^)(NSArray *items, NSError *error))completion;

@end
