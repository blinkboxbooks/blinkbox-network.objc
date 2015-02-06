//
//  BBALibraryResponseMapper.h
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 04/08/2014.
 

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
