//
//  BBBLibraryResponseMapper.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 04/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBLibraryResponseMapper.h"
#import "BBBConnection.h"
#import "BBBAuthenticationService.h"
#import "BBBStatusResponseMapper.h"
#import "BBBLibraryResponse.h"
#import "BBBAPIErrors.h"

@implementation BBBLibraryResponseMapper

- (id) responseFromData:(NSData *)data
               response:(NSURLResponse *)response
                  error:(NSError *__autoreleasing *)error{
    
    if (!response) {
        if (error != nil) {
            *error = [NSError errorWithDomain:BBBResponseMappingErrorDomain
                                         code:BBBResponseMappingErrorUnreadableData
                                     userInfo:nil];
        }
        return nil;
    }
    
    BBBStatusResponseMapper *mapper = [BBBStatusResponseMapper new];
    
    NSNumber *success = [mapper responseFromData:nil
                                        response:response
                                           error:error];
    
    if (![success boolValue]) {
        return nil;
    }
    
    id parsedJSON = [super responseFromData:data
                                   response:response
                                      error:error];
    if (!parsedJSON) {
        NSError *anError = *error;
        BOOL dataUnreadableError = (anError.code == NSPropertyListReadCorruptError &&
                                    [anError.domain isEqualToString:NSCocoaErrorDomain]);
        if (dataUnreadableError) {
            
            *error = [NSError errorWithDomain:BBBConnectionErrorDomain
                                         code:BBBAPIUnreadableData
                                     userInfo:nil];
        }
        return nil;
    }
    
    
    BBBLibraryResponse *libraryResponse = [BBBLibraryResponse new];
    
    if (![libraryResponse parseJSON:parsedJSON error:error]) {
        return nil;
    }
    
    return libraryResponse;
}

@end
