//
//  BBBSuccesLibraryResponseMapper.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 14/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBStatusResponseMapper.h"
#import "BBBConnection.h"
#import "BBBAuthenticationService.h"

@implementation BBBStatusResponseMapper

- (id) responseFromData:(NSData *)data
               response:(NSHTTPURLResponse *)response
                  error:(NSError **)error{
    
    NSNumber *success = @NO;
    
    switch (response.statusCode) {
        case BBBHTTPSuccess:{
            success =  @YES;
            break;
        }
        case BBBHTTPUnauthorized:{
            *error = [NSError errorWithDomain:BBBAuthenticaitonServiceErrorDomain
                                         code:BBBAuthenticationServiceErrorUnauthorized
                                     userInfo:nil];
            break;
        }
        case BBBHTTPNotFound:{
            *error =  [NSError errorWithDomain:BBBConnectionErrorDomain
                                          code:BBBConnectionErrorNotFound
                                      userInfo:nil];
            break;
        }
        case BBBHTTPForbidden:{
            *error =  [NSError errorWithDomain:BBBConnectionErrorDomain
                                          code:BBBConnectionErrorForbidden
                                      userInfo:nil];
            break;
        }
        case BBBHTTPServerError:{
            *error = [NSError errorWithDomain:BBBConnectionErrorDomain
                                         code:BBBConnectionErrorServerError
                                     userInfo:nil];
            break;
        }
        default:{
            NSAssert(NO, @"unexpected HTTP status");
            break;
        }
    }
    
    return success;
}
@end
