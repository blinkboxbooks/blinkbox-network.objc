//
//  BBAKeyServiceResponseMapper.m
//  BBBAPI
//
//  Created by Owen Worley on 01/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBAKeyServiceResponseMapper.h"

NSString *const BBAKeyServiceResponseMapperErrorDomain = @"api.keyServiceResponseMappingErrorDomain";

/**
 *  Mapping of possible status code responses from the key service
 */
typedef NS_ENUM(NSUInteger, BBAKeyServiceResponseCode){
    /**
     *  201 - Success
     */
    BBAKeyServiceResponseCodeSuccess = 201,
    /**
     *  User is not authorised
     */
    BBAKeyServiceResponseCodeNotAuthorised = 401,
    /**
     *  User is not allowed to access the key
     */
    BBAKeyServiceResponseCodeNotAllowed = 403,
    /**
     *  User has fetched too many keys
     */
    BBAKeyServiceResponseCodeKeyLimitExceeded = 409,
    /**
     *  Key was not found
     */
    BBAKeyServiceResponseCodeNotFound = 404,
};



@implementation BBAKeyServiceResponseMapper
- (id) responseFromData:(NSData *)data
               response:(NSHTTPURLResponse *)response
                  error:(NSError **)error{

    switch (response.statusCode) {
        case BBAKeyServiceResponseCodeSuccess:
            if (data) {
                return data;
            }
            break;

        case BBAKeyServiceResponseCodeNotAuthorised:
            [self setError:error withType:BBAKeyServiceResponseMapperErrorNotAuthorised];
            return nil;

        case BBAKeyServiceResponseCodeNotAllowed:
            [self setError:error withType:BBAKeyServiceResponseMapperErrorNotAllowed];
            return nil;

        case BBAKeyServiceResponseCodeKeyLimitExceeded:
            [self setError:error withType:BBAKeyServiceResponseMapperErrorKeyLimitExceeded];
            return nil;

        case BBAKeyServiceResponseCodeNotFound:
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
