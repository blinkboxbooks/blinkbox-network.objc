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
NSString *const kBBBAuthServiceTokensName = @"com.bbb.AuthenticationService.tokens";
NSString *const kBBBAuthServiceClientsName = @"com.bbb.AuthenticationService.clients";
//Server oauth2 grant types
NSString *const kBBBGrantTypePassword = @"password";
NSString *const kBBBGrantTypeRefreshToken = @"refresh_token";
NSString *const kBBBGrantTypeRegistration = @"urn:blinkbox:oauth:grant-type:registration";

//Server JSON dictionary keys
NSString *const kBBBAuthKeyGrantType = @"grant_type";
NSString *const kBBBAuthKeyUsername = @"username";
NSString *const kBBBAuthKeyPassword = @"password";
NSString *const kBBBAuthKeyUserId = @"user_id";
NSString *const kBBBAuthKeyUserURI = @"user_uri";
NSString *const kBBBAuthKeyUserUserName = @"user_username";
NSString *const kBBBAuthKeyUserFirstName = @"user_first_name";
NSString *const kBBBAuthKeyUserLastName = @"user_last_name";
NSString *const kBBBAuthKeyClientId = @"client_id";
NSString *const kBBBAuthKeyClientURI = @"client_uri";
NSString *const kBBBAuthKeyClientSecret = @"client_secret";
NSString *const kBBBAuthKeyLastUsedDate = @"last_used_date";
NSString *const kBBBAuthKeyAccessToken = @"access_token";
NSString *const kBBBAuthKeyExpiresIn = @"expires_in";
NSString *const kBBBAuthKeyTokenType = @"token_type";
NSString *const kBBBAuthKeyRefreshToken = @"refresh_token";
NSString *const kBBBAuthKeyFirstName = @"first_name";
NSString *const kBBBAuthKeyLastName = @"last_name";
NSString *const kBBBAuthKeyAcceptedTerms = @"accepted_terms_and_conditions";
NSString *const kBBBAuthKeyAllowMarketing = @"allow_marketing_communications";
NSString *const kBBBAuthKeyClientName = @"client_name";
NSString *const kBBBAuthKeyClientBrand = @"client_brand";
NSString *const kBBBAuthKeyClientOS = @"client_os";
NSString *const kBBBAuthKeyClientModel = @"client_model";

//Errors returned by the server
NSString *const kBBBServerKeyError = @"error";
NSString *const kBBBServerKeyErrorReason = @"error_reason";
NSString *const kBBBServerErrorInvalidGrant = @"invalid_grant";
NSString *const kBBBServerErrorInvalidRequest = @"invalid_request";
NSString *const kBBBServerErrorInvalidClient = @"invalid_client";
NSString *const kBBBServerErrorUsernameAlreadyTaken = @"username_already_taken";
NSString *const kBBBServerErrorCountryGeoblocked = @"country_geoblocked";
NSString *const kBBBServerErrorClientLimitReached = @"client_limit_reached";

//End point URLS
NSString *const kBBBAuthServiceURLOAUTH2 = @"oauth2/token";
NSString *const kBBBAuthServiceURLTokensRevoke = @"tokens/revoke";
NSString *const kBBBAuthServiceURLClients = @"clients";
NSString *const kBBBAuthServiceURLPasswordReset = @"password/reset";

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
