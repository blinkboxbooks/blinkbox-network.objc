//
//  BBAConnection.m
//  BBANetworking
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 24/07/2014.
 

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
        case BBAContentTypeURLUnencodedForm:
        {
            /*
             This options is used with the key service, where content type header myst be `urlencoded`
             but the body must not be
             */
            return @"application/x-www-form-urlencoded";
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


@interface BBAConnection ()

@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, strong) NSMutableDictionary *headers;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation BBAConnection

#pragma mark - NSObject

- (id) init{
    self = [super init];
    if (self) {
        _requiresAuthentication = NO;
        _contentType = BBAContentTypeUnknown;
        _parameters = [NSMutableDictionary new];
        _headers = [NSMutableDictionary new];
        _requiresAuthentication = YES;
    }
    return self;
}

- (id) initWithBaseURL:(NSURL *)URL{
    NSParameterAssert(URL);
    
    if (!URL) {
        return nil;
    }
    
    self = [self init];
    if (self) {
        _baseURL = URL;
    }
    return self;
}

- (id) initWithDomain:(BBAAPIDomain)domain relativeURL:(NSString *)relativeURLString{
    
    NSURL *baseURL = [[BBANetworkConfiguration defaultConfiguration] baseURLForDomain:domain];
    
    NSURL *url = [NSURL URLWithString:relativeURLString relativeToURL:baseURL];
    
    self = [self initWithBaseURL:url];
    
    return self;
}

#pragma mark - Getter

- (NSURLSession *) session{
    if (!_session) {
        _session = [NSURLSession sharedSession];
    }
    return _session;
}

- (id<BBAAuthenticator>) authenticator{
    if (!_authenticator) {
        _authenticator = [[BBANetworkConfiguration defaultConfiguration] sharedAuthenticator];
    }
    return _authenticator;
}

- (BBARequestFactory *) requestFactory{
    if (!_requestFactory) {
        _requestFactory = [BBARequestFactory new];
    }
    return _requestFactory;
}

#pragma mark - Public

- (void) addParameterWithKey:(NSString*)key value:(NSString*)value{
    NSAssert([self.parameters objectForKey:key] == nil, @"Overwriting parameter %@. Is that intended?", key);
    NSAssert([key isKindOfClass:[NSString class]], @"key must by a NSString");
    NSAssert([value isKindOfClass:[NSString class]], @"value must by a NSString");
    [self.parameters setObject:value forKey:key];
}

- (void) addParameterWithKey:(NSString *)key arrayValue:(NSArray *)value{
    NSAssert([self.parameters objectForKey:key] == nil, @"Overwriting parameter %@. Is that intended?", key);
    NSAssert([key isKindOfClass:[NSString class]], @"key must by a NSArray");
    NSAssert([value isKindOfClass:[NSArray class]], @"value must by a NSArray");
    [self.parameters setObject:value forKey:key];
}

- (void) setParameterValue:(NSString *)value withKey:(NSString *)key{
    BOOL keyHasCorrectClass = [key isKindOfClass:[NSString class]];
    NSParameterAssert(key);
    NSParameterAssert(keyHasCorrectClass);
    if (!key || !keyHasCorrectClass) {
        return;
    }
    
    if (value) {
        self.parameters[key] = value;
    }
    else{
        [self.parameters removeObjectForKey:key];
    }
}

- (void) addHeaderFieldWithKey:(NSString*)key value:(NSString*)value{
    NSAssert([self.headers objectForKey:key] == nil, @"Overwriting header %@. Is that intended?", key);
    [self.headers setObject:value forKey:key];
}

- (void) setContentType:(BBAContentType)contentType{
    if (_contentType != contentType) {
        _contentType = contentType;
        [self addHeaderFieldWithKey:@"Content-Type"
                              value:BBANSStringFromBBAContentType(contentType)];
    }
    
}

- (void) perform:(BBAHTTPMethod)method
         forUser:(BBAUserDetails *)user
      completion:(void (^)(id response, NSError *error))completion{
    
    NSParameterAssert(completion);
    if (!completion) {
        return;
    }
    
    NSAssert(self.responseMapper, @"we need response mapper");
    if (!self.responseMapper) {
        NSError *error = [NSError errorWithDomain:BBAConnectionErrorDomain
                                             code:BBAAPIWrongUsage
                                         userInfo:nil];
        completion(nil, error);
        return;
    }
    
    NSError *error;
    BBARequest *request = [self.requestFactory requestWith:self.baseURL
                                                parameters:self.parameters
                                                   headers:self.headers
                                                    method:method
                                               contentType:self.contentType
                                                     error:&error];
    
    NSAssert(request, @"request factory must return a request");
    if (!request) {
        completion(nil, error);
        return;
    }
    
    if (!self.requiresAuthentication) {
        [self performRequest:request
                  completion:completion];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.authenticator authenticateRequest:request
                                        forUser:user
                                     completion:^(BBARequest *request, NSError *error) {
                                         
                                         if (!request) {
                                             completion(nil, error);
                                             return ;
                                         }
                                         
                                         
                                         [self performRequest:request
                                                   completion:completion];
                                         
                                     }];
    });
    
}

- (void) performRequest:(BBARequest *)request
             completion:(void (^)(id response, NSError *error))completion{
    
    NSURLSession *s = self.session;
    
    NSURLSessionDataTask *dataTask;
    dataTask = [s dataTaskWithRequest:request.URLRequest
                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        
                        if (response) {
                            NSError *mapperError;
                            id returnData = [self.responseMapper responseFromData:data
                                                                         response:response
                                                                            error:&mapperError];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion(returnData, mapperError);
                            });
                            return ;
                        }
                        
                        NSError *connectionError;
                        NSDictionary *userInfo;
                        
                        if (error != nil) {
                            userInfo = @{NSUnderlyingErrorKey : error};
                        }
                        
                        connectionError = [NSError errorWithDomain:BBAConnectionErrorDomain
                                                              code:BBAAPIErrorCouldNotConnect
                                                          userInfo:userInfo];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(nil, connectionError);
                        });
                        
                    }];
    
    [dataTask resume];
}

#pragma mark - Private

- (void) perform:(BBAHTTPMethod)method completion:(void (^)(id, NSError *))completion{
    [self perform:method forUser:nil completion:completion];
}

@end
