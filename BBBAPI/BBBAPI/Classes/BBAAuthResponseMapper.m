//
//  BBAAuthResponseMapper.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 31/07/2014.
 
// Source for docs
//http://jira.blinkbox.local/confluence/display/PT/Authentication+Service+Rest+API+Guide#AuthenticationServiceRestAPIGuide-TokenResponse

#import "BBAAuthResponseMapper.h"
#import "BBAAuthData.h"
#import "BBAAuthenticationServiceConstants.h"
#import "BBAAuthServiceErrorParser.h"


@interface BBAAuthResponseMapper ()
@property (nonatomic, strong) BBAAuthServiceErrorParser *errorParser;
@end

@implementation BBAAuthResponseMapper


- (BBAAuthServiceErrorParser *) errorParser{
    if (_errorParser == nil) {
        _errorParser = [BBAAuthServiceErrorParser new];
    }
    return _errorParser;
}

- (BBAAuthData *) authDataForResponse:(NSURLResponse *)response
                                 JSON:(NSDictionary *)JSON
                           statusCode:(NSInteger)statusCode
                                error:(NSError **)error{

    BBAAuthData *authData = [[BBAAuthData alloc]initWithDictionary:JSON
                                                          response:response];


    if (![authData isValidForResponse:response]) {
        if (error != nil) {
            *error =  [NSError errorWithDomain:kBBAAuthServiceName
                                          code:BBAAuthServiceErrorCodeCouldNotParseAuthData
                                      userInfo:nil];
        }
        return nil;
    }

    return authData;
}

- (BBAAuthData *) responseFromData:(NSData *)data
                          response:(NSURLResponse *)response
                             error:(NSError *__autoreleasing *)error{

    NSError *JSONError = nil;
    id JSON = [super responseFromData:data response:response error:&JSONError];

    NSDictionary *userInfo;

    if (!JSON) {
        if (JSONError) {
            userInfo = @{NSUnderlyingErrorKey : JSONError};
        }
        *error = [NSError errorWithDomain:BBAResponseMappingErrorDomain
                                     code:BBAResponseMappingErrorUnreadableData
                                 userInfo:userInfo];
        return nil;

    }

    *error = nil;

    if (![JSON isKindOfClass:[NSDictionary class]]) {
        *error = [NSError errorWithDomain:BBAResponseMappingErrorDomain
                                     code:BBAResponseMappingErrorUnexpectedDataFormat
                                 userInfo:nil];
        return nil;
    }

    NSInteger statusCode = [((NSHTTPURLResponse *)response) statusCode];

    //Cast response to dictionary
    NSDictionary *tokenResponse = (NSDictionary *)JSON;

    //Attempt to parse data as an authdata response.
    NSError *authParseError = nil;
    BBAAuthData *authData = [self authDataForResponse:response
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
