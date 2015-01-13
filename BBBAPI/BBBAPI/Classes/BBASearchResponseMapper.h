//
//  BBASearchResponseMapper.h
//  BBBAPI
//
//  Created by Owen Worley on 09/01/2015.
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
