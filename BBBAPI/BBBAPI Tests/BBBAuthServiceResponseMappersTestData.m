//
//  BBBAuthServiceResponseMappersTestData.m
//  BBBAPI
//
//  Created by Owen Worley on 20/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBAuthServiceResponseMappersTestData.h"

@implementation BBBAuthServiceResponseMappersTestData
#pragma mark - Test helper methods
+ (NSDictionary *) validClientListResponseData:(NSData **)data
                                      response:(NSURLResponse **)response{

    NSDictionary *dict = @{
                           @"clients": @[
                                   @{
                                       @"client_id": @"urn:blinkbox:zuul:client:2697",
                                       @"client_uri": @"/clients/2697",
                                       @"client_name": @"GT-I9300",
                                       @"client_brand": @"samsung",
                                       @"client_model": @"GT-I9300",
                                       @"client_os": @"Android 18",
                                       @"last_used_date": @"2014-05-23"
                                       },
                                   @{
                                       @"client_id": @"urn:blinkbox:zuul:client:14140",
                                       @"client_uri": @"/clients/14140",
                                       @"client_name": @"Some random device",
                                       @"client_brand": @"Apple",
                                       @"client_model": @"iPad",
                                       @"client_os": @"iPhone OS 7.0.4",
                                       @"last_used_date": @"2014-05-30"
                                       }
                                   ]
                           };
    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/clients"];

    [self authResponseData:data
                  response:response
            withStatusCode:200
                   withURL:URL
            withDictionary:dict];


    return dict;

}

+ (NSDictionary *) validAddClientInfoResponseData:(NSData **)data
                                         response:(NSURLResponse **)response{

    NSDictionary *dict = @{
                           @"client_id": @"urn:blinkbox:zuul:client:33100",
                           @"client_uri": @"/clients/33100",
                           @"client_name": @"Joe's iPhone",
                           @"client_brand": @"Apple",
                           @"client_model": @"iPhone 4",
                           @"client_os": @"iOS8",
                           @"last_used_date": @"2014-08-14",
                           @"client_secret": @"zz3XSEuZtpukH6Ie0rfRzycnbzXaO81g6qE1zKKDq0s"
                           };

    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/clients"];

    [self authResponseData:data
                  response:response
            withStatusCode:200
                   withURL:URL
            withDictionary:dict];


    return dict;

}

+ (NSDictionary *)invalidRequestResponseData:(NSData **)data
                                    response:(NSURLResponse **)response
                                      reason:(NSString*)reason{

    NSDictionary *responseDict = @{@"error" : @"invalid_request",
                                   @"error_reason" : reason};

    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/oauth2/token"];

    [self authResponseData:data
                  response:response
            withStatusCode:400
                   withURL:URL
            withDictionary:responseDict];

    return responseDict;
}

+ (NSDictionary *)invalidClientResponseData:(NSData **)data
                                   response:(NSURLResponse **)response{

    NSDictionary *responseDict = @{@"error" : @"invalid_client",
                                   @"error_description" : @"The client id and/or client secret is incorrect."};

    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/oauth2/token"];

    [self authResponseData:data
                  response:response
            withStatusCode:400
                   withURL:URL
            withDictionary:responseDict];

    return responseDict;
}

+ (NSDictionary *)invalidGrantResponseData:(NSData **)data
                                  response:(NSURLResponse **)response{

    NSDictionary *responseDict = @{@"error" : @"invalid_grant",
                                   @"error_description" : @"The username and/or password is incorrect."};

    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/oauth2/token"];

    [self authResponseData:data
                  response:response
            withStatusCode:400
                   withURL:URL
            withDictionary:responseDict];

    return responseDict;
}

+ (NSDictionary *)registrationUserAndClientAuthResponseData:(NSData **)data
                                                   response:(NSURLResponse**)response
                                                 statusCode:(NSInteger)statusCode{

    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/oauth2/token"];

    NSDictionary *authData = @{@"access_token": @"eyJraWQiOiJibGlua2JveC9wbGF0L2VuYy9yc2EvMSIsImN0eSI6IkpXVCIsImVuYyI6IkExMjhHQ00iLCJhbGciOiJSU0EtT0FFUCJ9.ii33jw7lQZGZR1mS41KYPmvmjgKF8euUpSswV0zWBMkb8D5kZnpLEY_HM7oMpFmNr5ONicptW19lMz76P3xfPOPoD-FqDsywn8rTpnkOplJJDsZgSXPDUKubdzCA7JYj_zvnr-nBF5mcYKjErkKeH2hJm7_kRorddF3GSCKQH5dR4G9_qFyi2giCy5pFRn_-2p8l7JIpSuQvgL89mAE60JlJJQcqSFKZ7tosQBlbKe7MqxyyBYF-mQg-XEtsLBmVz_77TSqd4lusIlwZd-Ke110JbKJFPJGtPTMNRmhzEO4uAAVGmYgk1KCL8A4nrLEiORK7crceTIuWZ6wMFiSdvA.MWvgH37fQLhCoFs5.s7_POav6D7YAVCecnVcAdo6Pppmcw_dRzJJ_qvIkEWF3Qle0ksgwFB0I-rc4M-R1EKdmpkT5hnkexKNKmTdY203Fa9yzhkZzQSVRMytUe-P5ycjl0sxRA4RxCX_8aazrK8KFWLF9LJ39mbQjjbtrUdLWxzF4lL0YexzNGGQMC_B0qIP2Fwb0LaBRibOVqnRBiNIioM5bwFisyfY9Vvx2uLgU2wJfz1qnLwikF2xejLD3wVvenleWvJa2Pz19w3mCRzAHVhmBtL_t1vUy4qopbKv3l-lcUQczvHEnTRTAS9KWlpy0KSzQIpZTfmcz8F1SmYYZznRMnKtZST8lBi9gYSKeKqknC66TCuqz4CglLAD-sdIfsn346nArtbF0TgGe-Hv0yeYDvhCyltVz2Q.cAI9GR2KjoDcNelfThZQ1Q",
                               @"token_type":@"bearer",
                               @"expires_in":         @(1800),
                               @"refresh_token":@"pMg2C7XePHo9PcTxdQUlC5_XO5nRAb3vb4NwPU6Op84",
                               @"user_id":@"urn:blinkbox:zuul:user:30901",
                               @"user_uri":@"/users/30901",
                               @"user_username":@"joe@aaabloggs.com",
                               @"user_first_name":@"Joe",
                               @"user_last_name":@"Bloggs",
                               @"client_id":@"urn:blinkbox:zuul:client:32563",
                               @"client_uri":@"/clients/32563",
                               @"client_name":@"Bobs iPhone",
                               @"client_brand":@"Apple",
                               @"client_model":@"iPhone 5s",
                               @"client_os":@"iOS8",
                               @"last_used_date":@"2014-08-12",
                               @"client_secret":@"eXPrpPPuLQxxuxOZRMWmR3z1PnlQVFTnFPkVjzuHh5E"};

    [self authResponseData:data
                  response:response
            withStatusCode:statusCode
                   withURL:URL
            withDictionary:authData];

    return authData;
}
//Data for user login (no client)
+ (NSDictionary *)validLoginUserAuthResponseData:(NSData **)data
                                        response:(NSURLResponse**)response
                                      statusCode:(NSInteger)statusCode{

    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/oauth2/token"];

    NSDictionary *authData = @{@"access_token" : @"a_valid_access_token",
                               @"token_type" : @"bearer",
                               @"expires_in" : @(1800),
                               @"refresh_token" : @"a_valid_refresh_token",
                               @"user_id" : @"urn:blinkbox:zuul:user:3931",
                               @"user_uri" : @"/users/3931",
                               @"user_username" : @"xctest_books@blinkbox.com",
                               @"user_first_name" : @"XCTest",
                               @"user_last_name" : @"Books"};

    [self authResponseData:data
                  response:response
            withStatusCode:statusCode
                   withURL:URL
            withDictionary:authData];

    return authData;
}

//Data for refresh request WITH client
+ (NSDictionary *) validRefreshUserAndClientTokenData:(NSData **)data
                                             response:(NSURLResponse **)response
                                           statusCode:(NSInteger)statusCode{
    //This is the same response as login WITH client, pass through
    return [self validLoginUserAndClientAuthResponseData:data
                                                response:response
                                              statusCode:statusCode];
}

//Data for refresh request WITHOUT client
+ (NSDictionary *) validRefreshUserWithoutClientTokenData:(NSData **)data
                                                 response:(NSURLResponse **)response
                                               statusCode:(NSInteger)statusCode{
    //This is the same response as login WITHOUT client, pass through
    return [self validLoginUserAuthResponseData:data
                                       response:response
                                     statusCode:statusCode];
}

//Data for user login WITH client
+ (NSDictionary *)validLoginUserAndClientAuthResponseData:(NSData **)data
                                                 response:(NSURLResponse**)response
                                               statusCode:(NSInteger)statusCode{

    NSURL *URL = [NSURL URLWithString:@"https://auth.blinkboxbooks.com/oauth2/token"];

    NSDictionary *authData = @{@"access_token" : @"a_valid_access_token",
                               @"token_type" : @"bearer",
                               @"expires_in" : @(1800),
                               @"refresh_token" : @"a_valid_refresh_token",
                               @"user_id" : @"urn:blinkbox:zuul:user:3931",
                               @"user_uri" : @"/users/3931",
                               @"user_username" : @"xctest_books@blinkbox.com",
                               @"user_first_name" : @"XCTest",
                               @"user_last_name" : @"Books",
                               @"client_id": @"urn:blinkbox:zuul:client:32563",
                               @"client_uri": @"/clients/32563",
                               @"client_name": @"Bobs iPhone",
                               @"client_brand": @"Apple",
                               @"client_model": @"iPhone 5s",
                               @"client_os": @"iOS8",
                               @"last_used_date": @"2014-08-12"};

    [self authResponseData:data
                  response:response
            withStatusCode:statusCode
                   withURL:URL
            withDictionary:authData];

    return authData;
}

+ (void) authResponseData:(NSData **)data
                 response:(NSURLResponse**)response
           withStatusCode:(NSInteger)statusCode
                  withURL:(NSURL*)URL
           withDictionary:(NSDictionary*)dict{

    *data = [NSJSONSerialization dataWithJSONObject:dict
                                            options:0
                                              error:nil];

    *response = [[NSHTTPURLResponse alloc] initWithURL:URL
                                            statusCode:statusCode
                                           HTTPVersion:@"HTTP/1.1"
                                          headerFields:[NSDictionary dictionary]];
    
    
}

@end
