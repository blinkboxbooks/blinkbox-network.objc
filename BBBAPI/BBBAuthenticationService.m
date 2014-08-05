//
//  BBBAuthenticationService.m
//  BBBNetworking
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBAuthenticationService.h"
#import "BBBAuthenticationServiceConstants.h"
#import "BBBConnection.h"
#import "BBBUserDetails.h"
#import "BBBClientDetails.h"
#import "BBBRequestFactory.h"

@interface BBBAuthenticationService ()
@property (nonatomic, strong) id<BBBResponseMapping> responseMapper;
@end

@implementation BBBAuthenticationService

#pragma mark - Init
- (instancetype) init{
    if (self = [super init]) {
        self.responseMapper = [BBBNetworkConfiguration responseMapperForServiceName:kBBBAuthServiceName];
    }
    return self;
}

#pragma mark - Public API
- (void) registerUser:(BBBUserDetails *)user
               client:(BBBClientDetails *)client
           completion:(void (^)(BBBAuthData *, NSError *))completion{

    @throw [NSException exceptionWithName:@"Unimplemented method"
                               reason:@"Not implemented yet"
                             userInfo:nil];
}

- (void) registerClient:(BBBClientDetails *)client
                forUser:(BBBUserDetails *)user
             completion:(void (^)(BBBAuthData *, NSError *))completion{

    @throw [NSException exceptionWithName:@"Unimplemented method"
                                   reason:@"Not implemented yet"
                                 userInfo:nil];
}

- (void) loginUser:(BBBUserDetails *)user
            client:(BBBClientDetails *)client
        completion:(void (^)(BBBAuthData *, NSError *))completion{
    
    BBBConnection *connection = [[BBBConnection alloc] initWithDomain:(BBBAPIDomainAuthentication)
                                                          relativeURL:[self oauthURL]];
    connection.requestFactory = [BBBRequestFactory new];
#warning Subclassing would simplify setting these parameters\
we could just do setUserDetails: and setClientDetails\
This way the set calls are reduced, and we can do the error checking in\
the subclass

    if (user.email == nil || user.password == nil) {
        completion(nil,nil); //fix
        return;
    }
    [connection addParameterWithKey:kBBBAuthKeyUsername value:user.email];
    [connection addParameterWithKey:kBBBAuthKeyPassword value:user.password];

    //Client id and secret are optional parameters
    if (client.identifier != nil && client.secret != nil) {
        [connection addParameterWithKey:kBBBAuthKeyClientId value:client.identifier];
        [connection addParameterWithKey:kBBBAuthKeyClientSecret value:client.secret];
    }

    NSString *grantType = [BBBAuthenticationServiceConstants stringGrantType:BBBGrantTypePassword];
    [connection addParameterWithKey:kBBBAuthKeyGrantType value:grantType];
    
    connection.contentType = BBBContentTypeURLEncodedForm;

    connection.responseMapper = self.responseMapper;

    [connection perform:(BBBHTTPMethodPOST)
             completion:^(BBBAuthData *data, NSError *error) {
                 
                 completion(data,error);
                 
             }];
}

- (void) refreshAuthData:(BBBAuthData *)data
              completion:(void (^)(BBBAuthData *, NSError *))completion{
    @throw [NSException exceptionWithName:@"Unimplemented method"
                                   reason:@"Not implemented yet"
                                 userInfo:nil];
}

- (void) resetPasswordForUser:(BBBUserDetails *)user
                   completion:(void (^)(BOOL, NSError *))completion{
    @throw [NSException exceptionWithName:@"Unimplemented method"
                                   reason:@"Not implemented yet"
                                 userInfo:nil];
}

- (void) revokeRefreshTokenForUser:(BBBUserDetails *)user
                        completion:(void (^)(BOOL, NSError *))completion{
    @throw [NSException exceptionWithName:@"Unimplemented method"
                                   reason:@"Not implemented yet"
                                 userInfo:nil];
}

- (void) getAllClientsForUser:(BBBUserDetails *)user
                   completion:(void (^)(NSArray *, NSError *))completion{
    @throw [NSException exceptionWithName:@"Unimplemented method"
                                   reason:@"Not implemented yet"
                                 userInfo:nil];
}

- (void) deleteClient:(BBBClientDetails *)client
              forUser:(BBBUserDetails *)user
           completion:(void (^)(BOOL, NSError *))completion{
    @throw [NSException exceptionWithName:@"Unimplemented method"
                                   reason:@"Not implemented yet"
                                 userInfo:nil];
}
#pragma mark - Helper methods
- (NSString *)oauthURL{
    return @"oauth2/token";
}


@end
