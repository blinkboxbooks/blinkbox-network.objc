//
//  BBABookmarkResponseMapper.m
//  BBBAPI
//
//  Created by Owen Worley on 08/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBABookmarkResponseMapper.h"
#import "BBABookmarkItem.h"
#import "BBAConnection.h"
#import "BBAAPIErrors.h"
#import "BBADateHelper.h"

@implementation BBABookmarkResponse
- (instancetype) initWithData:(NSData *)data{
    self = [self init];
    if (self) {
        NSDictionary *bookmarksJSON;
        bookmarksJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        NSArray *JSONBookmarks = bookmarksJSON[@"bookmarks"];
        if (!JSONBookmarks && bookmarksJSON) {
            JSONBookmarks = @[bookmarksJSON];
        }

        _bookmarks = [BBABookmarkItem bookmarkItemsWithJSONArray:JSONBookmarks];

        NSDate *date = [BBADateHelper dateFromString:bookmarksJSON[@"lastSyncDateTime"]];
        _lastSyncDate = date;


    }
    return self;
}
@end

@interface BBABookmarkResponseMapper ()
@property (nonatomic, assign) BBABookmarkResponseMapperType type;
@end

@implementation BBABookmarkResponseMapper

+ (BBABookmarkResponseMapper *) mapperWithType:(BBABookmarkResponseMapperType)type{

    BBABookmarkResponseMapper *mapper;
    mapper = [[BBABookmarkResponseMapper alloc] initWithType:type];

    return mapper;
}

- (instancetype) initWithType:(BBABookmarkResponseMapperType)type{

    self = [self init];
    if (self) {
        _type = type;
    }
    return self;
}

- (id) responseFromData:(NSData *)data
               response:(NSURLResponse *)response
                  error:(NSError *__autoreleasing *)error{

    return [self responseForType:self.type
                            data:data
                        response:response
                           error:error];
}

- (id) responseForType:(BBABookmarkResponseMapperType)type
                  data:(NSData *)data
               response:(NSURLResponse *)response
                 error:(NSError *__autoreleasing *)error{
    switch (type) {
        case BBABookmarkResponseMapperTypeGetMultipleBookmarks:
            return [self multipleBookmarksGETResponseWithData:data
                                                     response:response
                                                        error:error];

        case BBABookmarkResponseMapperTypeDeleteMultipleBookmarks:
            return @([self multipleBookmarksDELETEResponseWithData:data
                                                          response:response
                                                             error:error]);

        case BBABookmarkResponseMapperTypeDeleteBookmark:
            return @([self singleBookmarkDELETEResponseWithData:data
                                                       response:response
                                                          error:error]);

        case BBABookmarkResponseMapperTypeCreateBookmark:
            return [self bookmarkCREATEResponseWithData:data
                                               response:response
                                                  error:error];
        case BBABookmarkResponseMapperTypeUpdateBookmark:
            return @([self bookmarkUPDATERResponseWithData:data
                                               response:response
                                                  error:error]);
        default:
            break;
    }
    return nil;
}

- (BBABookmarkResponse *) multipleBookmarksGETResponseWithData:(NSData *)data
                                response:(NSURLResponse *)response
                                   error:(NSError *__autoreleasing *)error{
    NSHTTPURLResponse *httpResonse = (NSHTTPURLResponse *)response;

    if (httpResonse.statusCode == BBAHTTPSuccess) {
        BBABookmarkResponse *bookmarkResponse = [[BBABookmarkResponse alloc] initWithData:data];
        return bookmarkResponse;
    }
    else{
        [self setError:error fromStatusCode:httpResonse.statusCode];
        return nil;
    }

    return nil;
}

- (BOOL) multipleBookmarksDELETEResponseWithData:(NSData *)data
                                        response:(NSURLResponse *)response
                                           error:(NSError *__autoreleasing *)error{
    NSHTTPURLResponse *httpResonse = (NSHTTPURLResponse *)response;


    //204 - Success
    if (httpResonse.statusCode == BBAHTTPNoContent /* 204 */) {
        return YES;

    }
    else{
        [self setError:error fromStatusCode:httpResonse.statusCode];
        return NO;
    }
    return NO;
}

- (BOOL) singleBookmarkDELETEResponseWithData:(NSData *)data
                                     response:(NSURLResponse *)response
                                        error:(NSError *__autoreleasing *)error{
    NSHTTPURLResponse *httpResonse = (NSHTTPURLResponse *)response;

    if (httpResonse.statusCode == BBAHTTPNoContent /* 204 */) {
        return YES;
    }
    else{
        [self setError:error fromStatusCode:httpResonse.statusCode];
        return NO;
    }

    return NO;
}

-(BBABookmarkResponse *) bookmarkCREATEResponseWithData:(NSData *)data
                                               response:(NSURLResponse *)response
                                                  error:(NSError *__autoreleasing *)error{
    NSHTTPURLResponse *httpResonse = (NSHTTPURLResponse *)response;
    if (httpResonse.statusCode == BBAHTTPCreated /* 201 */) {
        BBABookmarkResponse *bookmarkResponse = [[BBABookmarkResponse alloc] initWithData:data];
        return bookmarkResponse;
    }
    else{
        [self setError:error fromStatusCode:httpResonse.statusCode];
        return nil;
    }

}

- (BOOL) bookmarkUPDATERResponseWithData:(NSData *)data
                                             response:(NSURLResponse *)response
                                                error:(NSError *__autoreleasing *)error{
    NSHTTPURLResponse *httpResonse = (NSHTTPURLResponse *)response;
    if (httpResonse.statusCode == BBAHTTPSuccess /* 200 */) {
        return YES;
    }
    else{
        [self setError:error fromStatusCode:httpResonse.statusCode];
        return NO;
    }

}

- (void) setError:(NSError *__autoreleasing *)error
   fromStatusCode:(NSInteger)statusCode{
    if (!error) {
        return;
    }
    //200 - Not found.
    //Delete Multiple Bookmarks returns a 200 as a fail code when it cannot find the specified\
    bookmarks to delete
    if (statusCode == BBAHTTPSuccess /* 200 */) {
        *error = [NSError errorWithDomain:BBAConnectionErrorDomain
                                     code:BBAAPIErrorNotFound
                                 userInfo:nil];
    }
    //404 - Not Found
    else if (statusCode == BBAHTTPNotFound /* 404 */) {
        *error = [NSError errorWithDomain:BBAConnectionErrorDomain
                                     code:BBAAPIErrorNotFound
                                 userInfo:nil];
    }
    //403 - Forbidden/Unauthorised
    else if (statusCode == BBAHTTPForbidden /* 403 */) {
        *error = [NSError errorWithDomain:BBAConnectionErrorDomain
                                     code:BBAAPIErrorForbidden
                                 userInfo:nil];
    }
    //400 - Bad Request
    else if (statusCode == BBAHTTPBadRequest /* 400 */) {
        *error = [NSError errorWithDomain:BBAConnectionErrorDomain
                                     code:BBAAPIErrorBadRequest
                                 userInfo:nil];

    }
    //409 - Conflict
    else if (statusCode == BBAHTTPConflict /* 409 */) {
        *error = [NSError errorWithDomain:BBAConnectionErrorDomain
                                     code:BBAAPIErrorConflict
                                 userInfo:nil];

    }
    //500 - Internal server error
    else if (statusCode == BBAHTTPServerError /* 500 */) {
        *error = [NSError errorWithDomain:BBAConnectionErrorDomain
                                     code:BBAAPIServerError
                                 userInfo:nil];
    }
}

@end
