//
//  BBARequestFactory.m
//  BBAAPI
//
//  Created by Tomek Kuźma on 31/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBARequestFactory.h"
#import "BBARequest.h"

NSString *const BBARequestFactoryDomain = @"com.BBA.requestFactoryErrorDomain";

@implementation BBARequestFactory

- (BBARequest *) requestWith:(NSURL *)url
                  parameters:(NSDictionary *)parameters
                     headers:(NSDictionary *)headers
                      method:(BBAHTTPMethod)method
                 contentType:(BBAContentType)contentType
                       error:(NSError **)error{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Construct body or url params
    if(method == BBAHTTPMethodGET) {

        if([parameters count] >0) {
            NSString *queryString = [NSString stringWithFormat:@"?%@",[self constructURLEncodedBodyString:parameters]];
            NSURL *paramaterURL = [url URLByAppendingPathComponent:queryString];
            [request setURL:paramaterURL];

        }
        else{
            [request setURL:url];
        }
        
        [request setHTTPMethod:@"GET"];
    }
    else if(method == BBAHTTPMethodDELETE) {
        if([parameters count] >0) {
            NSString *queryString = [NSString stringWithFormat:@"?%@",[self constructURLEncodedBodyString:parameters]];
            NSURL *paramaterURL = [url URLByAppendingPathComponent:queryString];
            [request setURL:paramaterURL];

        }
        else{
            [request setURL:url];
        }

        [request setHTTPMethod:@"DELETE"];
    }
    else {
        NSError *bodyError;
        NSData *body = [self bodyFromParameters:parameters
                                    contentType:contentType
                                          error:&bodyError];
        [request setHTTPBody:body];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];

    }

    [request setAllHTTPHeaderFields:headers];
    
    return [BBARequest requestWithURLRequest:request];
}

- (NSData *) bodyFromParameters:(NSDictionary *)parameters
                    contentType:(BBAContentType)contentType
                          error:(NSError * __autoreleasing *)error {
    
    if(contentType == BBAContentTypeURLEncodedForm) {
        return [[self constructURLEncodedBodyString:parameters] dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    
    if (contentType == BBAContentTypeJSON) {
        
        if([NSJSONSerialization isValidJSONObject:parameters] == NO) {
            *error = [NSError errorWithDomain:BBARequestFactoryDomain
                                         code:BBAURLConnectionErrorCodeCouldSerialiseDataToJSON
                                     userInfo:nil];
            return nil;
        }
        
        NSError *jsonError = nil;
        NSData *data =[NSJSONSerialization dataWithJSONObject:parameters options:0 error:&jsonError];
        if(jsonError != nil) {
        description: domain:
            *error = [NSError errorWithDomain:BBARequestFactoryDomain
                                         code:BBAURLConnectionErrorCodeCouldSerialiseDataToJSON
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
