//
//  BBAConnectionTestsMocks.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 24/10/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import "BBAConnectionTestsMocks.h"

@implementation BBAMockNetworkConfiguration
- (id<BBAAuthenticator>) sharedAuthenticator{
    return self.authenticator;
}
- (NSURL *)baseURLForDomain:(BBAAPIDomain)domain{
    self.passedDomain = domain;
    return self.baseURL;
}
@end

@implementation BBAMockAuthenticator

- (void) authenticateRequest:(BBARequest *)request
                  completion:(void (^)(BBARequest *, NSError *))completion{
    
    [self authenticateRequest:request
                      forUser:nil
                   completion:completion];
}

- (void) authenticateRequest:(BBARequest *)request
                     forUser:(BBAUserDetails *)user
                  completion:(void (^)(BBARequest *, NSError *))completion{

    self.wasAskedToAuthenticate = YES;
    self.passedRequest = request;
    self.passedUser = user;
    BBARequest *requestToReturn = self.requestToReturn;
    if (!requestToReturn) {
        requestToReturn = request;
    }
    completion(requestToReturn, self.errorToReturn);
}


@end


@implementation BBAMockRequestFactory
- (BBARequest *) requestWith:(NSURL *)url
                  parameters:(NSDictionary *)parameters
                     headers:(NSDictionary *)headers
                      method:(BBAHTTPMethod)method
                 contentType:(BBAContentType)contentType
                       error:(NSError *__autoreleasing *)error{

    self.passedURL = url;
    self.passedParameters = parameters;
    self.passedHeaders = headers;
    self.passedMethod = method;
    self.passedContentType = contentType;
    
    *error = self.errorToReturn;
    
    return self.requestToReturn;
}
@end

@implementation BBAMockURLSessionDataTask : NSURLSessionDataTask
- (void)resume{
    
}
@end

@implementation BBAMockURLSession : NSURLSession
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler{
    self.passedRequest = request;
    completionHandler(self.dataToReturn, self.responseToReturn, self.errorToReturn);
    return self.taskToReturn;
}
@end

@implementation BBAMockResponseMapper

- (id) responseFromData:(NSData *)data response:(NSURLResponse *)response error:(NSError **)error{
    *error = self.errorToReturn;
    return self.objectToReturn;
}

@end