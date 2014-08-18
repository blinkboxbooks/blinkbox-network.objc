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
#import "BBBAuthServiceErrorParser.h"


@interface BBBAuthResponseMapper ()
@property (nonatomic, strong) BBBAuthServiceErrorParser *errorParser;
@end

@implementation BBBAuthResponseMapper


- (BBBAuthServiceErrorParser *) errorParser{
    if (_errorParser == nil) {
        _errorParser = [BBBAuthServiceErrorParser new];
    }
    return _errorParser;
}

- (BBBAuthData *)authDataForResponse:(NSURLResponse *)response
                                JSON:(NSDictionary *)JSON
                              statusCode:(NSInteger)statusCode
                                   error:(NSError **)error{

    BBBAuthData *authData = [[BBBAuthData alloc]initWithDictionary:JSON
                                                          response:response];


    if (![authData isValidForResponse:response]) {
        if (error != nil) {
            *error =  [NSError errorWithDomain:kBBBAuthServiceName
                                          code:BBBAuthServiceErrorCodeCouldNotParseAuthData
                                      userInfo:nil];
        }
        return nil;
    }

    return authData;
}

- (BBBAuthData *)responseFromData:(NSData *)data
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
    BBBAuthData *authData = [self authDataForResponse:response
                                                JSON:tokenResponse
                                               statusCode:statusCode
                                                    error:&authParseError];

    //Successful auth data parse
    if (authData) {
        return authData;
    }

    //Handle service error responses
    NSError *serviceError = [self.errorParser errorForResponseJSON:tokenResponse statusCode:statusCode];
    if (serviceError != nil) {
        *error = serviceError;
        return nil;
    }
    
    //Auth data parse returned an error
    if (authData == nil && authParseError != nil) {
        *error = authParseError;
        return nil;
    }

    NSAssert(NO, @"Unhandled error");
    return nil;


}
@end
