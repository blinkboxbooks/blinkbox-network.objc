//
//  BBALibraryItemMapper.h
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 12/12/2014.
  

#import <Foundation/Foundation.h>
@class BBALibraryItem;

/**
 *  `BBALibraryItemMapper` is responsible for mapping values from the JSON
 *  response from the Library Service into newly created `BBALibraryItem` objects
 */
@interface BBALibraryItemMapper : NSObject

/**
 *  Valides and parses `dictionary` in to new instance of `BBALibraryItem`
 *
 *  @param dictionary must not be `nil` and `type` field must contain `urn:blinkboxbooks:schema:libraryitem`
 *
 *  @return new intance of `BBALibraryItem` class or `nil`
 */
- (BBALibraryItem *) itemFromDictionary:(NSDictionary *)dictionary;
@end