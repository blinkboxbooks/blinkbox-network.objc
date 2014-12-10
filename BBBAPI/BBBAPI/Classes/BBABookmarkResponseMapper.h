//
//  BBABookmarkResponseMapper.h
//  BBBAPI
//
//  Created by Owen Worley on 08/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBAResponseMapping.h"

typedef NS_ENUM(NSUInteger, BBABookmarkResponseMapperType) {
    BBABookmarkResponseMapperTypeGetMultipleBookmarks = 0,
    BBABookmarkResponseMapperTypeGetBookmark = 1,
    BBABookmarkResponseMapperTypeDeleteMultipleBookmarks = 2,
    BBABookmarkResponseMapperTypeDeleteBookmark = 3,
    BBABookmarkResponseMapperTypeCreateBookmark = 4,
    BBABookmarkResponseMapperTypeUpdateBookmark = 5,
};

/**
 *  Represents a response from the Bookmark service, contianing an `NSArray` of bookmarks and (optionally) a lastSyncDate
 */
@interface BBABookmarkResponse : NSObject
@property (nonatomic, copy) NSDate *lastSyncDate;
@property (nonatomic, copy) NSArray *bookmarks;

/**
 *  Create a `BBABookmarkResponse` from `NSData` containing JSON Values
 *
 *  @param data `NSData` containing JSON Bookmark values
 *
 *  @return `BBABookmarkResponse`
 */
- (instancetype) initWithData:(NSData *)data;

@end

/**
 *  `BBABookmarkResponseMapper` is responsible for mapping responses from the bookmark service into
 *  a format usable by the API library.
 */
@interface BBABookmarkResponseMapper : NSObject <BBAResponseMapping>

/**
 *  Returns a mapper with a given type
 *
 *  @param type see `BBABookmarkResponseMapperType` for a list of valid types
 *
 *  @return `BBABookmarkResponseMapper` configured for mapping responses of the given `type`
 */
+ (BBABookmarkResponseMapper *) mapperWithType:(BBABookmarkResponseMapperType)type;

/**
 *  Initialises a mapper with a given type
 *
 *  @param type see `BBABookmarkResponseMapperType` for a list of valid types
 *
 *  @return `BBABookmarkResponseMapper` configured for mapping responses of the given `type`
 */
- (instancetype) initWithType:(BBABookmarkResponseMapperType)type;

@end
