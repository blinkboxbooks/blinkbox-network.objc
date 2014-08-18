//
//  BBBTokensResponseMapper.m
//  BBBAPI
//
//  Created by Owen Worley on 12/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBTokensResponseMapper.h"
#import "BBBAuthenticationServiceConstants.h"
#import "BBBAuthServiceErrorParser.h"
#import "BBBJSONResponseMapper.h"

@interface BBBTokensResponseMapper ()
@property (nonatomic, strong) BBBAuthServiceErrorParser *errorParser;
@property (nonatomic, strong) BBBJSONResponseMapper *jsonMapper;
@end

@implementation BBBTokensResponseMapper

- (BBBAuthServiceErrorParser *) errorParser{
    if (_errorParser == nil) {
        _errorParser = [BBBAuthServiceErrorParser new];
    }
    return _errorParser;
}

- (BBBJSONResponseMapper *) jsonMapper{
    if (_jsonMapper == nil) {
        _jsonMapper = [BBBJSONResponseMapper new];
    }
    return _jsonMapper;
}

- (NSNumber *) responseFromData:(NSData *)data
               response:(NSURLResponse *)response
                  error:(NSError *__autoreleasing *)error{
    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];

    //Success
    if (statusCode == 200) {
        return @(YES);
    }

    //Parse response for JSON error
    id JSON = [self.jsonMapper responseFromData:data response:response error:nil];

    if (JSON && [JSON isKindOfClass:[NSDictionary class]]) {
        NSError *serverError = [self.errorParser errorForResponseJSON:JSON
                                                           statusCode:statusCode];
        if (serverError) {
            if (error) {
                *error = serverError;
            }
            return @(NO);
        }
    }


    //No JSON errors, what is this response?
    if (error) {
        *error = [NSError errorWithDomain:kBBBAuthServiceName
                                     code:BBBAuthServiceErrorCodeInvalidResponse
                                 userInfo:nil];
    }
    return @(NO);

}
@end
