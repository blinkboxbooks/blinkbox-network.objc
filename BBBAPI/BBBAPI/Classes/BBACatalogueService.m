//
//  BBACatalogueService.m
//  BBAAPI
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBACatalogueService.h"
#import "BBABookItem.h"
#import "BBAConnection.h"
#import "BBAAPIErrors.h"
#import "BBARequestFactory.h"
#import "BBACatalogueResponseMapper.h"
#import <NSArray+Functional.h>

NSString *const BBACatalogueErrorDomain = @"com.BBB.CatalogueErrorDomain";

@implementation BBACatalogueService

#pragma mark - Public

- (void) getSynopsisForBookItem:(BBABookItem *)item
                     completion:(void (^)(BBABookItem *itemWithSynposis, NSError *error))completion{
    NSParameterAssert(completion);
    if (!completion) {
        return;
    }
    
    NSParameterAssert(item.identifier);
    if (!item.identifier) {
        completion(nil, [self wrongUsageError]);
        return;
    }
    
    NSString *endpoint = [NSString stringWithFormat:@"catalogue/books/%@/synopsis", item.identifier];
    
    BBAConnection *connection = [[BBAConnection alloc] initWithDomain:(BBAAPIDomainREST)
                                                          relativeURL:endpoint];
    connection.requiresAuthentication = NO;
    [connection setRequestFactory:[BBARequestFactory new]];
    [connection setResponseMapper:[BBACatalogueResponseMapper new]];
    
    [connection perform:(BBAHTTPMethodGET)
             completion:^(id response, NSError *error) {
                 completion(response, error);
             }];
}

- (void) getRelatedBooksForBookItem:(BBABookItem *)item
                              count:(NSUInteger)count
                         completion:(void (^)(NSArray *libraryItems, NSError *error))completion{
    NSParameterAssert(completion);
    if (!completion) {
        return;
    }
    
    NSParameterAssert(item.identifier);
    if (!item.identifier) {
        completion(nil, [self wrongUsageError]);
        return;
    }
    
    NSString *endpoint = [NSString stringWithFormat:@"catalogue/books/%@/related", item.identifier];
    
    BBAConnection *connection = [[BBAConnection alloc] initWithDomain:(BBAAPIDomainREST)
                                                          relativeURL:endpoint];
    connection.requiresAuthentication = NO;
    [connection setRequestFactory:[BBARequestFactory new]];
    [connection setResponseMapper:[BBACatalogueResponseMapper new]];
    
    NSUInteger countToSend = MAX(1, count);
    
    [connection addParameterWithKey:@"count" value:[@(countToSend) description]];
    
    [connection perform:(BBAHTTPMethodGET)
             completion:^(id response, NSError *error) {
                 completion(response, error);
             }];
}

- (void) getDetailsForBookItems:(NSArray *)items
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
    
    NSArray *isbnsGroups = [self isbnGroupsFromItems:items];
    
    dispatch_group_t serviceGroup = dispatch_group_create();
    dispatch_queue_t arrayQueue = dispatch_queue_create("com.bba.catalogue.array", DISPATCH_QUEUE_SERIAL);
    NSMutableArray *results = [NSMutableArray new];
    __block NSError *errorResult = nil;
    
    for (NSArray *group in isbnsGroups) {
        dispatch_group_enter(serviceGroup);
        
        BBAConnection *connection = [self newConnection];
        [connection addParameterWithKey:@"id" arrayValue:group];
        
        [connection perform:(BBAHTTPMethodGET)
                 completion:^(NSArray *responseItems, NSError *error) {
                     dispatch_async(arrayQueue, ^{
                         
                         if (!responseItems) {
                             errorResult = error;
                         }
                         
                         [results addObjectsFromArray:responseItems];
                         dispatch_group_leave(serviceGroup);
                     });
                 }];
    }
    
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        
        if (errorResult) {
            completion(nil, errorResult);
            return ;
        }
        
        NSArray *filteredResults = [self resultsFromServer:results input:items];
        
        completion(filteredResults, nil);
    });
}

#pragma mark - Private

- (NSArray *) resultsFromServer:(NSArray *)serverResults input:(NSArray *)inputItems{
    
    
    /*
     This method generate mapping isbn -> index in the input array 
     and then enumarates server results, constructs new array to make
     sure that books are return in the same order as they came in, filtering
     not returned results and the end
     */
    
    NSMutableArray *detailedItems = [[inputItems mapUsingBlock:^id(id obj) {
        return [NSNull null];
    }] mutableCopy];
    
    NSDictionary *mapping = [self indexToISBNFromItems:inputItems];
    
    for (BBABookItem *item in serverResults) {
        NSInteger index = [mapping[item.identifier] integerValue];
        
        [detailedItems replaceObjectAtIndex:index withObject:item];
    }
    
    NSArray *onlyBooks = [detailedItems filterUsingBlock:^BOOL(id obj) {
        return [obj isKindOfClass:[BBABookItem class]];
    }];
    
    return onlyBooks;
    
}

- (NSDictionary *) indexToISBNFromItems:(NSArray *)items{
    
    NSMutableDictionary *mappings = [NSMutableDictionary new];
    
    for (NSInteger i = 0; i < items.count; i++) {
        BBABookItem *item = items[i];
        mappings[item.identifier]= @(i);
    }

    return mappings;
}

- (BBAConnection *) newConnection{
    BBAConnection *connection = [[BBAConnection alloc] initWithDomain:(BBAAPIDomainREST)
                                                          relativeURL:@"catalogue/books"];
    connection.requiresAuthentication = NO;
    [connection setRequestFactory:[BBARequestFactory new]];
    [connection setResponseMapper:[BBACatalogueResponseMapper new]];
    return connection;
}

- (NSArray *) isbnGroupsFromItems:(NSArray *)items{
    NSArray *isbns = [items valueForKeyPath:NSStringFromSelector(@selector(identifier))];
    
    const NSInteger itemMax = 50;
    
    NSMutableArray *arrayOfArrays = [NSMutableArray array];
    
    NSInteger itemsRemaining = [isbns count];
    NSInteger j = 0;
    
    while(j < [isbns count]) {
        
        NSRange range = NSMakeRange(j, MIN(itemMax, itemsRemaining));
        
        NSArray *subarray = [isbns subarrayWithRange:range];
        [arrayOfArrays addObject:subarray];
        
        itemsRemaining -= range.length;
        j += range.length;
    }
    
    return  arrayOfArrays;
}

- (NSError *) wrongUsageError{
    NSError *error = [NSError errorWithDomain:BBACatalogueErrorDomain
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
    
    for (BBABookItem *item in items) {
        if (![item isKindOfClass:[BBABookItem class]]) {
            return NO;
        }
        
        if (!item.identifier) {
            return NO;
        }
    }
    
    return YES;
}


@end
