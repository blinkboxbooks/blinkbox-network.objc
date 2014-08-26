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
#import "BBBAPIErrors.h"
#import "BBBNetworkConfiguration.h"

NSString * BBBNSStringFromBBBContentType(BBBContentType type){
    switch (type) {
        case BBBContentTypeURLEncodedForm:
        {
            return @"application/x-www-form-urlencoded";
            break;
        }
        case BBBContentTypeJSON:
        {
            return @"application/vnd.blinkboxbooks.data.v1+json";
            break;
        }
            
        default:
            NSCAssert(NO, @"unexpected content type");
            break;
    }
    return nil;
}

NSString *const BBBConnectionErrorDomain = @"BBBURLConnectionErrorDomain";
NSString *const BBBHTTPVersion11 = @"HTTP/1.1";

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
        _contentType = BBBContentTypeUnknown;
        _baseURL = URL;
        _parameters = [NSMutableDictionary new];
        _headers = [NSMutableDictionary new];
        _requiresAuthentication = YES;
        _authenticator = [BBBNetworkConfiguration sharedAuthenticator];
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
    if (_contentType != contentType) {
        _contentType = contentType;
        [self addHeaderFieldWithKey:@"Content-Type"
                              value:BBBNSStringFromBBBContentType(contentType)];
    }
    
}

- (void)perform:(BBBHTTPMethod)method completion:(void (^)(id, NSError *))completion{
    [self perform:method forUser:nil completion:completion];
}

- (void) perform:(BBBHTTPMethod)method
         forUser:(BBBUserDetails *)user
      completion:(void (^)(id response, NSError *error))completion{
    
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
    
    NSError *authenticatorError = nil;
    
    
    void(^taskBlock)(void) = ^(void) {
        
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
                                NSDictionary *userInfo;
                                
                                if (error != nil) {
                                    userInfo = @{NSUnderlyingErrorKey : error};
                                }
                                
                                connectionError = [NSError errorWithDomain:BBBConnectionErrorDomain
                                                                      code:BBBAPIErrorCouldNotConnect
                                                                  userInfo:userInfo];
                                
                                completion(nil, connectionError);
                                
                            }
                            
                            
                        }];
        
        [dataTask resume];
    };
    
    if (self.requiresAuthentication) {
        if (user) {
            [self.authenticator authenticateRequest:request
                                            forUser:user
                                              error:&authenticatorError
                                         completion:taskBlock];
        }
        else {
            [self.authenticator authenticateRequest:request
                                              error:&authenticatorError
                                         completion:taskBlock];
        }
        
    }
    else{
        taskBlock();
    }
}
@end
