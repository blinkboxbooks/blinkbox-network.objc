//
//  BBAAuthServiceErrorParser.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 12/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAAuthServiceErrorParser.h"
#import "BBAAuthenticationServiceConstants.h"

@implementation BBAAuthServiceErrorParser
- (NSError *) errorForResponseJSON:(NSDictionary *)JSON
                        statusCode:(NSInteger)statusCode{

    //Check serverErrorValue for known error types.
    //If serverErrorValue is nil, we fall through and return `BBAAuthServiceErrorCodeInvalidResponse`
    NSString *serverErrorValue = JSON[kBBAServerKeyError];

    NSError *(^error)(BBAAuthServiceErrorCode code) = ^(BBAAuthServiceErrorCode code) {
        return  [NSError errorWithDomain:kBBAAuthServiceName
                                    code:code
                                userInfo:nil];
    };

    if ([serverErrorValue isEqualToString:kBBAServerErrorInvalidRequest]) {

        NSString *serverErrorReason = JSON[kBBAServerKeyErrorReason];

        if ([serverErrorReason isEqualToString:kBBAServerErrorClientLimitReached]) {
            return  error(BBAAuthServiceErrorCodeClientLimitReached);
        }
        else if ([serverErrorReason isEqualToString:kBBAServerErrorCountryGeoblocked]){
            return error(BBAAuthServiceErrorCodeCountryGeoblocked);
        }
        else if ([serverErrorReason isEqualToString:kBBAServerErrorUsernameAlreadyTaken]){
            return error(BBAAuthServiceErrorCodeUsernameAlreadyTaken);
        }

        NSAssert(NO, @"Unknown error reason %@", serverErrorReason);
        return error(BBAAuthServiceErrorCodeInvalidRequest);

    }

    if ([serverErrorValue isEqualToString:kBBAServerErrorInvalidGrant]) {
        return  error(BBAAuthServiceErrorCodeInvalidGrant);
    }

    if ([serverErrorValue isEqualToString:kBBAServerErrorInvalidClient]) {
        return error(BBAAuthServiceErrorCodeInvalidClient);
    }

    return error(BBAAuthServiceErrorCodeInvalidResponse);
}

@end
