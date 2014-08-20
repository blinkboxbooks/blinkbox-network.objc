//
//  BBBAuthenticationServiceConstants.h
//  BBBAPI
//
//  Created by Owen Worley on 04/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *const kBBBAuthServiceName;
extern NSString *const kBBBAuthServiceTokensName;
extern NSString *const kBBBAuthServiceClientsName;

//Server oauth2 grant types
extern NSString *const kBBBGrantTypePassword;
extern NSString *const kBBBGrantTypeRefreshToken;
extern NSString *const kBBBGrantTypeRegistration;

//Server JSON dictionary keys
extern NSString *const kBBBAuthKeyGrantType;
extern NSString *const kBBBAuthKeyUsername;
extern NSString *const kBBBAuthKeyPassword;
extern NSString *const kBBBAuthKeyUserId;
extern NSString *const kBBBAuthKeyUserURI;
extern NSString *const kBBBAuthKeyUserUserName;
extern NSString *const kBBBAuthKeyUserFirstName;
extern NSString *const kBBBAuthKeyUserLastName;
extern NSString *const kBBBAuthKeyClientId;
extern NSString *const kBBBAuthKeyClientURI;
extern NSString *const kBBBAuthKeyClientSecret;
extern NSString *const kBBBAuthKeyLastUsedDate;
extern NSString *const kBBBAuthKeyAccessToken;
extern NSString *const kBBBAuthKeyExpiresIn;
extern NSString *const kBBBAuthKeyTokenType;
extern NSString *const kBBBAuthKeyRefreshToken;
extern NSString *const kBBBAuthKeyFirstName;
extern NSString *const kBBBAuthKeyLastName;
extern NSString *const kBBBAuthKeyAcceptedTerms;
extern NSString *const kBBBAuthKeyAllowMarketing;
extern NSString *const kBBBAuthKeyClientName;
extern NSString *const kBBBAuthKeyClientBrand;
extern NSString *const kBBBAuthKeyClientOS;
extern NSString *const kBBBAuthKeyClientModel;

//Errors returned by the server
extern NSString *const kBBBServerKeyError;
extern NSString *const kBBBServerKeyErrorReason;
extern NSString *const kBBBServerErrorInvalidGrant;
extern NSString *const kBBBServerErrorInvalidRequest;
extern NSString *const kBBBServerErrorInvalidClient;
extern NSString *const kBBBServerErrorUsernameAlreadyTaken;
extern NSString *const kBBBServerErrorCountryGeoblocked;
extern NSString *const kBBBServerErrorClientLimitReached;

//End point URLS
extern NSString *const kBBBAuthServiceURLOAUTH2;
extern NSString *const kBBBAuthServiceURLTokensRevoke;
extern NSString *const kBBBAuthServiceURLClients;
extern NSString *const kBBBAuthServiceURLPasswordReset;
//Grant types
typedef NS_ENUM(NSInteger, BBBGrantType) {
    BBBGrantTypePassword = 1,
    BBBGrantTypeRegistration = 2,
    BBBGrantTypeRefreshToken = 3,
};

//Auth service error codes
typedef NS_ENUM(NSInteger, BBBAuthServiceErrorCode) {
    BBBAuthServiceErrorCodeInvalidRequest = 1000,
    BBBAuthServiceErrorCodeInvalidGrant = 1001,
    BBBAuthServiceErrorCodeInvalidClient = 1002,

    BBBAuthServiceErrorCodeUsernameAlreadyTaken = 1003,
    BBBAuthServiceErrorCodeClientLimitReached = 1004,
    BBBAuthServiceErrorCodeCountryGeoblocked = 1005,

    BBBAuthServiceErrorCodeCouldNotParseAuthData = 1006,

    BBBAuthServiceErrorCodeInvalidResponse = 1007,
};

@interface BBBAuthenticationServiceConstants : NSObject
+ (NSString *) stringGrantType:(BBBGrantType)type;
@end
