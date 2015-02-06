//
//  BBALibraryResponse.h
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 05/08/2014.
 

#import <Foundation/Foundation.h>
#import "BBALibraryTypes.h"

extern NSString * BBANSStringFromReadingStatus(BBAReadingStatus status);
extern NSString * BBANSStringFromPurchaseStatus(BBAPurchaseStatus status);
extern NSString * BBANSStringFromVisibiliyStatus(BBAVisiblityStatus status);

/**
 *  Object that represents data sent from the server via library service.
 *  It's producing an array of library items and synchronisation date if there is one.
 */
@interface BBALibraryResponse : NSObject

/**
 *  If `parsedJSON` is carrying date information, such as response from  `getChanges`
 *  carries `lastSyncDateTime`, this property contains parsed date. Can be `nil` for other types
 *  for responses.
 */
@property (nonatomic, strong, readonly) NSDate *syncDate;

/**
 *  Array containing `BBALibraryItem`'s objects, can be empty. Will be `nil` if `parsedJSON` cannot
 *  be mapped to library item objects.
 */
@property (nonatomic, copy, readonly) NSArray *changes;

/**
 *  This method validates `parsedJSON` object and it's correct format, maps it to 
 *  `changes` and `syncDate` objects.
 *
 *  @param parsedJSON object to be parsed to library items form, currently expects `NSDictionary`
 *  @param error      address to write error instance in case of data being invalid
 *
 *  @return `YES` if everything went good and `parsedJSON` was mapped correctly, `NO` otherwise.
 */
- (BOOL) parseJSON:(id)parsedJSON error:(NSError **)error;

@end
