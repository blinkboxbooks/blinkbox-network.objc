//
//  BBAAuthDataValidator.m
//  BBAAPI
//
//  Created by Owen Worley on 12/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAAuthDataValidator.h"
#import "BBAAuthData.h"
#import "BBAAuthenticationServiceConstants.h"
#import "BBAMacros.h"

/**
 *  Can be used to make code not stringly-typed and shorter, for example in
 *  KVO, KVC, NSSortDescriptors, NSPredicates
 */

@implementation BBAAuthDataValidator
- (BOOL) isValid:(BBAAuthData *)data forResponse:(NSURLResponse *)response{

    NSString *URLPath = [[response URL]path];
    NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];

    BOOL hasSuccessCode = (statusCode == 200);

    if(!hasSuccessCode) {
        return NO;
    }

    BOOL hasAuthSuffix = [URLPath hasSuffix:kBBAAuthServiceURLOAUTH2];
    BOOL hasTokensSuffix = [URLPath hasSuffix:kBBAAuthServiceURLTokensRevoke];
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
    return @[BBAKEY(accessToken),
             BBAKEY(tokenType),
             BBAKEY(accessTokenExpirationDate),
             BBAKEY(refreshToken),
             BBAKEY(userId),
             BBAKEY(userURI),
             BBAKEY(userUserName),
             BBAKEY(userFirstName),
             BBAKEY(userLastName),
             BBAKEY(clientId),
             BBAKEY(clientURI),
             BBAKEY(clientName),
             BBAKEY(clientBrand),
             BBAKEY(clientModel),
             BBAKEY(clientOS),
             BBAKEY(lastUsedDate),
             BBAKEY(clientSecret)
             ];
}

- (NSArray *)loginUserKeys{
    return @[BBAKEY(accessToken),
             BBAKEY(tokenType),
             BBAKEY(accessTokenExpirationDate),
             BBAKEY(refreshToken),
             BBAKEY(userId),
             BBAKEY(userURI),
             BBAKEY(userUserName),
             BBAKEY(userFirstName),
             BBAKEY(userLastName)];
}

- (NSArray *)loginUserAndClientKeys{
    return @[BBAKEY(accessToken),
             BBAKEY(tokenType),
             BBAKEY(accessTokenExpirationDate),
             BBAKEY(refreshToken),
             BBAKEY(userId),
             BBAKEY(userURI),
             BBAKEY(userUserName),
             BBAKEY(userFirstName),
             BBAKEY(userLastName),
             BBAKEY(clientId),
             BBAKEY(clientURI),
             BBAKEY(clientName),
             BBAKEY(clientBrand),
             BBAKEY(clientModel),
             BBAKEY(clientOS),
             BBAKEY(lastUsedDate)];

}

- (BOOL) data:(BBAAuthData *)data hasFields:(NSArray *)fields{
    for (NSString *key in fields) {
        if (![data respondsToSelector:NSSelectorFromString(key)] ||
            [data valueForKey:key] == nil) {
            return NO;
        }
    }
    return YES;
}


@end