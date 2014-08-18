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

    //Register user+client call
    if ([URLPath hasSuffix:kBBBAuthServiceURLOAUTH2] &&
        statusCode == 200 && [self data:data hasFields:[self registrationKeys]]) {
        return YES;
    }

    //Login with client, refresh token with client:
    else if ([URLPath hasSuffix:kBBBAuthServiceURLOAUTH2] &&
             statusCode == 200 && [self data:data hasFields:[self loginUserAndClientKeys]]) {
        return YES;
    }

    //Login without client, refresh without client
    else if ([URLPath hasSuffix:kBBBAuthServiceURLOAUTH2] &&
             statusCode == 200 && [self data:data hasFields:[self loginUserKeys]]) {
        return YES;
    }

    //Revoke Token
    else if ([URLPath hasSuffix:kBBBAuthServiceURLTokensRevoke] &&
             data != nil && statusCode == 200) {
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