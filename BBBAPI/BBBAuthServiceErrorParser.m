//
//  BBBAuthServiceErrorParser.m
//  BBBAPI
//
//  Created by Owen Worley on 12/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBAuthServiceErrorParser.h"
#import "BBBAuthenticationServiceConstants.h"

@implementation BBBAuthServiceErrorParser
- (NSError *) errorForResponseJSON:(NSDictionary *)JSON
                        statusCode:(NSInteger)statusCode{

    //Check serverErrorValue for known error types.
    //If serverErrorValue is nil, we fall through and return `BBBAuthServiceErrorCodeInvalidResponse`
    NSString *serverErrorValue = JSON[kBBBServerKeyError];

    NSError *(^error)(BBBAuthServiceErrorCode code) = ^(BBBAuthServiceErrorCode code) {
        return  [NSError errorWithDomain:kBBBAuthServiceName
                                    code:code
                                userInfo:nil];
    };

    if ([serverErrorValue isEqualToString:kBBBServerErrorInvalidRequest]) {

        NSString *serverErrorReason = JSON[kBBBServerKeyErrorReason];

        if ([serverErrorReason isEqualToString:kBBBServerErrorClientLimitReached]) {
            return  error(BBBAuthServiceErrorCodeClientLimitReached);
        }
        else if ([serverErrorReason isEqualToString:kBBBServerErrorCountryGeoblocked]){
            return error(BBBAuthServiceErrorCodeCountryGeoblocked);
        }
        else if ([serverErrorReason isEqualToString:kBBBServerErrorUsernameAlreadyTaken]){
            return error(BBBAuthServiceErrorCodeUsernameAlreadyTaken);
        }

        NSAssert(NO, @"Unknown error reason %@", serverErrorReason);
        return error(BBBAuthServiceErrorCodeInvalidRequest);

    }

    if ([serverErrorValue isEqualToString:kBBBServerErrorInvalidGrant]) {
        return  error(BBBAuthServiceErrorCodeInvalidGrant);
    }

    if ([serverErrorValue isEqualToString:kBBBServerErrorInvalidClient]) {
        return error(BBBAuthServiceErrorCodeInvalidClient);
    }

    return error(BBBAuthServiceErrorCodeInvalidResponse);
}

@end
