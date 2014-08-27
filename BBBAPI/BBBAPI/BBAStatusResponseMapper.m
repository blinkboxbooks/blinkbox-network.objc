//
//  BBASuccesLibraryResponseMapper.m
//  BBAAPI
//
//  Created by Tomek Kuźma on 14/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAStatusResponseMapper.h"
#import "BBAConnection.h"
#import "BBAAuthenticationService.h"
#import "BBAAuthenticationServiceConstants.h"
#import "BBAAPIErrors.h"

@implementation BBAStatusResponseMapper

- (id) responseFromData:(NSData *)data
               response:(NSHTTPURLResponse *)response
                  error:(NSError **)error{
    
    NSNumber *success = @NO;
    
    switch (response.statusCode) {
        case BBAHTTPSuccess:{
            success =  @YES;
            break;
        }
        case BBAHTTPUnauthorized:{
            *error = [NSError errorWithDomain:kBBAAuthServiceName
                                         code:BBAAPIErrorUnauthorised
                                     userInfo:nil];
            break;
        }
        case BBAHTTPNotFound:{
            *error =  [NSError errorWithDomain:BBAConnectionErrorDomain
                                          code:BBAAPIErrorNotFound
                                      userInfo:nil];
            break;
        }
        case BBAHTTPForbidden:{
            *error =  [NSError errorWithDomain:BBAConnectionErrorDomain
                                          code:BBAAPIErrorForbidden
                                      userInfo:nil];
            break;
        }
        case BBAHTTPServerError:{
            *error = [NSError errorWithDomain:BBAConnectionErrorDomain
                                         code:BBAAPIServerError
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
