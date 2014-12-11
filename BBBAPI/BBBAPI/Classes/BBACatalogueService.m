//
//  BBACatalogueService.m
//  BBAAPI
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBACatalogueService.h"
#import "BBALibraryItem.h"
#import "BBAConnection.h"
#import "BBAAPIErrors.h"

NSString *const BBACatalogureErrorDomain = @"com.BBB.CatalogueErrorDomain";

@implementation BBACatalogueService

#pragma mark - Public

- (void) getSynopsisForLibraryItem:(BBALibraryItem *)item
                        completion:(void (^)(BBALibraryItem *itemWithSynposis, NSError *error))completion{
    NSParameterAssert(completion);
    if (!completion) {
        return;
    }
    
    NSParameterAssert(item.isbn);
    if (!item.isbn) {
        completion(nil, [self wrongUsageError]);
        return;
    }
}

- (void) getRelatedBooksForLibraryItem:(BBALibraryItem *)item
                            completion:(void (^)(NSArray *libraryItems, NSError *error))completion{
    NSParameterAssert(completion);
    if (!completion) {
        return;
    }
    
    NSParameterAssert(item.isbn);
    if (!item.isbn) {
        completion(nil, [self wrongUsageError]);
        return;
    }
    
    
}

- (void) getDetailsForLibraryItems:(NSArray *)items
                        completion:(void (^)(NSArray *detailItems, NSError *))completion{
    NSParameterAssert(completion);
    if (!completion) {
        return;
    }
    
    BOOL itemsOk = [self checkItemsArray:items];
    NSParameterAssert(itemsOk);
    if (!itemsOk) {
        completion(nil, [self  wrongUsageError]);
        return;
    }
}

#pragma mark - Private

- (NSError *) wrongUsageError{
    NSError *error = [NSError errorWithDomain:BBACatalogureErrorDomain
                                         code:BBAAPIWrongUsage
                                     userInfo:nil];
    return error;
}

- (BOOL) checkItemsArray:(NSArray *)items{
    NSParameterAssert(items);
    if (!items) {
        return NO;
    }
    
    BOOL classOk = [items isKindOfClass:[NSArray class]];
    NSParameterAssert(classOk);
    if (!classOk) {
        return NO;
    }
    
    for (BBALibraryItem *item in items) {
        if (![item isKindOfClass:[BBALibraryItem class]]) {
            return NO;
        }
        
        if (!item.isbn) {
            return NO;
        }
    }
    
    return YES;
}

@end
