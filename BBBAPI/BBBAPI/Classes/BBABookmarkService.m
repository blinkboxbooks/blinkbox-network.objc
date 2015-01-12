//
//  BBABookmarkService.m
//  BBAAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBABookmarkService.h"
#import "BBAConnection.h"
#import "BBARequestFactory.h"
#import "BBALibraryItem.h"
#import "BBABookmarkResponseMapper.h"
#import "BBAAPIErrors.h"
#import "BBABookmarkItem.h"
#import "BBAServerDateFormatter.h"

NSString *const kBBABookmarkServiceLastSyncDateTime = @"lastSyncDateTime";
NSString *const kBBABookmarkServiceBookmarkType = @"bookmarkType";
NSString *const kBBABookmarkServiceErrorDomain = @"BBA.error.bookmarkServiceDomain";

@interface BBABookmarkService ()
/**
 *  The class to use for communication with the server. This defaults to BBAConnection.
 */
@property (nonatomic, strong) Class connectionClass;
@property (nonatomic, strong) BBAServerDateFormatter *dateFormatter;
@end

@implementation BBABookmarkService
- (void) getBookmarkChangesForItem:(BBALibraryItem *)item
                         afterDate:(NSDate *)date
                         typesMask:(BBABookmarkType)types
                              user:(BBAUserDetails *)user
                        completion:(void (^)(NSArray *bookmarkChanges, NSDate *syncDate, NSError *error))completion{

    NSParameterAssert(completion);
    if (!completion) {
        return;
    }

    id connection = nil;
    NSString *myBookmarksEndPoint = @"my/bookmarks";
    connection = [[self.connectionClass alloc] initWithDomain:(BBAAPIDomainREST)
                                               relativeURL:myBookmarksEndPoint];

    [connection setRequestFactory:[BBARequestFactory new]];
    [connection setResponseMapper:[BBABookmarkResponseMapper new]];
    [connection setRequiresAuthentication:YES];


    if (date) {
        NSString *dateString;
        dateString = [self.dateFormatter stringFromDate:date];
        if (dateString) {
            [connection addParameterWithKey:kBBABookmarkServiceLastSyncDateTime value:dateString];
        }
    }

    NSArray *bookmarkTypes = [self bookmarkTypeStringArrayFromType:types];

    if (bookmarkTypes.count > 0) {
        [connection addParameterWithKey:kBBABookmarkServiceBookmarkType arrayValue:bookmarkTypes];
    }

    if (item.isbn) {
        [connection addParameterWithKey:@"book" value:item.isbn];
    }
    
    [connection perform:(BBAHTTPMethodGET)
                forUser:user
             completion:^(BBABookmarkResponse *response, NSError *error) {
                 completion(response.bookmarks, response.lastSyncDate, error);
             }];
}


- (void) deleteBookmarksForItem:(BBALibraryItem *)item
                      typesMask:(BBABookmarkType)types
                           user:(BBAUserDetails *)user
                     completion:(void (^)(BOOL success, NSError *error))completion{

    NSParameterAssert(item.isbn);
    NSParameterAssert(completion);

    if (!completion) {
        return;
    }

    if (!item.isbn) {
        completion(NO,  [NSError errorWithDomain:kBBABookmarkServiceErrorDomain
                                            code:BBAAPIWrongUsage
                                        userInfo:nil]);
        return;
    }

    id connection = nil;
    NSString *myBookmarksEndPoint = @"my/bookmarks";
    connection = [[self.connectionClass alloc] initWithDomain:(BBAAPIDomainREST)
                                                  relativeURL:myBookmarksEndPoint];

    [connection setContentType:BBAContentTypeURLEncodedForm];
    [connection setRequestFactory:[BBARequestFactory new]];
    [connection setResponseMapper:[BBABookmarkResponseMapper mapperWithType:BBABookmarkResponseMapperTypeDeleteMultipleBookmarks]];
    [connection setRequiresAuthentication:YES];


    NSArray *bookmarkTypes = [self bookmarkTypeStringArrayFromType:types];

    if (bookmarkTypes.count > 0) {
        [connection addParameterWithKey:kBBABookmarkServiceBookmarkType arrayValue:bookmarkTypes];
    }

    if (item.isbn) {
        [connection addParameterWithKey:@"book" value:item.isbn];
    }

    [connection perform:(BBAHTTPMethodDELETE)
                forUser:user
             completion:^(id response, NSError *error) {
                 completion([response boolValue], error);
             }];
}

- (void) deleteBookmark:(BBABookmarkItem *)item
                   user:(BBAUserDetails *)user
             completion:(void (^)(BOOL success, NSError *error))completion{

    NSParameterAssert(item);
    NSParameterAssert(completion);

    if (!completion) {
        return;
    }

    if (!item.identifier) {
        completion(NO, [NSError errorWithDomain:kBBABookmarkServiceErrorDomain
                                            code:BBAAPIWrongUsage
                                        userInfo:nil]);
        return;
    }

    id connection = nil;
    NSString *myBookmarksEndPoint = [NSString stringWithFormat:@"my/bookmarks/%@", item.identifier];
    connection = [[self.connectionClass alloc] initWithDomain:(BBAAPIDomainREST)
                                                  relativeURL:myBookmarksEndPoint];

    [connection setContentType:BBAContentTypeURLEncodedForm];
    [connection setRequestFactory:[BBARequestFactory new]];
    [connection setResponseMapper:[BBABookmarkResponseMapper mapperWithType:BBABookmarkResponseMapperTypeDeleteBookmark]];
    [connection setRequiresAuthentication:YES];

    [connection perform:(BBAHTTPMethodDELETE)
                forUser:user
             completion:^(id response, NSError *error) {
                 completion([response boolValue], error);
             }];

}

- (void) addBookMark:(BBABookmarkItem *)bookmark
             forItem:(BBALibraryItem *)item
                user:(BBAUserDetails *)user
          completion:(void (^)(BBABookmarkItem *bookmarkItem, NSError *error))completion{

    NSParameterAssert(bookmark);
    NSParameterAssert(item);
    NSParameterAssert(completion);

    if (!completion) {
        return;
    }

    if (!bookmark || !item) {
        completion(nil, [NSError errorWithDomain:kBBABookmarkServiceErrorDomain
                                           code:BBAAPIWrongUsage
                                       userInfo:nil]);
        return;
    }

    id connection = nil;
    NSString *myBookmarksEndPoint = @"my/bookmarks";
    connection = [[self.connectionClass alloc] initWithDomain:(BBAAPIDomainREST)
                                                  relativeURL:myBookmarksEndPoint];

    [connection setContentType:BBAContentTypeJSON];
    [connection setRequestFactory:[BBARequestFactory new]];
    [connection setResponseMapper:[BBABookmarkResponseMapper mapperWithType:BBABookmarkResponseMapperTypeCreateBookmark]];
    [connection setRequiresAuthentication:YES];

    NSDictionary *bookmarkRepresentation;
    bookmarkRepresentation = [bookmark dictionaryRepresentation];

    for (NSString *key in bookmarkRepresentation) {
        id value = bookmarkRepresentation[key];
        [connection addParameterWithKey:key value:value];
    }


    [connection perform:(BBAHTTPMethodPOST)
                forUser:user
             completion:^(BBABookmarkResponse *response, NSError *error) {
                 completion([[response bookmarks]firstObject], error);
             }];

}

- (void) updateBookMark:(BBABookmarkItem *)item
                   user:(BBAUserDetails *)user
             completion:(void (^)(BOOL success, NSError *error))completion{

    NSParameterAssert(item.identifier);
    NSParameterAssert(completion);

    if (!completion) {
        return;
    }

    if (!item.identifier) {
        completion(nil, [NSError errorWithDomain:kBBABookmarkServiceErrorDomain
                                            code:BBAAPIWrongUsage
                                        userInfo:nil]);
        return;
    }

    id connection = nil;
    NSString *myBookmarksEndPoint = [NSString stringWithFormat:@"my/bookmarks/%@", item.identifier];
    connection = [[self.connectionClass alloc] initWithDomain:(BBAAPIDomainREST)
                                                  relativeURL:myBookmarksEndPoint];

    [connection setContentType:BBAContentTypeJSON];
    [connection setRequestFactory:[BBARequestFactory new]];
    [connection setResponseMapper:[BBABookmarkResponseMapper mapperWithType:BBABookmarkResponseMapperTypeUpdateBookmark]];
    [connection setRequiresAuthentication:YES];

    NSDictionary *bookmarkRepresentation;
    bookmarkRepresentation = [item dictionaryRepresentation];

    for (NSString *key in bookmarkRepresentation) {
        id value = bookmarkRepresentation[key];
        [connection addParameterWithKey:key value:value];
    }


    [connection perform:(BBAHTTPMethodPUT)
                forUser:user
             completion:^(id response, NSError *error) {
                 completion([response boolValue], error);
             }];

}
#pragma mark - Private Methods

- (NSArray *) bookmarkTypeStringArrayFromType:(BBABookmarkType)type{

    if(type == BBABookmarkTypeAll){
        return @[@"HIGLIGHT",
                @"CROSS_REFERENCE",
                @"BOOKMARK",
                @"LAST_READ_POSITION",
                @"NOTE"];
    }

    NSMutableArray *types = [NSMutableArray new];
    if((type & BBABookmarkTypeBookmark) != 0){
        [types addObject:@"BOOKMARK"];
    }
    if((type & BBABookmarkTypeHighlight) != 0){
        [types addObject:@"HIGHLIGHT"];
    }
    if((type & BBABookmarkTypeLastReadingPostion) != 0){
        [types addObject:@"LAST_READ_POSITION"];
    }
    if((type & BBABookmarkTypeCrossReference) != 0){
        [types addObject:@"CROSS_REFERENCE"];
    }
    if((type & BBABookmarkTypeNote) != 0){
        [types addObject:@"NOTE"];
    }


    return types;
}



#pragma mark - Getters

- (Class) connectionClass{
    if (_connectionClass == nil) {
        _connectionClass = [BBAConnection class];
    }

    return _connectionClass;
}

- (BBAServerDateFormatter *) dateFormatter{
    if (_dateFormatter == nil) {
        _dateFormatter = [BBAServerDateFormatter new];
    }

    return _dateFormatter;
}
@end
