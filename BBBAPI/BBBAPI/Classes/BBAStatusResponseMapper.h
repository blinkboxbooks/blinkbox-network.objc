//
//  BBASuccesLibraryResponseMapper.h
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 14/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBAResponseMapping.h"
/**
 *  Response mapper that expect `nil` data and return boolean NSNumber status
 *  based on the HTTP status code of the response passed in. It returns @YES if HTTP status code
 *  is 200 and doesn't write into the `error`. It is returns @NO if HTTP status is different that 200
 *  and write the cause to the `error` address.
 */
@interface BBAStatusResponseMapper : NSObject <BBAResponseMapping>
@end
