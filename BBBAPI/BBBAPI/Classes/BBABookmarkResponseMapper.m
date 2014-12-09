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
        _bookmarks = [BBABookmarkItem bookmarkItemsWithJSONArray:bookmarksJSON[@"bookmarks"]];

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

- (BBABookmarkResponse *) responseFromData:(NSData *)data
               response:(NSURLResponse *)response
                  error:(NSError *__autoreleasing *)error{

    return [self responseForType:self.type
                            data:data
                        response:response
                           error:error];
}

- (BBABookmarkResponse *) responseForType:(BBABookmarkResponseMapperType)type
                  data:(NSData *)data
               response:(NSURLResponse *)response
                 error:(NSError *__autoreleasing *)error{
    switch (type) {
        case BBABookmarkResponseMapperTypeGetMultipleBookmarks:
            return [self multipleBookmarksGETResponseWithData:data
                                                     response:response
                                                        error:error];
            break;

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
    else if (httpResonse.statusCode == BBAHTTPBadRequest){

        if (error) {
            *error = [NSError errorWithDomain:BBAConnectionErrorDomain
                                         code:BBAAPIBadRequest
                                     userInfo:nil];
            return nil;
        }
    }
    else if(httpResonse.statusCode == BBAHTTPServerError){
        if (error) {
            *error = [NSError errorWithDomain:BBAConnectionErrorDomain
                                         code:BBAAPIServerError
                                     userInfo:nil];
            return nil;
        }
    }
    return nil;
}


@end
