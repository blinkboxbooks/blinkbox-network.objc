//
//  BBBLibraryService.h
//  BBBAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBBLibraryTypes.h"

extern NSString *const BBBLibraryServiceErrorDomain;

NS_ENUM(NSInteger, BBBLibraryServiceError){
    BBBLibraryServiceErrorMissingParameters = 190,
    BBBLibraryServiceErrorWrongParameters = 191,
};


@class BBBLibraryItem;
@class BBBUserDetails;

/**
 *  Class represents `Library Service` in the BlinkboxBooks API.
 *  It's documentation can be found at :
 *   http://jira.blinkbox.local/confluence/display/PT/Library+Service+REST+API+Guide
 */
@interface BBBLibraryService : NSObject

/**
 *  Method gets `user`'s library changes after `date`. If `date` is `nil`, it returns all
 *  items in the given `user`'s library. If `items` is supplied, method returns changes to
 *  given `BBBLibraryItem` objects.
 *  @seealso BBBLibraryItem
 *  @seealso BBBUserDetails
 *
 *  @param date       date of the last call of this method or `nil`
 *  @param items      array of `BBBLibraryItem` objects
 *  @param user       user represenation, must not be nil
 *  @param completion callback is called on the callers thread, must not be nil
 */
- (void) getChangesAfterDate:(NSDate *)date
                       items:(NSArray *)items
                        user:(BBBUserDetails *)user
                  completion:(void (^)(NSArray *items, NSDate *syncDate, NSError *error))completion;

/**
 *  This method calls `getChangesAfterDate:items:user:completion` with `items` parameter set to `nil`
 *  @seealso getChangesAfterDate:items:user:completion
 *  @seealso NSDate
 *  @seealso BBBUserDetails
 *
 *  @param date       date of the last call of this method or `nil`
 *  @param user       user represenation, must not be nil
 *  @param completion callback is called on the callers thread, must not be nil
 */
- (void) getChangesAfterDate:(NSDate *)date
                        user:(BBBUserDetails *)user
                  completion:(void (^)(NSArray *items, NSDate *syncDate, NSError *error))completion;
/**
 *  This method allows the retrieval of an individual library item.
 *  
 *  @seealso BBBUserDetails
 *
 *  @param item       librarty item to get the details of, must not be nil
 *  @param user       user that owns given library, must not be nil
 *  @param completion called on the caller thread, must not be nil
 */
- (void) getItem:(BBBLibraryItem *)item
            user:(BBBUserDetails *)user
      completion:(void (^)(BBBLibraryItem *libraryItem, NSError *error))completion;

/**
 *  This method updates reading status to  `status` of a given `item` for specified `user`.
 *  
 *  @seealso BBBLibraryItem
 *  @seealso BBBUserDetails
 *
 *  @param status     new reading status
 *  @param item       library item to set the status, must not be `nil`
 *  @param user       the owner of the `library`
 *  @param completion callback that is called on the caller thread
 */
- (void) setReadingStatus:(BBBReadingStatus)status
                     item:(BBBLibraryItem *)item
                     user:(BBBUserDetails *)user
               completion:(void (^)(BOOL success, NSError *error))completion;


/**
 *  Retrieves archived items for the user
 *
 *  @param user       owner of the archive
 *  @param completion callback called on the callers thread, must not be `nil`, `items` contains 
 *                    `BBBLibraryItem` objects
 */
- (void) getArchivedItemsForUser:(BBBUserDetails *)user
                      completion:(void (^)(NSArray *items, NSError *error))completion;

/**
 *  Retrieves all deleted items for a user
 *
 *  @param user       owner of the library
 *  @param completion callback called on the caller's thread, must not be `nil`. The `items` parameter
 *                    contains `BBBLibraryItem` objects
 */
- (void) getDeletedItemsForUser:(BBBUserDetails *)user
                     completion:(void (^)(NSArray *items, NSError *error))completion;
/**
 *  Adds sample `item` to the library of the `user`.
 *
 *  @param item       item to add to the library, must not be `nil`. It's `isbn` must not be `nil`
 *  @param user       owner of the libary
 *  @param completion callback called on the callers thread, cannot be `nil`
 */
- (void) addSampleItem:(BBBLibraryItem *)item
                  user:(BBBUserDetails *)user
            completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Deletes a library `item` from `user`'s library. Currently this method works `ONLY` with
 *  `items` that have `purchaseStatus` set to `BBBPurchaseStatusSampled`. For other items, 
 *  method calls completion with failure and error meaning wrong parameter and asserts.
 *
 *  @param item       library item to delete from library, must not be `nil`
 *  @param user       owen of the library
 *  @param completion callback called on the callers queue, must not be `nil`
 */
- (void) deleteItem:(BBBLibraryItem *)item
               user:(BBBUserDetails *)user
         completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Adds `item` to the library of the `user`.
 *
 *  @param item       library item to move to archive, must not be `nil`
 *  @param user       owner of the library
 *  @param completion callback called on the caller thread, must not be `nil`
 */
- (void) archiveItem:(BBBLibraryItem *)item
                user:(BBBUserDetails *)user
          completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Restore a library item from the archive to the current library.
 *
 *  @param item       item to be restored from the archive to library, must not be nil, `identifier`
 *                    must no be `nil` either.
 *  @param user       owner of the library
 *  @param completion callback called on the callers thread, must not be nil
 */
- (void) unarchiveItem:(BBBLibraryItem *)item
                  user:(BBBUserDetails *)user
            completion:(void (^)(BOOL success, NSError *error))completion;

@end
