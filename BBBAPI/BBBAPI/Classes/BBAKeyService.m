//
//  BBAKeyService.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAKeyService.h"
#import "BBAAPIErrors.h"
#import "BBAConnection.h"

NSString *const BBAKeyServiceDomain = @"BBA.error.keyServiceDomain";
NSString *const BBAKeyServiceName = @"com.BBA.keyService";

@interface BBAKeyService ()
@property (nonatomic, strong) BBANetworkConfiguration *configuration;
@end

@implementation BBAKeyService

#pragma mark - Public Methods

- (void) getKeyForURL:(NSURL *)keyURL
            publicKey:(NSString *)publicKey
              forUser:(BBAUserDetails *)user
           completion:(void (^)(NSData *key, NSError *error))completion{

    NSParameterAssert(keyURL);
    NSParameterAssert(publicKey);
    NSParameterAssert(completion);
    if (!completion) {
        return;
    }

    if (!keyURL || !publicKey) {
        NSError *error;
        error = [NSError errorWithDomain:BBAKeyServiceDomain
                                    code:BBAAPIWrongUsage
                                userInfo:nil];
        completion(nil, error);
        return;
    }

    BBAConnection *connection = [[BBAConnection alloc] initWithBaseURL:keyURL];

    connection.authenticator = [self.configuration sharedAuthenticator];

    connection.responseMapper = [self.configuration newResponseMapperForServiceName:BBAKeyServiceName];

    [connection addParameterWithKey:@"key" value:publicKey];

    [connection setContentType:BBAContentTypeURLUnencodedForm];
    
    [connection perform:(BBAHTTPMethodPOST)
                forUser:user
             completion:^(id response, NSError *error) {
                 completion(response, error);
             }];

}

#pragma mark - Getters

- (BBANetworkConfiguration *) configuration{
    if (!_configuration) {
        _configuration = [BBANetworkConfiguration defaultConfiguration];
    }

    return _configuration;
}

@end
