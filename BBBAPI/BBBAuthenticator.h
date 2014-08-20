//
//  BBBAuthenticator.h
//  BBBNetworking
//
//  Created by Tomek Kuźma on 24/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BBBRequest;
@class BBBUserDetails;

@protocol BBBAuthenticator <NSObject>

- (BOOL) authenticateRequest:(BBBRequest *)request
                       error:(NSError **)error
                  completion:(void (^)(void))completion;

- (BOOL) authenticateRequest:(BBBRequest *)request
                     forUser:(BBBUserDetails *)user
                       error:(NSError **)error
                  completion:(void (^)(void))completion;

@end
