//
//  BBBAuthenticationService.m
//  BBBNetworking
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBAuthenticationService.h"
#import "BBBConnection.h"
#import "BBBUserDetails.h"
#import "BBBClientDetails.h"

typedef NS_ENUM(NSInteger, BBBGrantType) {
    BBBGrantTypePassword = 1,
    BBBGrantTypeRegistration = 2,
    BBBGrantTypeRefreshToken = 3,
};

NSString * BBBStringGrantType(BBBGrantType type){
    return nil;
}

NSString *const kAuthServiceName = @"com.bbb.AuthenticationService";


@implementation BBBAuthenticationService

- (void) login:(BBBUserDetails *)user
        client:(BBBClientDetails *)client
    completion:(void (^)(BBBAuthData *data, NSError *error))completion{
    
    BBBConnection *connection = [[BBBConnection alloc] initWithDomain:(BBBAPIDomainAuthentication) relativeURL:[self oauthURL]];
    
    [connection addParameterWithKey:@"password" value:user.password];
    [connection addParameterWithKey:@"username" value:user.email];
    [connection addParameterWithKey:@"client_id" value:client.identifier];
    [connection addParameterWithKey:@"client_secret" value:client.secret];
    [connection addParameterWithKey:@"grantType" value:BBBStringGrantType(BBBGrantTypePassword)];
    
    connection.contentType = BBBContentTypeURLEncodedForm;
 
    connection.responseMapper = [BBBNetworkConfiguration responseMapperForServiceName:kAuthServiceName];
    
    
    [connection perform:(BBBHTTPMethodPOST)
             completion:^(BBBAuthData *data, NSError *error) {
                 
                 completion(data,error);
                 
             }];
    
}
- (NSString *)oauthURL{
    return @"oauth2/token";
}

@end
