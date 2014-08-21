//
//  BBBLibraryResponseMapper.h
//  BBBAPI
//
//  Created by Tomek Kuźma on 04/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBJSONResponseMapper.h"

/**
 *  This object implements `BBBResponseMapping` and it's returned object is of type
 *  `BBBLibraryResponse`. It uses implemention of `responseFromData:response:error:` 
 *  of it's superclass.
 *
 *  @seealso BBBLibraryResponse
 *  @seealso BBBResponseMapping
 */
@interface BBBLibraryResponseMapper : BBBJSONResponseMapper

@end
