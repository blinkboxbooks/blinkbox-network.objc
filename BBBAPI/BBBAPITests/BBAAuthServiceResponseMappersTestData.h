//
//  BBAAuthServiceResponseMappersTestData.h
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 20/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBAAuthServiceResponseMappersTestData : NSObject
+ (NSDictionary *) validClientListResponseData:(NSData **)data
                                      response:(NSURLResponse **)response;

+ (NSDictionary *) validAddClientInfoResponseData:(NSData **)data
                                         response:(NSURLResponse **)response;

+ (NSDictionary *)invalidRequestResponseData:(NSData **)data
                                    response:(NSURLResponse **)response
                                      reason:(NSString*)reason;

+ (NSDictionary *)invalidClientResponseData:(NSData **)data
                                   response:(NSURLResponse **)response;

+ (NSDictionary *)invalidGrantResponseData:(NSData **)data
                                  response:(NSURLResponse **)response;

+ (NSDictionary *)registrationUserAndClientAuthResponseData:(NSData **)data
                                                   response:(NSURLResponse**)response
                                                 statusCode:(NSInteger)statusCode;

+ (NSDictionary *)validLoginUserAuthResponseData:(NSData **)data
                                        response:(NSURLResponse**)response
                                      statusCode:(NSInteger)statusCode;

+ (NSDictionary *) validRefreshUserAndClientTokenData:(NSData **)data
                                             response:(NSURLResponse **)response
                                           statusCode:(NSInteger)statusCode;

+ (NSDictionary *) validRefreshUserWithoutClientTokenData:(NSData **)data
                                                 response:(NSURLResponse **)response
                                               statusCode:(NSInteger)statusCode;

+ (NSDictionary *)validLoginUserAndClientAuthResponseData:(NSData **)data
                                                 response:(NSURLResponse**)response
                                               statusCode:(NSInteger)statusCode;

+ (void) authResponseData:(NSData **)data
                 response:(NSURLResponse**)response
           withStatusCode:(NSInteger)statusCode
                  withURL:(NSURL*)URL
           withDictionary:(NSDictionary*)dict;

@end
