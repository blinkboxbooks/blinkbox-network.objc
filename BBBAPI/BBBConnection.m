//
//  BBBConnection.m
//  BBBNetworking
//
//  Created by Tomek Kuźma on 24/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBConnection.h"
#import "BBBRequestFactory.h"
#import "BBBRequest.h"
#import "BBBNetworkConfiguration.h"

NSString * BBBContentTypeString(BBBContentType type){
    NSString *contentType = @"";
    switch (type) {
        case BBBContentTypeJSON:
            contentType = @"application/vnd.blinkboxbooks.data.v1+json";
            break;
        case BBBContentTypeURLEncodedForm:
            contentType = @"application/x-www-form-urlencoded";
        default:
            break;
    }
    return contentType;
}
NSString *const kBBBURLConnectionErrorDomain = @"kBBBURLConnectionErrorDomain";
typedef void(^BBBURLConnectionCompletionCallback)(NSURLResponse *response, NSData *data, NSError *connectionError);

@interface BBBConnection ()

@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, strong) NSMutableDictionary *headers;
@property (nonatomic, strong) NSURL *baseURL;
@end

@implementation BBBConnection

- (id) initWithBaseURL:(NSURL *)URL{
    self = [super init];
    if (self) {
        self.baseURL = URL;
        self.parameters = [NSMutableDictionary new];
        self.headers = [NSMutableDictionary new];
    }
    return self;
}

- (id) initWithDomain:(BBBAPIDomain)domain relativeURL:(NSString *)relativeURLString{
    
    NSURL *baseURL = [BBBNetworkConfiguration baseURLForDomain:domain];
    
    NSURL *url = [NSURL URLWithString:relativeURLString relativeToURL:baseURL];
    
    self = [self initWithBaseURL:url];
    
    return self;
}

- (void) addParameterWithKey:(NSString*)key value:(NSString*)value{
    NSAssert([self.parameters objectForKey:key] == nil, @"Overwriting parameter %@. Is that intended?", key);
    [self.parameters setObject:value forKey:key];
}

- (void) addParameterWithKey:(NSString *)key arrayValue:(NSArray *)value{
    NSAssert([self.parameters objectForKey:key] == nil, @"Overwriting parameter %@. Is that intended?", key);
    [self.parameters setObject:value forKey:key];
}

- (void) removeParameterWithKey:(NSString *)key{
    [self.parameters removeObjectForKey:key];
}

- (void) addHeaderFieldWithKey:(NSString*)key value:(NSString*)value{
    NSAssert([self.headers objectForKey:key] == nil, @"Overwriting header %@. Is that intended?", key);
    [self.headers setObject:value forKey:key];
}

- (void) removeHeaderFieldWithKey:(NSString*)key{
    [self.headers removeObjectForKey:key];
}

- (void) setContentType:(BBBContentType)contentType{
    [self addHeaderFieldWithKey:@"Content-Type" value:BBBContentTypeString(contentType)];
}

- (void) setHTTPMethod:(BBBHTTPMethod)httpMethod{
    NSAssert(false, @"This is probably not needed");
}

- (void)perform:(BBBHTTPMethod)method completion:(void (^)(id, NSError *))completion{
    NSURLSession *s = [NSURLSession sharedSession];
    NSError *error;
    BBBRequest *request = [self.requestFactory requestWith:self.baseURL
                                                parameters:self.parameters
                                                   headers:self.headers
                                                    method:method
                                               contentType:self.contentType
                                                     error:&error];
    
    if (!request) {
        completion(nil, error);
        return;
    }
    
    NSURLSessionDataTask *dataTask;
    dataTask = [s dataTaskWithRequest:request.URLRequest
         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
             
             
             
             if (response) {
                 NSError *mapperError;
                 id returnData = [self.responseMapper responseFromData:data
                                                              response:response
                                                                 error:&mapperError];
                 
                 completion(returnData, mapperError);
             }
             else{

                 NSError *connectionError;
                 if (error != nil) {
                     
                     NSDictionary *userInfo = @{NSUnderlyingErrorKey : error};
                     
                     connectionError = [NSError errorWithDomain:kBBBURLConnectionErrorDomain
                                                 code:BBBURLConnectionErrorCodeCannotConnect
                                             userInfo:userInfo];
                 }
                 
                 completion(nil, connectionError);
                 
             }
            
             
         }];

    [dataTask resume];
}
@end
