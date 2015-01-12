//
//  BBACatalogueService.h
//  BBAAPI
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const BBACatalogureErrorDomain;

@class BBABookItem;

@interface BBACatalogueService : NSObject

- (void) getSynopsisForBookItem:(BBABookItem *)item
                     completion:(void (^)(BBABookItem *itemWithSynposis, NSError *error))completion;

- (void) getRelatedBooksForBookItem:(BBABookItem *)item
                              count:(NSUInteger)count
                         completion:(void (^)(NSArray *libraryItems, NSError *error))completion;

- (void) getDetailsForBookItems:(NSArray *)item
                     completion:(void (^)(NSArray *detailItems, NSError *))completion;
@end
