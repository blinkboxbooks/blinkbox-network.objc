//
//  BBALibraryItemMapper.h
//  BBBAPI
//
//  Created by Tomek Kuźma on 12/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

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