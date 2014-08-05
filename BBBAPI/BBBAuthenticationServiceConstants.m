//
//  BBBAuthenticationServiceConstants.m
//  BBBAPI
//
//  Created by Owen Worley on 04/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBAuthenticationServiceConstants.h"

@implementation BBBAuthenticationServiceConstants

NSString *const kBBBAuthServiceName = @"com.bbb.AuthenticationService";

NSString *const kBBBGrantTypePassword = @"password";
NSString *const kBBBGrantTypeRefreshToken = @"refresh_token";
NSString *const kBBBGrantTypeRegistration = @"urn:blinkbox:oauth:grant-type:registration";

NSString *const kBBBAuthKeyGrantType = @"grant_type";

NSString *const kBBBAuthKeyUsername = @"username";
NSString *const kBBBAuthKeyPassword = @"password";

NSString *const kBBBAuthKeyClientId = @"client_id";
NSString *const kBBBAuthKeyClientSecret = @"client_secret";

//Errors returned by the server
NSString *const kBBBServerKeyError = @"error";
NSString *const kBBBServerKeyErrorReason = @"error_reason";
NSString *const kBBBServerErrorInvalidGrant = @"invalid_grant";
NSString *const kBBBServerErrorInvalidRequest = @"invalid_request";
NSString *const kBBBServerErrorInvalidClient = @"invalid_client";
NSString *const kBBBServerErrorUsernameAlreadyTaken = @"username_already_taken";
NSString *const kBBBServerErrorCountryGeoblocked = @"country_geoblocked";
NSString *const kBBBServerErrorClientLimitReached = @"client_limit_reached";

+ (NSString *) stringGrantType:(BBBGrantType)type{

    NSString *grantType = @"";
    switch (type) {
        case BBBGrantTypePassword:
            grantType = kBBBGrantTypePassword;
            break;
        case BBBGrantTypeRefreshToken:
            grantType = kBBBGrantTypeRefreshToken;
            break;
        case BBBGrantTypeRegistration:
            grantType = kBBBGrantTypeRegistration;
            break;
        default:
            break;
    }

    NSAssert([grantType length]>0, @"Grant type not found for type %i", type);
    return grantType;
}
@end
