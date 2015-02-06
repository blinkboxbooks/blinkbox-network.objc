//
//  BBALibraryResponseMapper.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 04/08/2014.
 

#import "BBALibraryResponseMapper.h"
#import "BBAConnection.h"
#import "BBAAuthenticationService.h"
#import "BBAStatusResponseMapper.h"
#import "BBALibraryResponse.h"
#import "BBAAPIErrors.h"

@implementation BBALibraryResponseMapper

- (id) responseFromData:(NSData *)data
               response:(NSURLResponse *)response
                  error:(NSError *__autoreleasing *)error{
    
    if (!response) {
        if (error != nil) {
            *error = [NSError errorWithDomain:BBAResponseMappingErrorDomain
                                         code:BBAResponseMappingErrorUnreadableData
                                     userInfo:nil];
        }
        return nil;
    }
    
    BBAStatusResponseMapper *mapper = [BBAStatusResponseMapper new];
    
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
            
            *error = [NSError errorWithDomain:BBAConnectionErrorDomain
                                         code:BBAAPIUnreadableData
                                     userInfo:nil];
        }
        return nil;
    }
    
    
    BBALibraryResponse *libraryResponse = [BBALibraryResponse new];
    
    if (![libraryResponse parseJSON:parsedJSON error:error]) {
        return nil;
    }
    
    return libraryResponse;
}

@end
