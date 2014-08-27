//
//  BBAConnection.m
//  BBANetworking
//
//  Created by Tomek Kuźma on 24/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAConnection.h"
#import "BBARequestFactory.h"
#import "BBARequest.h"
#import "BBAAPIErrors.h"
#import "BBANetworkConfiguration.h"

NSString * BBANSStringFromBBAContentType(BBAContentType type){
    switch (type) {
        case BBAContentTypeURLEncodedForm:
        {
            return @"application/x-www-form-urlencoded";
            break;
        }
        case BBAContentTypeJSON:
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

NSString *const BBAConnectionErrorDomain = @"BBAURLConnectionErrorDomain";
NSString *const BBAHTTPVersion11 = @"HTTP/1.1";

typedef void(^BBAURLConnectionCompletionCallback)(NSURLResponse *response, NSData *data, NSError *connectionError);

@interface BBAConnection ()

@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, strong) NSMutableDictionary *headers;
@property (nonatomic, strong) NSURL *baseURL;
@end

@implementation BBAConnection

- (id) initWithBaseURL:(NSURL *)URL{
    self = [super init];
    if (self) {
        _contentType = BBAContentTypeUnknown;
        _baseURL = URL;
        _parameters = [NSMutableDictionary new];
        _headers = [NSMutableDictionary new];
        _requiresAuthentication = YES;
        _authenticator = [BBANetworkConfiguration sharedAuthenticator];
    }
    return self;
}

- (id) initWithDomain:(BBAAPIDomain)domain relativeURL:(NSString *)relativeURLString{
    
    NSURL *baseURL = [BBANetworkConfiguration baseURLForDomain:domain];
    
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

- (void) setContentType:(BBAContentType)contentType{
    if (_contentType != contentType) {
        _contentType = contentType;
        [self addHeaderFieldWithKey:@"Content-Type"
                              value:BBANSStringFromBBAContentType(contentType)];
    }
    
}

- (void)perform:(BBAHTTPMethod)method completion:(void (^)(id, NSError *))completion{
    [self perform:method forUser:nil completion:completion];
}

- (void) perform:(BBAHTTPMethod)method
         forUser:(BBAUserDetails *)user
      completion:(void (^)(id response, NSError *error))completion{
    
    NSURLSession *s = [NSURLSession sharedSession];
    NSError *error;
    BBARequest *request = [self.requestFactory requestWith:self.baseURL
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
                                
                                connectionError = [NSError errorWithDomain:BBAConnectionErrorDomain
                                                                      code:BBAAPIErrorCouldNotConnect
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
