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

#pragma mark - Public Methods

- (BBARequest *) requestWith:(NSURL *)url
                  parameters:(NSDictionary *)parameters
                     headers:(NSDictionary *)headers
                      method:(BBAHTTPMethod)method
                 contentType:(BBAContentType)contentType
                       error:(NSError **)error{
    
    NSParameterAssert(url);
    
    BOOL headersValid = [self headersValid:headers];
    NSAssert(headersValid, @"Headers not valid");
    BOOL parametersValid = [self parametersValid:parameters];
    NSAssert(parametersValid, @"Parameters not valid");
    
    if (!headersValid) {
        [self handleError:error
                 withCode:BBARequestFactoryErrorHeadersInvalid
          underlyingError:nil];
        return nil;
    }
    
    if (!parametersValid) {
        [self handleError:error
                 withCode:BBARequestFactoryErrorParametersInvalid
          underlyingError:nil];
        return nil;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Construct body or url params
    if(method == BBAHTTPMethodGET) {
        
        if([parameters count] >0) {
            NSString *queryString = [NSString stringWithFormat:@"?%@",
                                     [self constructURLEncodedBodyString:parameters]];
            NSURL *paramaterURL = [NSURL URLWithString:queryString relativeToURL:url];
            [request setURL:paramaterURL];
            
        }
        else {
            [request setURL:url];
        }
    }
    else {
        NSError *bodyError;
        NSData *body = [self bodyFromParameters:parameters
                                    contentType:contentType
                                          error:&bodyError];
        
        if (!body) {
            [self handleError:error
                     withCode:BBARequestFactoryErrorCouldNotCreateRequest
              underlyingError:bodyError];
            
            return nil;
            
        }
        
        [request setHTTPBody:body];
        [request setURL:url];
        
    }
    NSString *HTTPMethod = [self httpMethodStringForHTTPMethod:method];
    NSAssert(HTTPMethod, @"Bad HTTPMethod");
    [request setHTTPMethod:HTTPMethod];
    [request setAllHTTPHeaderFields:headers];
    
    return [BBARequest requestWithURLRequest:request];
}

- (BOOL) headersValid:(NSDictionary *)headers{
    return [self dictionary:headers containsOnlyInstancesOfClass:[NSString class]];
}

- (BOOL) parametersValid:(NSDictionary *)headers{

    BOOL valid = [self dictionary:headers containsOnlyInstancesOfClasses:@[ [NSString class],
                                                                             [NSArray class] ]];
    return valid;
}
- (BOOL) dictionary:(NSDictionary *)dictionary containsOnlyInstancesOfClasses:(NSArray *)classes{
    __block BOOL valid = YES;

    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        for (Class validClass in classes) {
            NSInteger invalidCount = 0;
            if (![obj isKindOfClass:validClass]) {
                invalidCount++;
            }
            if (invalidCount == classes.count) {
                valid = NO;
                *stop = YES;
            }
        }

    }];

    return valid;
}
- (BOOL) dictionary:(NSDictionary *)dictionary containsOnlyInstancesOfClass:(Class)class{
    __block BOOL valid = YES;
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if (![obj isKindOfClass:class]) {
            valid = NO;
            *stop = YES;
        }
    }];
    
    return valid;
}

- (void) handleError:(NSError **)error
            withCode:(BBARequestFactoryError)code
     underlyingError:(NSError *)underlyingError{
    
    if (error) {
        NSDictionary *userInfo;
        if (underlyingError) {
            userInfo = @{NSUnderlyingErrorKey : underlyingError};
        }
        
        *error =  [NSError errorWithDomain:BBARequestFactoryDomain
                                      code:code
                                  userInfo:userInfo];
    }
}

#pragma mark - Private Methods

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


- (NSString*) URLEncodedString:(NSString *)string{
    
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


- (NSString *) httpMethodStringForHTTPMethod:(BBAHTTPMethod)method{
    switch (method) {
        case BBAHTTPMethodGET:
            return @"GET";
        case BBAHTTPMethodPOST:
            return @"POST";
        case BBAHTTPMethodPUT:
            return @"PUT";
        case BBAHTTPMethodDELETE:
            return @"DELETE";
        default:
            NSAssert(false, @"Unrecognised http method");
            return nil;
    }
}
@end
