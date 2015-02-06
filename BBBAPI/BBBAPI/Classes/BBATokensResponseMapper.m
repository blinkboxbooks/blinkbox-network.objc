//
//  BBATokensResponseMapper.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 12/08/2014.
 

#import "BBATokensResponseMapper.h"
#import "BBAAuthenticationServiceConstants.h"
#import "BBAAuthServiceErrorParser.h"
#import "BBAJSONResponseMapper.h"

@interface BBATokensResponseMapper ()
@property (nonatomic, strong) BBAAuthServiceErrorParser *errorParser;
@property (nonatomic, strong) BBAJSONResponseMapper *jsonMapper;
@end

@implementation BBATokensResponseMapper

- (BBAAuthServiceErrorParser *) errorParser{
    if (_errorParser == nil) {
        _errorParser = [BBAAuthServiceErrorParser new];
    }
    return _errorParser;
}

- (BBAJSONResponseMapper *) jsonMapper{
    if (_jsonMapper == nil) {
        _jsonMapper = [BBAJSONResponseMapper new];
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
        *error = [NSError errorWithDomain:kBBAAuthServiceName
                                     code:BBAAuthServiceErrorCodeInvalidResponse
                                 userInfo:nil];
    }
    return @(NO);

}
@end
