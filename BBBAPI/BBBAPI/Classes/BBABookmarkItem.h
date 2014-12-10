//
//  BBABookmarkItem.h
//  BBBAPI
//
//  Created by Owen Worley on 05/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBABookmarkItem : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *guid;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *bookmarkType;
@property (nonatomic, copy) NSString *book;
@property (nonatomic, copy) NSString *position;
@property (nonatomic, copy) NSNumber *readingPercentage;
@property (nonatomic, copy) NSNumber *deleted;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *annotation;
@property (nonatomic, copy) NSString *style;
@property (nonatomic, copy) NSString *colour;
@property (nonatomic, copy) NSString *preview;
@property (nonatomic, copy) NSDate *createdDate;
@property (nonatomic, copy) NSDate *updatedDate;
@property (nonatomic, copy) NSString *createdByClient;
@property (nonatomic, copy) NSString *updatedByClient;
@property (nonatomic, copy) NSArray *links;

+ (NSArray *) bookmarkItemsWithJSONArray:(NSArray *)dictionary;
+ (BBABookmarkItem *) bookmarkItemWithJSON:(NSDictionary *)dictionary;
+ (BBABookmarkItem *) bookmarkItemWithData:(NSData *)data;

- (NSDictionary *) dictionaryRepresentation;
@end
