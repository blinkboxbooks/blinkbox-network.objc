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

NSString *const BBACatalogureErrorDomain = @"com.BBB.CatalogueErrorDomain";

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
    
    [connection addParameterWithKey:@"count" value:[@(count) description]];
    
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
    
    BBAConnection *connection = [[BBAConnection alloc] initWithDomain:(BBAAPIDomainREST)
                                                          relativeURL:[self catalogueEndpoint]];
    connection.requiresAuthentication = NO;
    [connection setRequestFactory:[BBARequestFactory new]];
    [connection setResponseMapper:[BBACatalogueResponseMapper new]];
    
    [connection perform:(BBAHTTPMethodGET)
             completion:^(id response, NSError *error) {
                 completion(response, error);
             }];
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

- (NSString *) catalogueEndpoint{
    return @"books/";
}

@end
