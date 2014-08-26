//
//  BBBClientsResponseMapper.m
//  BBBAPI
//
//  Created by Owen Worley on 14/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBClientsResponseMapper.h"
#import "BBBAuthenticationServiceConstants.h"
#import "BBBJSONResponseMapper.h"
#import "BBBAuthServiceErrorParser.h"
#import "BBBClientDetails.h"
#import "BBBAPIErrors.h"
#import "BBBConnection.h"

@interface BBBClientsResponseMapper ()
@property (nonatomic, strong) BBBJSONResponseMapper *jsonMapper;
@property (nonatomic, strong) BBBAuthServiceErrorParser *errorParser;
@end

@implementation BBBClientsResponseMapper

- (BBBJSONResponseMapper *) jsonMapper{
    if (_jsonMapper == nil) {
        _jsonMapper = [BBBJSONResponseMapper new];
    }
    return _jsonMapper;
}

- (BBBAuthServiceErrorParser *) errorParser{
    if (_errorParser == nil) {
        _errorParser = [BBBAuthServiceErrorParser new];
    }
    return _errorParser;
}


- (id) responseFromData:(NSData *)data
               response:(NSURLResponse *)response
                  error:(NSError *__autoreleasing *)error{

    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];

    id JSON = [self.jsonMapper responseFromData:data response:response error:nil];

    if (statusCode == BBBHTTPUnauthorized) {
        if (error) {
            *error =  [NSError errorWithDomain:kBBBAuthServiceName
                                          code:BBBAPIErrorUnauthorised
                                      userInfo:nil];
        }
        return nil;
    }

    if (statusCode == BBBHTTPNotFound) {
        if (error) {
            *error =  [NSError errorWithDomain:kBBBAuthServiceName
                                          code:BBBAPIErrorNotFound
                                      userInfo:nil];
        }
        return nil;
    }

    if (statusCode == BBBHTTPSuccess) {
        //200 code with empty data is a success
        if (JSON == nil) {
            return @(YES);
        }

        //200 response + json should be a valid response, parse it
        if (JSON != nil) {
            //Client list response
            NSArray *serverClients = JSON[@"clients"];
            if (serverClients) {
                NSMutableArray *clients = [NSMutableArray new];
                for (NSDictionary *clientDict in JSON[@"clients"]) {
                    BBBClientDetails *client = [self clientDetailsWithJSON:clientDict];
                    if (client) {
                        [clients addObject:client];
                    }
                }
                return clients;
            }

            //Client info response
            BBBClientDetails *clientDetails = [self clientDetailsWithJSON:JSON];
            if (clientDetails != nil) {
                return clientDetails;
            }
        }
    }

    //Parse response for JSON error
    if (JSON && [JSON isKindOfClass:[NSDictionary class]]) {
        NSError *serverError = [self.errorParser errorForResponseJSON:JSON
                                                           statusCode:statusCode];
        if (serverError) {
            if (error) {
                *error = serverError;
            }
            return nil;
        }
    }

    //No JSON errors, what is this response?
    if (error) {
        *error = [NSError errorWithDomain:kBBBAuthServiceName
                                     code:BBBAuthServiceErrorCodeInvalidResponse
                                 userInfo:nil];
    }
    return nil;
}

- (BBBClientDetails *)clientDetailsWithJSON:(NSDictionary *)JSON{
    if (!JSON) {
        return nil;
    }

    BBBClientDetails *details = [BBBClientDetails new];
    NSString *clientId = JSON[kBBBAuthKeyClientId];
    NSString *clientURI = JSON[kBBBAuthKeyClientURI];
    NSString *clientName = JSON[kBBBAuthKeyClientName];
    NSString *clientBrand = JSON[kBBBAuthKeyClientBrand];
    NSString *clientModel = JSON[kBBBAuthKeyClientModel];
    NSString *clientOS = JSON[kBBBAuthKeyClientOS];
    NSString *clientLastUsed = JSON[kBBBAuthKeyLastUsedDate];
    NSString *clientSecret = JSON[kBBBAuthKeyClientSecret];

    if (clientId && clientURI && clientName && clientBrand &&
        clientModel && clientOS && clientLastUsed) {
        details.identifier = clientId;
        details.uri = clientURI;
        details.name = clientName;
        details.brand = clientBrand;
        details.model = clientModel;
        details.operatingSystem = clientOS;
        details.lastUsedDate = clientLastUsed;
        details.secret = clientSecret;
        return  details;
    }

    return nil;


}
@end
