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
#import "BBAJSONResponseMapper.h"
#import "BBALibraryItem.h"
#import "BBABookmarkResponseMapper.h"

NSString *kBBABookmarkServiceLastSyncDateTime = @"lastSyncDateTime";
NSString *kBBABookmarkServiceBookmarkType = @"bookmarkType";

@implementation BBABookmarkService
- (void) getBookmarkChangesForItem:(BBALibraryItem *)item
                         afterDate:(NSDate *)date
                         typesMask:(BBABookmarkType)types
                              user:(BBAUserDetails *)user
                        completion:(void (^)(NSArray *bookmarkChanges, NSDate *syncDate, NSError *error))completion{

    NSParameterAssert(user);
    NSParameterAssert(completion);

    id connection = nil;
    NSString *myBookmarksEndPoint = @"my/bookmarks";
    connection = [[self.connectionClass alloc] initWithDomain:(BBAAPIDomainREST)
                                               relativeURL:myBookmarksEndPoint];

    [connection setRequestFactory:[BBARequestFactory new]];
    [connection setResponseMapper:[BBABookmarkResponseMapper new]];
    [connection setRequiresAuthentication:YES];

    if (date) {
        [connection addParameterWithKey:kBBABookmarkServiceLastSyncDateTime value:@"date_string"];
    }

    NSArray *bookmarkTypes = [self bookmarkTypeStringArrayFromType:types];

    if (bookmarkTypes.count>0) {
        [connection addParameterWithKey:kBBABookmarkServiceBookmarkType arrayValue:bookmarkTypes];
    }

    if (item.isbn) {
        [connection addParameterWithKey:@"book" value:item.isbn];
    }
    
    [connection perform:(BBAHTTPMethodGET)
             completion:^(BBABookmarkResponse *response, NSError *error) {
                 completion(response.bookmarks, response.lastSyncDate, error);
             }];
}


- (void) deleteBookmarksForItem:(BBALibraryItem *)item
                      typesMask:(BBABookmarkType)types
                           user:(BBAUserDetails *)user
                     completion:(void (^)(BOOL success, NSError *error))completion{
    
}

- (void) deleteBookmark:(BBABookmarkItem *)item
                   user:(BBAUserDetails *)user
             completion:(void (^)(BOOL success, NSError *error))completion{
    
}

- (void) addBookMark:(BBABookmarkItem *)bookmark
             forItem:(BBALibraryItem *)item
                user:(BBAUserDetails *)user
          completion:(void (^)(BBABookmarkItem *bookmarkItem, NSError *error))completion{
    
}

- (void) updateBookMark:(BBABookmarkItem *)item
                   user:(BBAUserDetails *)user
             completion:(void (^)(BBABookmarkItem *bookmarkItem, NSError *error))completion{
    
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

#pragma mark - Setters

- (Class) connectionClass{
    if (_connectionClass == nil) {
        _connectionClass = [BBAConnection class];
    }

    return _connectionClass;
}
@end
