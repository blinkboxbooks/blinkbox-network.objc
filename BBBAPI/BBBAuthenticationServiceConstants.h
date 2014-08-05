//
//  BBBAuthenticationServiceConstants.h
//  BBBAPI
//
//  Created by Owen Worley on 04/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *const kBBBAuthServiceName;

extern NSString *const kBBBGrantTypePassword;
extern NSString *const kBBBGrantTypeRefreshToken;
extern NSString *const kBBBGrantTypeRegistration;

extern NSString *const kBBBAuthKeyGrantType;

extern NSString *const kBBBAuthKeyUsername;
extern NSString *const kBBBAuthKeyPassword;

extern NSString *const kBBBAuthKeyClientId;
extern NSString *const kBBBAuthKeyClientSecret;

//Errors returned by the server
extern NSString *const kBBBServerKeyError;
extern NSString *const kBBBServerKeyErrorReason;
extern NSString *const kBBBServerErrorInvalidGrant;
extern NSString *const kBBBServerErrorInvalidRequest;
extern NSString *const kBBBServerErrorInvalidClient;
extern NSString *const kBBBServerErrorUsernameAlreadyTaken;
extern NSString *const kBBBServerErrorCountryGeoblocked;
extern NSString *const kBBBServerErrorClientLimitReached;



typedef NS_ENUM(NSInteger, BBBGrantType) {
    BBBGrantTypePassword = 1,
    BBBGrantTypeRegistration = 2,
    BBBGrantTypeRefreshToken = 3,
};

typedef NS_ENUM(NSInteger, BBBAuthServiceErrorCode) {
    BBBAuthServiceErrorCodeInvalidRequest,
    BBBAuthServiceErrorCodeInvalidGrant,
    BBBAuthServiceErrorCodeInvalidClient,

    BBBAuthServiceErrorCodeUsernameAlreadyTaken,
    BBBAuthServiceErrorCodeClientLimitReached,
    BBBAuthServiceErrorCodeCountryGeoblocked,

    BBBAuthServiceErrorCodeCouldNotParseAuthData,
};

@interface BBBAuthenticationServiceConstants : NSObject
+ (NSString *) stringGrantType:(BBBGrantType)type;
@end
