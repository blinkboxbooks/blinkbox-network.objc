//
//  BBBDefaultAuthenticator.m
//  BBBAPI
//
//  Created by Owen Worley on 13/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBDefaultAuthenticator.h"
#import "BBBAuthenticationService.h"
#import "BBBRequest.h"
#import "BBBAuthData.h"
@interface BBBDefaultAuthenticator ()
@property (nonatomic, strong) BBBAuthenticationService *authService;
@end

@implementation BBBDefaultAuthenticator
- (instancetype) init{
    if (self = [super init]) {
        self.authService = [BBBAuthenticationService new];
    }
    return self;
}

- (BOOL) authenticateRequest:(BBBRequest *)request
                       error:(NSError *__autoreleasing *)error
                  completion:(void (^)(void))completion{

    return [self authenticateRequest:request
                             forUser:self.currentUser
                               error:error
                          completion:completion];
}

- (BOOL) authenticateRequest:(BBBRequest *)request
                     forUser:(BBBUserDetails *)user
                       error:(NSError *__autoreleasing *)error
                  completion:(void (^)(void))completion{

    [self.authService loginUser:user?user:self.currentUser
                         client:user?nil:self.currentClient
                     completion:^(BBBAuthData *data, NSError *error) {

                         NSMutableDictionary *headers = [[[request URLRequest] allHTTPHeaderFields]mutableCopy];
                         NSString *token = data.accessToken;
                         NSString *bearerToken = [NSString stringWithFormat:@"Bearer %@", token];
                         [headers setObject:bearerToken forKey:@"Authorization"];
                         [[request URLRequest]setValue:headers forKey:@"allHTTPHeaderFields"];
                         completion();

    }];

    return YES;
}

@end
