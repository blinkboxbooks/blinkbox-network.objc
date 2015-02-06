//
//  BBAAuthenticationServiceConstants.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 04/08/2014.
 

#import "BBAAuthenticationServiceConstants.h"

@implementation BBAAuthenticationServiceConstants

NSString *const kBBAAuthServiceName = @"com.BBA.AuthenticationService";
NSString *const kBBAAuthServiceTokensName = @"com.BBA.AuthenticationService.tokens";
NSString *const kBBAAuthServiceClientsName = @"com.BBA.AuthenticationService.clients";
//Server oauth2 grant types
NSString *const kBBAGrantTypePassword = @"password";
NSString *const kBBAGrantTypeRefreshToken = @"refresh_token";
NSString *const kBBAGrantTypeRegistration = @"urn:blinkbox:oauth:grant-type:registration";

//Server JSON dictionary keys
NSString *const kBBAAuthKeyGrantType = @"grant_type";
NSString *const kBBAAuthKeyUsername = @"username";
NSString *const kBBAAuthKeyPassword = @"password";
NSString *const kBBAAuthKeyUserId = @"user_id";
NSString *const kBBAAuthKeyUserURI = @"user_uri";
NSString *const kBBAAuthKeyUserUserName = @"user_username";
NSString *const kBBAAuthKeyUserFirstName = @"user_first_name";
NSString *const kBBAAuthKeyUserLastName = @"user_last_name";
NSString *const kBBAAuthKeyClientId = @"client_id";
NSString *const kBBAAuthKeyClientURI = @"client_uri";
NSString *const kBBAAuthKeyClientSecret = @"client_secret";
NSString *const kBBAAuthKeyLastUsedDate = @"last_used_date";
NSString *const kBBAAuthKeyAccessToken = @"access_token";
NSString *const kBBAAuthKeyExpiresIn = @"expires_in";
NSString *const kBBAAuthKeyTokenType = @"token_type";
NSString *const kBBAAuthKeyRefreshToken = @"refresh_token";
NSString *const kBBAAuthKeyFirstName = @"first_name";
NSString *const kBBAAuthKeyLastName = @"last_name";
NSString *const kBBAAuthKeyAcceptedTerms = @"accepted_terms_and_conditions";
NSString *const kBBAAuthKeyAllowMarketing = @"allow_marketing_communications";
NSString *const kBBAAuthKeyClientName = @"client_name";
NSString *const kBBAAuthKeyClientBrand = @"client_brand";
NSString *const kBBAAuthKeyClientOS = @"client_os";
NSString *const kBBAAuthKeyClientModel = @"client_model";

//Errors returned by the server
NSString *const kBBAServerKeyError = @"error";
NSString *const kBBAServerKeyErrorReason = @"error_reason";
NSString *const kBBAServerErrorInvalidGrant = @"invalid_grant";
NSString *const kBBAServerErrorInvalidRequest = @"invalid_request";
NSString *const kBBAServerErrorInvalidClient = @"invalid_client";
NSString *const kBBAServerErrorUsernameAlreadyTaken = @"username_already_taken";
NSString *const kBBAServerErrorCountryGeoblocked = @"country_geoblocked";
NSString *const kBBAServerErrorClientLimitReached = @"client_limit_reached";

//End point URLS
NSString *const kBBAAuthServiceURLOAUTH2 = @"oauth2/token";
NSString *const kBBAAuthServiceURLTokensRevoke = @"tokens/revoke";
NSString *const kBBAAuthServiceURLClients = @"clients";
NSString *const kBBAAuthServiceURLPasswordReset = @"password/reset";

+ (NSString *) stringGrantType:(BBAGrantType)type{

    NSString *grantType = @"";
    switch (type) {
        case BBAGrantTypePassword:
            grantType = kBBAGrantTypePassword;
            break;
        case BBAGrantTypeRefreshToken:
            grantType = kBBAGrantTypeRefreshToken;
            break;
        case BBAGrantTypeRegistration:
            grantType = kBBAGrantTypeRegistration;
            break;
        default:
            break;
    }

    NSAssert([grantType length]>0, @"Grant type not found for type %ld", type);
    return grantType;
}
@end
