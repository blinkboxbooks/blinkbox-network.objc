//
//  BBAKeyServiceResponseMapper.h
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 01/12/2014.
  

#import <Foundation/Foundation.h>
#import "BBAResponseMapping.h"

extern NSString *const BBAKeyServiceResponseMapperErrorDomain;

typedef NS_ENUM(NSUInteger, BBAKeyServiceResponseMapperError) {
    BBAKeyServiceResponseMapperErrorNotAuthorised = 1100,
    BBAKeyServiceResponseMapperErrorNotAllowed = 1101,
    BBAKeyServiceResponseMapperErrorKeyLimitExceeded = 1102,
    BBAKeyServiceResponseMapperErrorNotFound = 1103,
    BBAKeyServiceResponseMapperErrorBadResponse = 1104,

};

/**
 *  This class maps responses from the key service into usable data representations
 */
@interface BBAKeyServiceResponseMapper : NSObject <BBAResponseMapping>
@end
