//
//  BBBAuthDataValidator.m
//  BBBAPI
//
//  Created by Owen Worley on 12/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBAuthDataValidator.h"
#import "BBBAuthData.h"
#import "BBBAuthenticationServiceConstants.h"
/**
 *  Can be used to make code not stringly-typed and shorter, for example in
 *  KVO, KVC, NSSortDescriptors, NSPredicates
 */
#warning Move to BBBMacros.h when we have one in the API project
#define  BBBKEY(val) NSStringFromSelector(@selector(val))

@implementation BBBAuthDataValidator
- (BOOL) isValid:(BBBAuthData *)data forResponse:(NSURLResponse *)response{

    NSString *URLPath = [[response URL]path];
    NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];

    BOOL hasSuccessCode = (statusCode == 200);

    if(!hasSuccessCode) {
        return NO;
    }

    BOOL hasAuthSuffix = [URLPath hasSuffix:kBBBAuthServiceURLOAUTH2];
    BOOL hasTokensSuffix = [URLPath hasSuffix:kBBBAuthServiceURLTokensRevoke];
    BOOL hasNeededFields = NO;

    //Register user+client call
    hasNeededFields = [self data:data hasFields:[self registrationKeys]];
    if (hasAuthSuffix && hasNeededFields) {
        return YES;
    }

    //Login with client, refresh token with client:
    hasNeededFields = [self data:data hasFields:[self loginUserAndClientKeys]];
    if (hasAuthSuffix && hasNeededFields) {
        return YES;
    }

    //Login without client, refresh without client
    hasNeededFields = [self data:data hasFields:[self loginUserKeys]];
    if (hasAuthSuffix && hasNeededFields) {
        return YES;
    }

    //Revoke Token
    hasNeededFields = (data != nil);
    if (hasTokensSuffix && hasNeededFields) {
        return YES;
    }

    return NO;
}

- (NSArray *)registrationKeys{
    return @[BBBKEY(accessToken),
             BBBKEY(tokenType),
             BBBKEY(accessTokenExpirationDate),
             BBBKEY(refreshToken),
             BBBKEY(userId),
             BBBKEY(userURI),
             BBBKEY(userUserName),
             BBBKEY(userFirstName),
             BBBKEY(userLastName),
             BBBKEY(clientId),
             BBBKEY(clientURI),
             BBBKEY(clientName),
             BBBKEY(clientBrand),
             BBBKEY(clientModel),
             BBBKEY(clientOS),
             BBBKEY(lastUsedDate),
             BBBKEY(clientSecret)
             ];
}

- (NSArray *)loginUserKeys{
    return @[BBBKEY(accessToken),
             BBBKEY(tokenType),
             BBBKEY(accessTokenExpirationDate),
             BBBKEY(refreshToken),
             BBBKEY(userId),
             BBBKEY(userURI),
             BBBKEY(userUserName),
             BBBKEY(userFirstName),
             BBBKEY(userLastName)];
}

- (NSArray *)loginUserAndClientKeys{
    return @[BBBKEY(accessToken),
             BBBKEY(tokenType),
             BBBKEY(accessTokenExpirationDate),
             BBBKEY(refreshToken),
             BBBKEY(userId),
             BBBKEY(userURI),
             BBBKEY(userUserName),
             BBBKEY(userFirstName),
             BBBKEY(userLastName),
             BBBKEY(clientId),
             BBBKEY(clientURI),
             BBBKEY(clientName),
             BBBKEY(clientBrand),
             BBBKEY(clientModel),
             BBBKEY(clientOS),
             BBBKEY(lastUsedDate)];

}

- (BOOL) data:(BBBAuthData *)data hasFields:(NSArray *)fields{
    for (NSString *key in fields) {
        if (![data respondsToSelector:NSSelectorFromString(key)] ||
            [data valueForKey:key] == nil) {
            return NO;
        }
    }
    return YES;
}


@end