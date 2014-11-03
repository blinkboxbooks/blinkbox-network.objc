//
//  BBADefaultAuthenticator.m
//  BBAAPI
//
//  Created by Owen Worley on 13/08/2014.
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

- (BOOL) authenticateRequest:(BBARequest *)request
                       error:(NSError *__autoreleasing *)error
                  completion:(void (^)(void))completion{

    return [self authenticateRequest:request
                             forUser:self.currentUser
                               error:error
                          completion:completion];
}

- (BOOL) authenticateRequest:(BBARequest *)request
                     forUser:(BBAUserDetails *)user
                       error:(NSError *__autoreleasing *)error
                  completion:(void (^)(void))completion{

    [self.authService loginUser:user ? user : self.currentUser
                         client:user ? nil : self.currentClient
                     completion:^(BBAAuthData *data, NSError *error) {

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
