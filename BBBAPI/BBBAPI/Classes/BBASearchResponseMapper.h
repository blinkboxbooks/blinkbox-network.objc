//
//  BBASearchResponseMapper.h
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 09/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBAJSONResponseMapper.h"

/**
 *  Maps responses from the search service into object classes.
 *  Responses from search/books are returned as`BBASearchServiceResult` 
 *  Responses from search/suggestions are returned as `BBASearchSuggestionsResult`
 */
@interface BBASearchResponseMapper : BBAJSONResponseMapper


@end
