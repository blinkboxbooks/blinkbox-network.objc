//
//  BBBAuthResponseMapper.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 31/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//
// Source for docs
//http://jira.blinkbox.local/confluence/display/PT/Authentication+Service+Rest+API+Guide#AuthenticationServiceRestAPIGuide-TokenResponse

#import "BBBAuthResponseMapper.h"
#import "BBBAuthData.h"

@class BBBAuthData;

@implementation BBBAuthResponseMapper

- (id)responseFromData:(NSData *)data
              response:(NSURLResponse *)response
                 error:(NSError *__autoreleasing *)error{
#if 0
    NSError *JSONError = nil;
    id JSON = [super responseFromData:data response:response error:&JSONError];
    
    NSDictionary *userInfo;
    
    if (!JSON) {
        if (JSONError) {
            userInfo = @{NSUnderlyingErrorKey : JSONError};
        }
        *error = [NSError errorWithDomain:BBBResponseMappingErrorDomain
                                     code:BBBResponseMappingErrorUnreadableData
                                 userInfo:userInfo];
        return nil;
    }
    
    *error = nil;
    
    if (![JSON isKindOfClass:[NSDictionary class]]) {
        *error = [NSError errorWithDomain:BBBResponseMappingErrorDomain
                                     code:BBBResponseMappingErrorUnexpectedDataFormat
                                 userInfo:nil];
        return nil;
    }
    
    
    BBBAuthData *authData = [BBBAuthData new];
    
    NSDictionary *tokenResponse = (NSDictionary *)JSON;
    
    NSString *accessToken = tokenResponse[@"access_token"];
    NSString *refreshToken = tokenResponse[@"refresh_token"];
    NSString *clientId = tokenResponse[@"client_id"];
    NSString *clientURI = tokenResponse[@"client_uri"];
    
    NSString *clientName = tokenResponse[@"client_name"];
    NSString *clientModel = tokenResponse[@"client_model"];
    NSString *clientSecret = tokenResponse[@"client_secret"];
    
    NSNumber *expiresIn = tokenResponse[@"expires_in"];
    
    NSString *userId = tokenResponse[@"user_id"];
    NSString *userURI = tokenResponse[@"user_uri"];
    
    NSString *userUsername = tokenResponse[@"user_username"];
    NSString *userFirstName = tokenResponse[@"client_secret"];
    NSString *userLastName = tokenResponse[@"user_last_name"];
    

    authData.accessToken = accessToken;
    authData.refreshToken = refreshToken;
    
    authData.accessTokenExpirationDate = nil;
    
    authData.userId = userId;
    authData.userURI = userURI;
    
    authData.clientId = clientId;
    authData.clientSecret = clientSecret;
    authData.clientURI = clientURI;
    
    return authData;
#endif
    return nil;
}
@end
