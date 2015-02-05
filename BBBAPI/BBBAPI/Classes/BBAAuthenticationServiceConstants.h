//
//  BBAAuthenticationServiceConstants.h
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 04/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *const kBBAAuthServiceName;
extern NSString *const kBBAAuthServiceTokensName;
extern NSString *const kBBAAuthServiceClientsName;

//Server oauth2 grant types
extern NSString *const kBBAGrantTypePassword;
extern NSString *const kBBAGrantTypeRefreshToken;
extern NSString *const kBBAGrantTypeRegistration;

//Server JSON dictionary keys
extern NSString *const kBBAAuthKeyGrantType;
extern NSString *const kBBAAuthKeyUsername;
extern NSString *const kBBAAuthKeyPassword;
extern NSString *const kBBAAuthKeyUserId;
extern NSString *const kBBAAuthKeyUserURI;
extern NSString *const kBBAAuthKeyUserUserName;
extern NSString *const kBBAAuthKeyUserFirstName;
extern NSString *const kBBAAuthKeyUserLastName;
extern NSString *const kBBAAuthKeyClientId;
extern NSString *const kBBAAuthKeyClientURI;
extern NSString *const kBBAAuthKeyClientSecret;
extern NSString *const kBBAAuthKeyLastUsedDate;
extern NSString *const kBBAAuthKeyAccessToken;
extern NSString *const kBBAAuthKeyExpiresIn;
extern NSString *const kBBAAuthKeyTokenType;
extern NSString *const kBBAAuthKeyRefreshToken;
extern NSString *const kBBAAuthKeyFirstName;
extern NSString *const kBBAAuthKeyLastName;
extern NSString *const kBBAAuthKeyAcceptedTerms;
extern NSString *const kBBAAuthKeyAllowMarketing;
extern NSString *const kBBAAuthKeyClientName;
extern NSString *const kBBAAuthKeyClientBrand;
extern NSString *const kBBAAuthKeyClientOS;
extern NSString *const kBBAAuthKeyClientModel;

//Errors returned by the server
extern NSString *const kBBAServerKeyError;
extern NSString *const kBBAServerKeyErrorReason;
extern NSString *const kBBAServerErrorInvalidGrant;
extern NSString *const kBBAServerErrorInvalidRequest;
extern NSString *const kBBAServerErrorInvalidClient;
extern NSString *const kBBAServerErrorUsernameAlreadyTaken;
extern NSString *const kBBAServerErrorCountryGeoblocked;
extern NSString *const kBBAServerErrorClientLimitReached;

//End point URLS
extern NSString *const kBBAAuthServiceURLOAUTH2;
extern NSString *const kBBAAuthServiceURLTokensRevoke;
extern NSString *const kBBAAuthServiceURLClients;
extern NSString *const kBBAAuthServiceURLPasswordReset;
//Grant types
typedef NS_ENUM(NSInteger, BBAGrantType) {
    BBAGrantTypePassword = 1,
    BBAGrantTypeRegistration = 2,
    BBAGrantTypeRefreshToken = 3,
};

//Auth service error codes
typedef NS_ENUM(NSInteger, BBAAuthServiceErrorCode) {
    BBAAuthServiceErrorCodeInvalidRequest = 1000,
    BBAAuthServiceErrorCodeInvalidGrant = 1001,
    BBAAuthServiceErrorCodeInvalidClient = 1002,

    BBAAuthServiceErrorCodeUsernameAlreadyTaken = 1003,
    BBAAuthServiceErrorCodeClientLimitReached = 1004,
    BBAAuthServiceErrorCodeCountryGeoblocked = 1005,

    BBAAuthServiceErrorCodeCouldNotParseAuthData = 1006,

    BBAAuthServiceErrorCodeInvalidResponse = 1007,
};

@interface BBAAuthenticationServiceConstants : NSObject
+ (NSString *) stringGrantType:(BBAGrantType)type;
@end
