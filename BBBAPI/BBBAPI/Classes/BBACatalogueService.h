//
//  BBACatalogueService.h
//  BBAAPI
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const BBACatalogureErrorDomain;

@class BBALibraryItem;

@interface BBACatalogueService : NSObject

- (void) getSynopsisForLibraryItem:(BBALibraryItem *)item
                        completion:(void (^)(BBALibraryItem *itemWithSynposis, NSError *error))completion;

- (void) getRelatedBooksForLibraryItem:(BBALibraryItem *)item
                            completion:(void (^)(NSArray *libraryItems, NSError *error))completion;

- (void) getDetailsForLibraryItems:(NSArray *)item
                        completion:(void (^)(NSArray *detailItems, NSError *))completion;
@end
