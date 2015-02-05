//
//  BBABookItem.h
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 12/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Represents object returned by the Catalogue (Book) Service
 */
@interface BBABookItem : NSObject

/**
 *  ISBN of the book
 */
@property (nonatomic, copy) NSString *identifier;

/**
 *  Globally unique identifier of a given book item
 */
@property (nonatomic, copy) NSString *guid;

/**
 *  Title of the book
 */
@property (nonatomic, copy) NSString *title;

/**
 *  If `YES` this book have sample ebook available
 */
@property (nonatomic, assign) BOOL sampleEligible;

/**
 *  Publication date of the book
 */
@property (nonatomic, strong) NSDate *publicationDate;

/**
 *  Array of the `BBAImageItem` objects
 */
@property (nonatomic, copy) NSArray *images;

/**
 *  Array of the `BBALinkItem` objects
 */
@property (nonatomic, copy) NSArray *links;

/**
 *  HTML or plain text with the synopsis
 */
@property (nonatomic, copy) NSString *synopsis;

/**
 *  Returns `href` from the `link` with `ref` containing `samplemedia`.
 *  Enumerates `links` to find, array might be empty
 *
 *  @return `nil` or link string
 */
- (NSString *) sampleLink;

/**
 *  Returns `title` from the `link` with `ref` containing `publisher`
 *  Enumerates `links` to find, array might be empty
 *
 *  @return `nil` or string
 */
- (NSString *) publisherName;

/**
 *  Returns `title` from the `link` with `ref` containing `contributor`
 *  Enumerates `links` to find, array might be empty
 *
 *  @return `nil` or string
 */
- (NSString *) authorName;

/**
 *  Returns `targetGuid` from the `link` with `ref` containing `contributor`
 *  Enumerates `links` to find, array might be empty
 *
 *  @return `nil` or string
 */
- (NSString *) authorGUID;

@end
