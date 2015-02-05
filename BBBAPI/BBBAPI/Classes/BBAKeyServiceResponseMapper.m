//
//  BBAKeyServiceResponseMapper.m
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 01/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBAKeyServiceResponseMapper.h"
#import "BBAConnection.h"

NSString *const BBAKeyServiceResponseMapperErrorDomain = @"api.keyServiceResponseMappingErrorDomain";


@implementation BBAKeyServiceResponseMapper
- (id) responseFromData:(NSData *)data
               response:(NSHTTPURLResponse *)response
                  error:(NSError **)error{

    switch (response.statusCode) {
        case BBAHTTPCreated: //Intentional fall through, 200 and 201 are both success cases
        case BBAHTTPSuccess:
            if (data) {
                return data;
            }
            break;

        case BBAHTTPUnauthorized:
            [self setError:error withType:BBAKeyServiceResponseMapperErrorNotAuthorised];
            return nil;

        case BBAHTTPForbidden:
            [self setError:error withType:BBAKeyServiceResponseMapperErrorNotAllowed];
            return nil;

        case BBAHTTPConflict:
            [self setError:error withType:BBAKeyServiceResponseMapperErrorKeyLimitExceeded];
            return nil;

        case BBAHTTPNotFound:
            [self setError:error withType:BBAKeyServiceResponseMapperErrorNotFound];
            return nil;
    }

    [self setError:error withType:BBAKeyServiceResponseMapperErrorBadResponse];
    return nil;
}

- (void) setError:(NSError **)error withType:(BBAKeyServiceResponseMapperError)errorType{
    if(!error){
        return;
    }

    *error = [NSError errorWithDomain:BBAKeyServiceResponseMapperErrorDomain
                                 code:errorType
                             userInfo:nil];

}
@end
