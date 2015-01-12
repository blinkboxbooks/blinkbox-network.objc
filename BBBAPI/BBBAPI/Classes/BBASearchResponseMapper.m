//
//  BBASearchResponseMapper.m
//  BBBAPI
//
//  Created by Owen Worley on 09/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBASearchResponseMapper.h"
#import "BBAAPIErrors.h"
#import "BBAConnection.h"
#import "BBASearchService.h"
#import "BBASearchServiceBook.h"
#import "BBASearchServiceResult.h"
#import "BBASearchSuggestionsResult.h"
#import <FastEasyMapping/FastEasyMapping.h>
#import "BBAMacros.h"

@interface BBASearchResponseMapper()

@property (nonatomic, copy) NSDictionary *statusCodeErrors;

@end

@implementation BBASearchResponseMapper

#pragma mark - Public methods
- (id) responseFromData:(NSData *)data
               response:(NSURLResponse *)response
                  error:(NSError **)error{
    NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;

    if (statusCode == BBAHTTPSuccess) {
        NSDictionary *responseData = [super responseFromData:data
                                                    response:response
                                                       error:nil];
        if (!responseData){
            if (error){
                *error = [NSError errorWithDomain:BBASearchServiceErrorDomain
                                               code:BBAAPIUnreadableData
                                           userInfo:nil];
            }
            return nil;
        }

        NSString *type = responseData[@"type"];

        if ([type isEqualToString:@"urn:blinkboxbooks:schema:list"]) {
            FEMObjectMapping *mapping = [BBASearchSuggestionsResult searchSuggestionsResultMapping];
            BBASearchSuggestionsResult *result;
            result = [FEMObjectDeserializer deserializeObjectExternalRepresentation:responseData
                                                                       usingMapping:mapping];
            //Currently we are only interested in books, not authors.
            NSPredicate *suggestedBookPredicate;
            suggestedBookPredicate = [NSPredicate predicateWithFormat:@"%K LIKE %@",
                                      BBAKEY(type), @"urn:blinkboxbooks:schema:suggestion:book"];
            NSArray *suggestedBooks = [result.items filteredArrayUsingPredicate:suggestedBookPredicate];
            result.items = suggestedBooks;
            return result;

        }
        else if([type isEqualToString:@"urn:blinkboxbooks:schema:search"]){
            FEMObjectMapping *mapping = [BBASearchServiceResult searchServiceResultMapping];
            BBASearchServiceResult *result;
            result = [FEMObjectDeserializer deserializeObjectExternalRepresentation:responseData
                                                                       usingMapping:mapping];

            return result;
        }

        return nil;
    }

    if (error) {
        *error = self.statusCodeErrors[@(statusCode)];
    }

    return nil;
}

#pragma mark - Private Methods

#pragma mark Getters

- (NSDictionary *) statusCodeErrors{

    if(!_statusCodeErrors){

        NSError *badRequestError;
        badRequestError = [NSError errorWithDomain:BBASearchServiceErrorDomain
                                              code:BBAAPIErrorBadRequest
                                          userInfo:nil];

        NSError *notFoundError;
        notFoundError = [NSError errorWithDomain:BBASearchServiceErrorDomain
                                              code:BBAAPIErrorNotFound
                                          userInfo:nil];

        NSError *serverError;
        serverError = [NSError errorWithDomain:BBASearchServiceErrorDomain
                                              code:BBAAPIServerError
                                          userInfo:nil];

        _statusCodeErrors = @{@(BBAHTTPBadRequest) : badRequestError,
                              @(BBAHTTPNotFound) : notFoundError,
                              @(BBAHTTPServerError) : serverError};
    }
    return _statusCodeErrors;
}

@end
