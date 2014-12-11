//
//  BBAKeyServiceResponseMapper.h
//  BBBAPI
//
//  Created by Owen Worley on 01/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

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
