//
//  BBACatalogueResponseMapper.h
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 11/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBAJSONResponseMapper.h"

/**
 *  `BBACatalogueResponseMapper` is used to map responses from the 
 *  Catalogue (Book) Service. `responseFromData:response:error` can return `NSArray` of 
 *  or single object of type `BBABookItem`. It can also return `nil` in case of an error.
 */
@interface BBACatalogueResponseMapper : BBAJSONResponseMapper

@end
