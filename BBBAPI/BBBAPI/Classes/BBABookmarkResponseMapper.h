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

@interface BBABookmarkResponse : NSObject
@property (nonatomic, copy) NSDate *lastSyncDate;
@property (nonatomic, copy) NSArray *bookmarks;

- (instancetype) initWithData:(NSData *)data;

@end

@interface BBABookmarkResponseMapper : NSObject <BBAResponseMapping>

+ (BBABookmarkResponseMapper *) mapperWithType:(BBABookmarkResponseMapperType)type;
- (instancetype) initWithType:(BBABookmarkResponseMapperType)type;

@end
