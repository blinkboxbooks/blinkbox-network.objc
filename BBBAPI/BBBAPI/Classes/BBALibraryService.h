//
//  BBALibraryService.h
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBALibraryTypes.h"

extern NSString *const BBALibraryServiceErrorDomain;

extern NSString *const BBALibraryServiceName;
extern NSString *const BBAStatusResponseServiceName;

@class BBALibraryItem;
@class BBAUserDetails;

/**
 *  Class represents `Library Service` in the BlinkboxBooks API.
 *  It's documentation can be found at :
 *   http://jira.blinkbox.local/confluence/display/PT/Library+Service+REST+API+Guide
 */
@interface BBALibraryService : NSObject

/**
 *  Method gets `user`'s library changes after `date`. If `date` is `nil`, it returns all
 *  items in the given `user`'s library. If `items` is supplied, method returns changes to
 *  given `BBALibraryItem` objects.
 *  @seealso BBALibraryItem
 *  @seealso BBAUserDetails
 *
 *  @param date       date of the last call of this method or `nil`
 *  @param items      array of `BBALibraryItem` objects
 *  @param user       user represenation, must not be nil
 *  @param completion callback is called on the callers thread, must not be nil
 */
- (void) getChangesAfterDate:(NSDate *)date
                       items:(NSArray *)items
                        user:(BBAUserDetails *)user
                  completion:(void (^)(NSArray *items, NSDate *syncDate, NSError *error))completion;

/**
 *  This method calls `getChangesAfterDate:items:user:completion` with `items` parameter set to `nil`
 *  @seealso getChangesAfterDate:items:user:completion
 *  @seealso NSDate
 *  @seealso BBAUserDetails
 *
 *  @param date       date of the last call of this method or `nil`
 *  @param user       user represenation, must not be nil
 *  @param completion callback is called on the callers thread, must not be nil
 */
- (void) getChangesAfterDate:(NSDate *)date
                        user:(BBAUserDetails *)user
                  completion:(void (^)(NSArray *items, NSDate *syncDate, NSError *error))completion;
/**
 *  This method allows the retrieval of an individual library item.
 *  
 *  @seealso BBAUserDetails
 *
 *  @param item       librarty item to get the details of, must not be nil
 *  @param user       user that owns given library, must not be nil
 *  @param completion called on the caller thread, must not be nil
 */
- (void) getItem:(BBALibraryItem *)item
            user:(BBAUserDetails *)user
      completion:(void (^)(BBALibraryItem *libraryItem, NSError *error))completion;

/**
 *  This method updates reading status to  `status` of a given `item` for specified `user`.
 *  
 *  @seealso BBALibraryItem
 *  @seealso BBAUserDetails
 *
 *  @param status     new reading status
 *  @param item       library item to set the status, must not be `nil`
 *  @param user       the owner of the `library`
 *  @param completion callback that is called on the caller thread
 */
- (void) setReadingStatus:(BBAReadingStatus)status
                     item:(BBALibraryItem *)item
                     user:(BBAUserDetails *)user
               completion:(void (^)(BOOL success, NSError *error))completion;


/**
 *  Retrieves archived items for the user
 *
 *  @param user       owner of the archive
 *  @param completion callback called on the callers thread, must not be `nil`, `items` contains 
 *                    `BBALibraryItem` objects
 */
- (void) getArchivedItemsForUser:(BBAUserDetails *)user
                      completion:(void (^)(NSArray *items, NSError *error))completion;

/**
 *  Retrieves all deleted items for a user
 *
 *  @param user       owner of the library
 *  @param completion callback called on the caller's thread, must not be `nil`. The `items` parameter
 *                    contains `BBALibraryItem` objects
 */
- (void) getDeletedItemsForUser:(BBAUserDetails *)user
                     completion:(void (^)(NSArray *items, NSError *error))completion;
/**
 *  Adds sample `item` to the library of the `user`.
 *
 *  @param item       item to add to the library, must not be `nil`. It's `isbn` must not be `nil`
 *  @param user       owner of the libary
 *  @param completion callback called on the callers thread, cannot be `nil`
 */
- (void) addSampleItem:(BBALibraryItem *)item
                  user:(BBAUserDetails *)user
            completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Deletes a library `item` from `user`'s library. Currently this method works `ONLY` with
 *  `items` that have `purchaseStatus` set to `BBAPurchaseStatusSampled`. For other items, 
 *  method calls completion with failure and error meaning wrong parameter and asserts.
 *
 *  @param item       library item to delete from library, must not be `nil`
 *  @param user       owen of the library
 *  @param completion callback called on the callers queue, must not be `nil`
 */
- (void) deleteItem:(BBALibraryItem *)item
               user:(BBAUserDetails *)user
         completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Adds `item` to the library of the `user`.
 *
 *  @param item       library item to move to archive, must not be `nil`
 *  @param user       owner of the library
 *  @param completion callback called on the caller thread, must not be `nil`
 */
- (void) archiveItem:(BBALibraryItem *)item
                user:(BBAUserDetails *)user
          completion:(void (^)(BOOL success, NSError *error))completion;

/**
 *  Restore a library item from the archive to the current library.
 *
 *  @param item       item to be restored from the archive to library, must not be nil, `identifier`
 *                    must no be `nil` either.
 *  @param user       owner of the library
 *  @param completion callback called on the callers thread, must not be nil
 */
- (void) unarchiveItem:(BBALibraryItem *)item
                  user:(BBAUserDetails *)user
            completion:(void (^)(BOOL success, NSError *error))completion;

@end
