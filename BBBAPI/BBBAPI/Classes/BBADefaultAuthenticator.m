//
//  BBADefaultAuthenticator.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 13/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBADefaultAuthenticator.h"
#import "BBAAuthenticationService.h"
#import "BBARequest.h"
#import "BBAAuthData.h"
@interface BBADefaultAuthenticator ()
@property (nonatomic, strong) BBAAuthenticationService *authService;
@end

@implementation BBADefaultAuthenticator
- (instancetype) init{
    if (self = [super init]) {
        self.authService = [BBAAuthenticationService new];
    }
    return self;
}

- (void) authenticateRequest:(BBARequest *)request
                  completion:(void (^)(BBARequest *request, NSError *error))completion{

    [self authenticateRequest:request
                             forUser:self.currentUser
                          completion:completion];
}

- (void) authenticateRequest:(BBARequest *)request
                     forUser:(BBAUserDetails *)user
                  completion:(void (^)(BBARequest *request, NSError *error))completion{

    [self.authService loginUser:user ? user : self.currentUser
                         client:user ? nil : self.currentClient
                     completion:^(BBAAuthData *data, NSError *error) {
                         
                         if (!data) {
                             completion(nil, error);
                             return ;
                         }
                         BBARequest *authenticatedRequest = [self authenticateRequest:request withData:data];
                         completion(authenticatedRequest, nil);

    }];

}

- (BBARequest *) authenticateRequest:(BBARequest *)request withData:(BBAAuthData *)data{
    
    
    NSMutableURLRequest *URLRequest = [[request URLRequest] mutableCopy];
    
    NSMutableDictionary *headers = [[URLRequest allHTTPHeaderFields] mutableCopy];
    
    NSString *bearerToken = [NSString stringWithFormat:@"Bearer %@", data.accessToken];
    
    headers[@"Authorization"] = bearerToken;
    
    URLRequest.allHTTPHeaderFields = headers;
    
    request.URLRequest = URLRequest;
    
    
    return request;
}




@end
