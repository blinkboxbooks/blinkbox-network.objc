//
//  BBAAuthenticator.h
//  BBANetworking
//
//  Created by Tomek Kuźma on 24/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

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
