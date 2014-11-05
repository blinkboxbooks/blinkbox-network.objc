//
//  BBALibraryService.m
//  BBAAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBALibraryService.h"
#import "BBAConnection.h"
#import "BBALibraryItem.h"
#import "BBAServerDateFormatter.h"
#import "BBALibraryResponse.h"
#import "BBAMacros.h"
#import "BBALibraryResponse.h"
#import "BBAStatusResponseMapper.h"
#import "BBALibraryResponseMapper.h"
#import "BBAAPIErrors.h"

NSString *const BBALibraryServiceErrorDomain = @"BBA.error.libraryServiceDomain";

@interface BBALibraryService ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, copy, readonly) NSString *libraryEndpoint;

@end

@implementation BBALibraryService

#pragma mark - Public

- (void) getChangesAfterDate:(NSDate *)date
                        user:(BBAUserDetails *)user
                  completion:(void (^)(NSArray *items, NSDate *syncDate, NSError *error))completion{
    [self getChangesAfterDate:date items:nil user:user completion:completion];
}

- (void) getChangesAfterDate:(NSDate *)date
                       items:(NSArray *)items
                        user:(BBAUserDetails *)user
                  completion:(void (^)(NSArray *items, NSDate *syncDate, NSError *error))completion{
    
    NSParameterAssert(completion);
    NSParameterAssert(user);
    
    if (!completion){
        return;
    }
    
    if(!user) {
        completion(nil,nil,[self missingParameterError]);
        return;
    }
    
    BBAConnection *connection = [[BBAConnection alloc] initWithDomain:(BBAAPIDomainREST)
                                                          relativeURL:[self libraryEndpoint]];
    
    connection.responseMapper = [BBALibraryResponseMapper new];
    
    if (date) {
        
        NSString *syncDateString = [self.dateFormatter stringFromDate:date];
        
        [connection addParameterWithKey:@"lastSyncDate" value:syncDateString];
    }
    
    if ([items count] > 0) {
        NSArray *value = [items valueForKeyPath:NSStringFromSelector(@selector(isbn))];
        [connection addParameterWithKey:@"book" arrayValue:value];
    }
    
    
    [connection perform:(BBAHTTPMethodGET)
                forUser:user
             completion:^(BBALibraryResponse *response, NSError *error) {
                 completion(response.changes, response.syncDate, error);
             }];
    
}

- (void) getItem:(BBALibraryItem *)item
            user:(BBAUserDetails *)user
      completion:(void (^)(BBALibraryItem *libraryItem, NSError *error))completion{
    NSParameterAssert(completion);
    
    NSParameterAssert(item);
    NSParameterAssert(user);
    
    if (!item || !user) {
        completion(nil, [self missingParameterError]);
        return;
    }
    
    NSAssert(item.identifier, @"item has to have identifier");
    
    NSString *relativeURL = [[self libraryEndpoint] stringByAppendingPathComponent:item.identifier];
    
    BBAConnection *connection = [[BBAConnection alloc] initWithDomain:(BBAAPIDomainREST)
                                                          relativeURL:relativeURL];
    
    connection.responseMapper = [BBALibraryResponseMapper new];
    
    [connection perform:(BBAHTTPMethodGET)
                forUser:user
             completion:^(BBALibraryResponse *response, NSError *error) {
                 completion([response.changes firstObject], error);
             }];
    
}

- (void) setReadingStatus:(BBAReadingStatus)status
                     item:(BBALibraryItem *)item
                     user:(BBAUserDetails *)user
               completion:(void (^)(BOOL success, NSError *error))completion{
    NSParameterAssert(completion);
    
    NSParameterAssert(item);
    NSParameterAssert(user);
    NSAssert(item.identifier, @"item must have an identifier");
    if (!item || !user) {
        completion(NO, [self missingParameterError]);
        return;
    }
    
    
    NSString *relativeURL = [[self libraryEndpoint] stringByAppendingPathComponent:item.identifier];
    
    BBAConnection *connection = [[BBAConnection alloc] initWithDomain:(BBAAPIDomainREST)
                                                          relativeURL:relativeURL];
    
    connection.contentType = BBAContentTypeJSON;
    
    connection.responseMapper = [BBAStatusResponseMapper new];
    
    NSString *newStatus = BBANSStringFromReadingStatus(status);
    
    [connection addParameterWithKey:@"readingStatus" value:newStatus];
    
    [connection perform:(BBAHTTPMethodPUT)
                forUser:user
             completion:^(NSNumber *success, NSError *error) {
                 BBABlockAssert([success isKindOfClass:[NSNumber class]] || !success,
                                @"we expect number here");
                 completion([success boolValue], error);
             }];
}

- (void) performAction:(BBAItemAction)action
                onItem:(BBALibraryItem *)item
                  user:(BBAUserDetails *)user
            completion:(void (^)(BOOL success, NSError *error))completion{
    NSParameterAssert(completion);
    
    NSParameterAssert(item);
    NSAssert(item.identifier, @"We need identifier to perform acttion");
    
    if (!item || !item.identifier) {
        completion(NO, [self missingParameterError]);
        return;
    }
    
    if (action == BBAItemActionNoAction) {
        return;
    }
    
    if (action == BBAItemActionDelete) {
        NSAssert(item.purchaseStatus == BBAPurchaseStatusSampled, @"currently supporting only sample books");
        if (item.purchaseStatus != BBAPurchaseStatusSampled) {
            NSError *error = [NSError errorWithDomain:BBALibraryServiceErrorDomain
                                                 code:BBAAPIWrongUsage
                                             userInfo:nil];
            completion(NO, error);
            return;
        }
    }
    
    
    NSString *relativeURL = [self relativeURLForAction:action item:item];
    
    BBAConnection *connection = [[BBAConnection alloc] initWithDomain:(BBAAPIDomainREST)
                                                          relativeURL:relativeURL];
    BBAHTTPMethod method = [self methodForAction:action];
    
    connection.contentType = BBAContentTypeJSON;
    
    connection.responseMapper = [BBAStatusResponseMapper new];
    
    if (action == BBAItemActionArchive || action == BBAItemActionUnarchive) {
        [connection addParameterWithKey:@"libraryItemId" value:item.identifier];
    }
    
    [connection perform:method
                forUser:user
             completion:^(NSNumber *response, NSError *error) {
                 BBABlockAssert([response isKindOfClass:[NSNumber class]] || !response,
                                @"must be a number of nil");
                 completion([response boolValue], error);
             }];
    
}

- (void) deleteItem:(BBALibraryItem *)item
               user:(BBAUserDetails *)user
         completion:(void (^)(BOOL success, NSError *error))completion{
    [self performAction:(BBAItemActionDelete)
                 onItem:item
                   user:user
             completion:completion];
}

- (void) archiveItem:(BBALibraryItem *)item
                user:(BBAUserDetails *)user
          completion:(void (^)(BOOL success, NSError *error))completion{
    [self performAction:(BBAItemActionArchive)
                 onItem:item
                   user:user
             completion:completion];
}

- (void) unarchiveItem:(BBALibraryItem *)item
                  user:(BBAUserDetails *)user
            completion:(void (^)(BOOL success, NSError *error))completion{
    [self performAction:(BBAItemActionUnarchive)
                 onItem:item
                   user:user
             completion:completion];
}

- (void) addSampleItem:(BBALibraryItem *)item
                  user:(BBAUserDetails *)user
            completion:(void (^)(BOOL success, NSError *error))completion{
    NSParameterAssert(completion);
    NSAssert(item.isbn, @"item mustn't be nil");
    
    if (!item.isbn) {
        completion(NO, [self missingParameterError]);
        return;
    }
    
    NSString *relativeURL = [[self libraryEndpoint] stringByAppendingPathComponent:@"samples"];
    
    BBAConnection *connection = [[BBAConnection alloc] initWithDomain:(BBAAPIDomainREST)
                                                          relativeURL:relativeURL];
    
    connection.contentType = BBAContentTypeJSON;
    
    connection.responseMapper = [BBAStatusResponseMapper new];
    
    [connection addParameterWithKey:@"isbn" value:item.isbn];
    
    [connection perform:(BBAHTTPMethodPOST)
                forUser:user
             completion:^(NSNumber *response, NSError *error) {
                 NSAssert([response isKindOfClass:[NSNumber class]] || !response,
                          @"must be a number or nil");
                 completion([response boolValue], error);
             }];
}

- (void) getArchivedItemsForUser:(BBAUserDetails *)user
                      completion:(void (^)(NSArray *items, NSError *error))completion{
    NSParameterAssert(completion);
    NSString *relativeURL = [self.libraryEndpoint stringByAppendingPathComponent:@"archived"];
    BBAConnection *connection = [[BBAConnection alloc] initWithDomain:(BBAAPIDomainREST)
                                                          relativeURL:relativeURL];
    
    connection.responseMapper = [BBALibraryResponseMapper new];
    [connection perform:(BBAHTTPMethodGET)
                forUser:user
             completion:^(BBALibraryResponse *response, NSError *error) {
                 completion(response.changes,nil);
                }];
}

- (void) getDeletedItemsForUser:(BBAUserDetails *)user
                     completion:(void (^)(NSArray *items, NSError *error))completion{
    NSParameterAssert(completion);
    NSString *relativeURL = [self.libraryEndpoint stringByAppendingPathComponent:@"deleted"];
    BBAConnection *connection = [[BBAConnection alloc] initWithDomain:(BBAAPIDomainREST)
                                                          relativeURL:relativeURL];
    
    connection.responseMapper = [BBALibraryResponseMapper new];
    
    [connection perform:(BBAHTTPMethodGET)
                forUser:user
             completion:^(BBALibraryResponse *response, NSError *error) {
                 completion(response.changes,nil);
             }];
}

#pragma mark - Getters

- (NSDateFormatter *) dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter = [BBAServerDateFormatter new];
    }
    return _dateFormatter;
}

#pragma mark - Private

- (NSError *) missingParameterError{
    NSError *error;
    
    error = [NSError errorWithDomain:BBALibraryServiceErrorDomain
                                code:BBAAPIWrongUsage
                            userInfo:nil];
    return error;
}

- (NSString *) libraryEndpoint{
    return @"service/my/library";
}

- (BBAHTTPMethod) methodForAction:(BBAItemAction)action{
    switch (action) {
        case BBAItemActionDelete:{
            return BBAHTTPMethodDELETE;
            break;
        }
        case BBAItemActionArchive:{
            return BBAHTTPMethodPOST;
            break;
        }
        case BBAItemActionUnarchive:{
            return BBAHTTPMethodPOST;
            break;
        }
        default:
            NSAssert(NO, @"unexpected aciton");
            return BBAHTTPMethodGET;
            break;
    }
}

- (NSString *) relativeURLForAction:(BBAItemAction)action item:(BBALibraryItem *)item{
    NSAssert(item.identifier, @"item has to exist and have identifer");
    NSAssert(self.libraryEndpoint, @"library endpoint must not be nil");
    switch (action) {
        case BBAItemActionDelete:{
            return [self.libraryEndpoint stringByAppendingPathComponent:item.identifier];
            break;
        }
        case BBAItemActionArchive:{
            return [self.libraryEndpoint stringByAppendingPathComponent:@"archived"];
            break;
        }
        case BBAItemActionUnarchive:{
            return [self.libraryEndpoint stringByAppendingPathComponent:@"current"];
            break;
        }
        default:
            NSAssert(NO, @"unexcpected action");
            break;
    }
    return nil;
}

@end
