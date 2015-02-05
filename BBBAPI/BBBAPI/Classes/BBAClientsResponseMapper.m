//
//  BBAClientsResponseMapper.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 14/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAClientsResponseMapper.h"
#import "BBAAuthenticationServiceConstants.h"
#import "BBAJSONResponseMapper.h"
#import "BBAAuthServiceErrorParser.h"
#import "BBAClientDetails.h"
#import "BBAAPIErrors.h"
#import "BBAConnection.h"

@interface BBAClientsResponseMapper ()
@property (nonatomic, strong) BBAJSONResponseMapper *jsonMapper;
@property (nonatomic, strong) BBAAuthServiceErrorParser *errorParser;
@end

@implementation BBAClientsResponseMapper

- (BBAJSONResponseMapper *) jsonMapper{
    if (_jsonMapper == nil) {
        _jsonMapper = [BBAJSONResponseMapper new];
    }
    return _jsonMapper;
}

- (BBAAuthServiceErrorParser *) errorParser{
    if (_errorParser == nil) {
        _errorParser = [BBAAuthServiceErrorParser new];
    }
    return _errorParser;
}


- (id) responseFromData:(NSData *)data
               response:(NSURLResponse *)response
                  error:(NSError *__autoreleasing *)error{

    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];

    id JSON = [self.jsonMapper responseFromData:data response:response error:nil];

    if (statusCode == BBAHTTPUnauthorized) {
        if (error) {
            *error =  [NSError errorWithDomain:kBBAAuthServiceName
                                          code:BBAAPIErrorUnauthorised
                                      userInfo:nil];
        }
        return nil;
    }

    if (statusCode == BBAHTTPNotFound) {
        if (error) {
            *error =  [NSError errorWithDomain:kBBAAuthServiceName
                                          code:BBAAPIErrorNotFound
                                      userInfo:nil];
        }
        return nil;
    }

    if (statusCode == BBAHTTPSuccess) {
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
                    BBAClientDetails *client = [self clientDetailsWithJSON:clientDict];
                    if (client) {
                        [clients addObject:client];
                    }
                }
                return clients;
            }

            //Client info response
            BBAClientDetails *clientDetails = [self clientDetailsWithJSON:JSON];
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
        *error = [NSError errorWithDomain:kBBAAuthServiceName
                                     code:BBAAuthServiceErrorCodeInvalidResponse
                                 userInfo:nil];
    }
    return nil;
}

- (BBAClientDetails *)clientDetailsWithJSON:(NSDictionary *)JSON{
    if (!JSON) {
        return nil;
    }

    BBAClientDetails *details = [BBAClientDetails new];
    NSString *clientId = JSON[kBBAAuthKeyClientId];
    NSString *clientURI = JSON[kBBAAuthKeyClientURI];
    NSString *clientName = JSON[kBBAAuthKeyClientName];
    NSString *clientBrand = JSON[kBBAAuthKeyClientBrand];
    NSString *clientModel = JSON[kBBAAuthKeyClientModel];
    NSString *clientOS = JSON[kBBAAuthKeyClientOS];
    NSString *clientLastUsed = JSON[kBBAAuthKeyLastUsedDate];
    NSString *clientSecret = JSON[kBBAAuthKeyClientSecret];

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
