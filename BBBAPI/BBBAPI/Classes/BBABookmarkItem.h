//
//  BBABookmarkItem.h
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 05/12/2014.
  

#import <Foundation/Foundation.h>

/**
 *  BBABookmarkItem represents a bookmark in a format understood by the server.
 */
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

/**
 *  Returns an `NSArray` of `BBABookmarkItems` from an `NSArray` of JSON Dictionaries
 *
 *  @param array `NSArray` of dictionaries containing bookmark data
 *
 *  @return `NSArray` of `BBABookmarkItems`
 */
+ (NSArray *) bookmarkItemsWithJSONArray:(NSArray *)array;

/**
 *  Creates a `BBABookmarkItem` from an NSDictionary of JSON Values
 *
 *  @param dictionary `NSDictionary` containing bookmark data
 *
 *  @return `BBABookmarkItem`
 */
+ (BBABookmarkItem *) bookmarkItemWithJSON:(NSDictionary *)dictionary;

/**
 *  Creates a `BBABookmarkItem` from NSData containing raw JSON Data
 *
 *  @param data `NSData` containing JSON Values for a bookmark
 *
 *  @return `BBABookmarkItem`
 */
+ (BBABookmarkItem *) bookmarkItemWithData:(NSData *)data;

/**
 *  Returns an `NSDictionary` of values representing this bookmark in a format that can be sent to the server
 *
 *  @return `NSDictionary` of key-pair bookmark data
 */
- (NSDictionary *) dictionaryRepresentation;
@end
