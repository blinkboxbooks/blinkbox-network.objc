//
//  BBALibraryResponseMapper.h
//  BBAAPI
//
//  Created by Tomek Kuźma on 04/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAJSONResponseMapper.h"

/**
 *  This object implements `BBAResponseMapping` and it's returned object is of type
 *  `BBALibraryResponse`. It uses implemention of `responseFromData:response:error:` 
 *  of it's superclass.
 *
 *  @seealso BBALibraryResponse
 *  @seealso BBAResponseMapping
 */
@interface BBALibraryResponseMapper : BBAJSONResponseMapper

@end
