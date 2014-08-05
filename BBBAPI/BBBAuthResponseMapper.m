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
#import "BBBAuthenticationServiceConstants.h"
@class BBBAuthData;

@implementation BBBAuthResponseMapper

- (NSError *) errorForResponseJSON:(NSDictionary *)JSON
                        statusCode:(NSInteger)statusCode{

    NSString *serverErrorValue = JSON[kBBBServerKeyError];

    NSError *(^error)(BBBAuthServiceErrorCode code) = ^(BBBAuthServiceErrorCode code) {
        return  [NSError errorWithDomain:kBBBAuthServiceName
                                    code:code
                                userInfo:nil];
    };

    if ([serverErrorValue isEqualToString:kBBBServerErrorInvalidRequest]) {

        NSString *serverErrorReason = JSON[kBBBServerKeyErrorReason];

        if ([serverErrorReason isEqualToString:kBBBServerErrorClientLimitReached]) {
            return  error(BBBAuthServiceErrorCodeClientLimitReached);
        }
        else if ([serverErrorReason isEqualToString:kBBBServerErrorCountryGeoblocked]){
            return error(BBBAuthServiceErrorCodeCountryGeoblocked);
        }
        else if ([serverErrorReason isEqualToString:kBBBServerErrorUsernameAlreadyTaken]){
            return error(BBBAuthServiceErrorCodeUsernameAlreadyTaken);
        }

        NSAssert(NO, @"Unknown error reason %@", serverErrorReason);
        return error(BBBAuthServiceErrorCodeInvalidRequest);

    }

    if ([serverErrorValue isEqualToString:kBBBServerErrorInvalidGrant]) {
        return  error(BBBAuthServiceErrorCodeInvalidGrant);
    }

    if ([serverErrorValue isEqualToString:kBBBServerErrorInvalidClient]) {
        return error(BBBAuthServiceErrorCodeInvalidClient);
    }

    return nil;
}

- (BBBAuthData *)authDataForResponseJSON:(NSDictionary *)JSON
                              statusCode:(NSInteger)statusCode
                                   error:(NSError **)error{

#warning is it 200 for all requests?
    if (statusCode != 200) {
        return nil;
    }

    BBBAuthData *authData = [[BBBAuthData alloc]initWithDictionary:JSON];

    if (![authData isValid]) {
        if (error != nil) {
            *error =  [NSError errorWithDomain:kBBBAuthServiceName
                                          code:BBBAuthServiceErrorCodeCouldNotParseAuthData
                                      userInfo:nil];
        }
        return nil;
    }

    return authData;
}

- (id)responseFromData:(NSData *)data
              response:(NSURLResponse *)response
                 error:(NSError *__autoreleasing *)error{

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

    NSInteger statusCode = [((NSHTTPURLResponse *)response) statusCode];

    //Cast response to dictionary
    NSDictionary *tokenResponse = (NSDictionary *)JSON;

    //Attempt to parse data as an authdata response.
    NSError *authParseError = nil;
    BBBAuthData *authData = [self authDataForResponseJSON:tokenResponse
                                               statusCode:statusCode
                                                    error:&authParseError];

    //Successful auth data parse
    if (authData) {
        return authData;
    }

    //Auth data parse returned an error
    if (authData == nil && authParseError != nil) {
        *error = authParseError;
        return nil;
    }

    //Handle service error responses
    NSError *serviceError = [self errorForResponseJSON:tokenResponse statusCode:statusCode];
    if (serviceError != nil) {
        *error = serviceError;
        return nil;
    }

    NSAssert(NO, @"Unhandled error");
    return nil;


}
@end
