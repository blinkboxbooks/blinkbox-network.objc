//
//  BBAAuthenticator.h
//  BBANetworking
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 24/07/2014.
 

#import <Foundation/Foundation.h>
@class BBARequest;
@class BBAUserDetails;

@protocol BBAAuthenticator <NSObject>

- (void) authenticateRequest:(BBARequest *)request
                  completion:(void (^)(BBARequest *request, NSError *error))completion;

- (void) authenticateRequest:(BBARequest *)request
                     forUser:(BBAUserDetails *)user
                  completion:(void (^)(BBARequest *request, NSError *error))completion;

@end
