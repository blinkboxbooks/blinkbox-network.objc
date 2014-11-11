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

- (BOOL) authenticateRequest:(BBARequest *)request
                       error:(NSError **)error
                  completion:(void (^)(void))completion;

- (BOOL) authenticateRequest:(BBARequest *)request
                     forUser:(BBAUserDetails *)user
                       error:(NSError **)error
                  completion:(void (^)(void))completion;

@end
