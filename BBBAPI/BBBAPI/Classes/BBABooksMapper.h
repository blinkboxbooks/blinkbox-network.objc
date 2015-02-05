//
//  BBABooksResponseMapper.h
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 11/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BBABookItem;

/**
 *  `BBABooksMapper` parses the response items from the Catalogue (Book) Service into 
 *  `BBABookItem` objects and does the basic validation of the incoming data
 */
@interface BBABooksMapper : NSObject
/**
 *  Creates and fills new `BBABookItem` object with the data
 *  from the `dictionary`
 *
 *  @param dictionary must not be `nil`, and `type` field must contain "urn:blinkboxbooks:schema:book"
 *
 *  @return new instance of the `BBABookItem` or `nil` if `dictionary` doesn't validate 
 */
- (BBABookItem *) itemFromDictionary:(NSDictionary *)dictionary;
@end


