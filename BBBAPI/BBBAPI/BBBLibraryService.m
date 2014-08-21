//
//  BBBLibraryService.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBLibraryService.h"
#import "BBBConnection.h"
#import "BBBLibraryItem.h"
#import "BBBServerDateFormatter.h"
#import "BBBLibraryResponse.h"
#import "BBBMacros.h"
#import "BBBLibraryResponse.h"
#import "BBBStatusResponseMapper.h"
#import "BBBLibraryResponseMapper.h"

NSString *const BBBLibraryServiceErrorDomain = @"bbb.error.libraryServiceDomain";

@interface BBBLibraryService ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, copy, readonly) NSString *libraryEndpoint;

@end

@implementation BBBLibraryService

#pragma mark - Public

- (void) getChangesAfterDate:(NSDate *)date
                        user:(BBBUserDetails *)user
                  completion:(void (^)(NSArray *items, NSDate *syncDate, NSError *error))completion{
    [self getChangesAfterDate:date items:nil user:user completion:completion];
}

- (void) getChangesAfterDate:(NSDate *)date
                       items:(NSArray *)items
                        user:(BBBUserDetails *)user
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
    
    BBBConnection *connection = [[BBBConnection alloc] initWithDomain:(BBBAPIDomainREST)
                                                          relativeURL:[self libraryEndpoint]];
    
    connection.responseMapper = [BBBLibraryResponseMapper new];
    
    if (date) {
        
        NSString *syncDateString = [self.dateFormatter stringFromDate:date];
        
        [connection addParameterWithKey:@"lastSyncDate" value:syncDateString];
    }
    
    if ([items count] > 0) {
        NSArray *value = [items valueForKeyPath:NSStringFromSelector(@selector(isbn))];
        [connection addParameterWithKey:@"book" arrayValue:value];
    }
    
    [connection perform:(BBBHTTPMethodGET)
             completion:^(BBBLibraryResponse *response, NSError *error) {
                 completion(response.changes, response.syncDate, error);
             }];
    
}

- (void) getItem:(BBBLibraryItem *)item
            user:(BBBUserDetails *)user
      completion:(void (^)(BBBLibraryItem *libraryItem, NSError *error))completion{
    NSParameterAssert(completion);
    
    NSParameterAssert(item);
    NSParameterAssert(user);
    
    if (!item || !user) {
        completion(nil, [self missingParameterError]);
        return;
    }
    
    NSAssert(item.identifier, @"item has to have identifier");
    
    NSString *relativeURL = [[self libraryEndpoint] stringByAppendingPathComponent:item.identifier];
    
    BBBConnection *connection = [[BBBConnection alloc] initWithDomain:(BBBAPIDomainREST)
                                                          relativeURL:relativeURL];
    
    connection.responseMapper = [BBBLibraryResponseMapper new];
    
    [connection perform:(BBBHTTPMethodGET)
                forUser:user
             completion:^(BBBLibraryResponse *response, NSError *error) {
                 completion([response.changes firstObject], error);
             }];
    
}

- (void) setReadingStatus:(BBBReadingStatus)status
                     item:(BBBLibraryItem *)item
                     user:(BBBUserDetails *)user
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
    
    BBBConnection *connection = [[BBBConnection alloc] initWithDomain:(BBBAPIDomainREST)
                                                          relativeURL:relativeURL];
    
    connection.contentType = BBBContentTypeJSON;
    
    connection.responseMapper = [BBBStatusResponseMapper new];
    
    NSString *newStatus = BBBNSStringFromBBBReadingStatus(status);
    
    [connection addParameterWithKey:@"readingStatus" value:newStatus];
    
    [connection perform:(BBBHTTPMethodPUT)
                forUser:user
             completion:^(NSNumber *success, NSError *error) {
                 BBBBlockAssert([success isKindOfClass:[NSNumber class]] || !success,
                                @"we expect number here");
                 completion([success boolValue], error);
             }];
}

- (void) performAction:(BBBItemAction)action
                onItem:(BBBLibraryItem *)item
                  user:(BBBUserDetails *)user
            completion:(void (^)(BOOL success, NSError *error))completion{
    NSParameterAssert(completion);
    
    NSParameterAssert(item);
    NSAssert(item.identifier, @"We need identifier to perform acttion");
    
    if (!item || !item.identifier) {
        completion(NO, [self missingParameterError]);
        return;
    }
    
    if (action == BBBItemActionNoAction) {
        return;
    }
    
    if (action == BBBItemActionDelete) {
        NSAssert(item.purchaseStatus == BBBPurchaseStatusSampled, @"currently supporting only sample books");
        if (item.purchaseStatus != BBBPurchaseStatusSampled) {
            NSError *error = [NSError errorWithDomain:BBBLibraryServiceErrorDomain
                                                 code:BBBLibraryServiceErrorWrongParameters
                                             userInfo:nil];
            completion(NO, error);
            return;
        }
    }
    
    
    NSString *relativeURL = [self relativeURLForAction:action item:item];
    
    BBBConnection *connection = [[BBBConnection alloc] initWithDomain:(BBBAPIDomainREST)
                                                          relativeURL:relativeURL];
    BBBHTTPMethod method = [self methodForAction:action];
    
    connection.contentType = BBBContentTypeJSON;
    
    connection.responseMapper = [BBBStatusResponseMapper new];
    
    if (action == BBBItemActionArchive || action == BBBItemActionUnarchive) {
        [connection addParameterWithKey:@"libraryItemId" value:item.identifier];
    }
    
    [connection perform:method
                forUser:user
             completion:^(NSNumber *response, NSError *error) {
                 BBBBlockAssert([response isKindOfClass:[NSNumber class]] || !response,
                                @"must be a number of nil");
                 completion([response boolValue], error);
             }];
    
}

- (void) deleteItem:(BBBLibraryItem *)item
               user:(BBBUserDetails *)user
         completion:(void (^)(BOOL success, NSError *error))completion{
    [self performAction:(BBBItemActionDelete)
                 onItem:item
                   user:user
             completion:completion];
}

- (void) archiveItem:(BBBLibraryItem *)item
                user:(BBBUserDetails *)user
          completion:(void (^)(BOOL success, NSError *error))completion{
    [self performAction:(BBBItemActionArchive)
                 onItem:item
                   user:user
             completion:completion];
}

- (void) unarchiveItem:(BBBLibraryItem *)item
                  user:(BBBUserDetails *)user
            completion:(void (^)(BOOL success, NSError *error))completion{
    [self performAction:(BBBItemActionUnarchive)
                 onItem:item
                   user:user
             completion:completion];
}

- (void) addSampleItem:(BBBLibraryItem *)item
                  user:(BBBUserDetails *)user
            completion:(void (^)(BOOL success, NSError *error))completion{
    NSParameterAssert(completion);
    NSAssert(item.isbn, @"item mustn't be nil");
    
    if (!item.isbn) {
        completion(NO, [self missingParameterError]);
        return;
    }
    
    NSString *relativeURL = [[self libraryEndpoint] stringByAppendingPathComponent:@"samples"];
    
    BBBConnection *connection = [[BBBConnection alloc] initWithDomain:(BBBAPIDomainREST)
                                                          relativeURL:relativeURL];
    
    connection.contentType = BBBContentTypeJSON;
    
    connection.responseMapper = [BBBStatusResponseMapper new];
    
    [connection addParameterWithKey:@"isbn" value:item.isbn];
    
    [connection perform:(BBBHTTPMethodPOST)
                forUser:user
             completion:^(NSNumber *response, NSError *error) {
                 NSAssert([response isKindOfClass:[NSNumber class]] || !response,
                          @"must be a number or nil");
                 completion([response boolValue], error);
             }];
}

- (void) getArchivedItemsForUser:(BBBUserDetails *)user
                      completion:(void (^)(NSArray *items, NSError *error))completion{
    NSParameterAssert(completion);
    NSString *relativeURL = [self.libraryEndpoint stringByAppendingPathComponent:@"archived"];
    BBBConnection *connection = [[BBBConnection alloc] initWithDomain:(BBBAPIDomainREST)
                                                          relativeURL:relativeURL];
    
    connection.responseMapper = [BBBLibraryResponseMapper new];
    [connection perform:(BBBHTTPMethodGET)
                forUser:user
             completion:^(BBBLibraryResponse *response, NSError *error) {
                 completion(response.changes,nil);
                }];
}

- (void) getDeletedItemsForUser:(BBBUserDetails *)user
                     completion:(void (^)(NSArray *items, NSError *error))completion{
    NSParameterAssert(completion);
    NSString *relativeURL = [self.libraryEndpoint stringByAppendingPathComponent:@"deleted"];
    BBBConnection *connection = [[BBBConnection alloc] initWithDomain:(BBBAPIDomainREST)
                                                          relativeURL:relativeURL];
    
    connection.responseMapper = [BBBLibraryResponseMapper new];
    
    [connection perform:(BBBHTTPMethodGET)
                forUser:user
             completion:^(BBBLibraryResponse *response, NSError *error) {
                 completion(response.changes,nil);
             }];
}

#pragma mark - Getters

- (NSDateFormatter *) dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter = [BBBServerDateFormatter new];
    }
    return _dateFormatter;
}

#pragma mark - Private

- (NSError *) missingParameterError{
    NSError *error;
    
    error = [NSError errorWithDomain:BBBLibraryServiceErrorDomain
                                code:BBBLibraryServiceErrorMissingParameters
                            userInfo:nil];
    return error;
}

- (NSString *) libraryEndpoint{
    return @"my/library";
}

- (BBBHTTPMethod) methodForAction:(BBBItemAction)action{
    switch (action) {
        case BBBItemActionDelete:{
            return BBBHTTPMethodDELETE;
            break;
        }
        case BBBItemActionArchive:{
            return BBBHTTPMethodPOST;
            break;
        }
        case BBBItemActionUnarchive:{
            return BBBHTTPMethodPOST;
            break;
        }
        default:
            NSAssert(NO, @"unexpected aciton");
            return BBBHTTPMethodGET;
            break;
    }
}

- (NSString *) relativeURLForAction:(BBBItemAction)action item:(BBBLibraryItem *)item{
    NSAssert(item.identifier, @"item has to exist and have identifer");
    NSAssert(self.libraryEndpoint, @"library endpoint must not be nil");
    switch (action) {
        case BBBItemActionDelete:{
            return [self.libraryEndpoint stringByAppendingPathComponent:item.identifier];
            break;
        }
        case BBBItemActionArchive:{
            return [self.libraryEndpoint stringByAppendingPathComponent:@"archived"];
            break;
        }
        case BBBItemActionUnarchive:{
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
