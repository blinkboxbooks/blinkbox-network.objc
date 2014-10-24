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
- (BOOL) authenticateRequest:(BBARequest *)request
                       error:(NSError **)error
                  completion:(void (^)(void))completion{
    return [self authenticateRequest:request forUser:nil error:error completion:completion];
    
}

- (BOOL) authenticateRequest:(BBARequest *)request
                     forUser:(BBAUserDetails *)user
                       error:(NSError **)error
                  completion:(void (^)(void))completion{
    self.wasAskedToAuthenticate = YES;
    self.passedRequest = request;
    self.passedUser = user;
    *error = self.errorToReturn;
    completion();
    return self.valueToReturn;
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