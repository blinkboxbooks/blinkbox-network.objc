//
//  BBBRequestFactory.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 31/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBRequestFactory.h"
#import "BBBRequest.h"

NSString *const BBBRequestFactoryDomain = @"com.bbb.requestFactoryErrorDomain";

@implementation BBBRequestFactory

- (BBBRequest *) requestWith:(NSURL *)url
                  parameters:(NSDictionary *)parameters
                     headers:(NSDictionary *)headers
                      method:(BBBHTTPMethod)method
                 contentType:(BBBContentType)contentType
                       error:(NSError **)error{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Construct body or url params
    if(method == BBBHTTPMethodGET) {
        NSString *queryString = @"";
        
        if([parameters count] >0) {
            queryString = [NSString stringWithFormat:@"?%@",[self constructURLEncodedBodyString:parameters]];
        }
        
        NSURL *paramaterURL = [url URLByAppendingPathComponent:[NSURL URLWithString:queryString]];
        
        [request setURL:paramaterURL];
    }
    else {
        NSError *bodyError;
        NSData *body = [self bodyFromParameters:parameters
                                    contentType:contentType
                                          error:&bodyError];
        [request setHTTPBody:body];
    }
    
    [request setAllHTTPHeaderFields:headers];
    
    return [BBBRequest requestWithURLRequest:request];
}

- (NSData *) bodyFromParameters:(NSDictionary *)parameters
                    contentType:(BBBContentType)contentType
                          error:(NSError * __autoreleasing *)error {
    
    if(contentType == BBBContentTypeURLEncodedForm) {
        return [[self constructURLEncodedBodyString:parameters] dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    
    if (contentType == BBBContentTypeJSON) {
        
        if([NSJSONSerialization isValidJSONObject:parameters] == NO) {
            *error = [NSError errorWithDomain:BBBRequestFactoryDomain
                                         code:BBBURLConnectionErrorCodeCouldSerialiseDataToJSON
                                     userInfo:nil];
            return nil;
        }
        
        NSError *jsonError = nil;
        NSData *data =[NSJSONSerialization dataWithJSONObject:parameters options:0 error:&jsonError];
        if(jsonError != nil) {
        description: domain:
            *error = [NSError errorWithDomain:BBBRequestFactoryDomain
                                         code:BBBURLConnectionErrorCodeCouldSerialiseDataToJSON
                                     userInfo:nil];
            return nil;
        }
        return data;
    }
    
    
    return nil;
}

- (NSString*) constructURLEncodedBodyString:(NSDictionary*)parameters{
    if([parameters count]==0) {
        return @"";
    }
    
    NSMutableArray *bodyStringsArray = [NSMutableArray new];
    NSString *format = @"%@=%@";
    
    void (^constructBlock)(NSString *, NSString *) = ^void(NSString *key, NSString *value) {
        NSString *bodyArgument = [NSString stringWithFormat:format, key, [self URLEncodedString:value]];
        [bodyStringsArray addObject:bodyArgument];
    };
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        
        if([value isKindOfClass:[NSString class]]) {
            constructBlock(key, value);
        }
        else if([value isKindOfClass:[NSArray class]]) {
            
            for (NSString *arrayValueItem in value) {
                constructBlock(key, arrayValueItem);
            }
        }
        else{
            NSAssert(NO, @"unsupported parameter type");
        }
    }];
    
    
    return [bodyStringsArray componentsJoinedByString:@"&"];
    
}


static NSString * const kCharactersToBeEscaped = @":/?&=;+!@#$()',*";
static NSString * const kCharactersToLeaveUnescaped = @"[].";

#ifndef BBRIDGE
#define BBRIDGE __bridge CFStringRef


- (NSString*)URLEncodedString:(NSString *)string{
    
    CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
    
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                  (BBRIDGE)string,
                                                                  (BBRIDGE)kCharactersToLeaveUnescaped,
                                                                  (BBRIDGE)kCharactersToBeEscaped,
                                                                  encoding);
    return (__bridge_transfer  NSString *)escaped;
    
}
#undef BBRIDGE
#endif

@end
