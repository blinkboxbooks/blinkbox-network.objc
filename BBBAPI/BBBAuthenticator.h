//
//  BBBAuthenticator.h
//  BBBNetworking
//
//  Created by Tomek Kuźma on 24/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BBBRequest;
@class BBBUser;

@protocol BBBAuthenticator <NSObject>

- (BOOL) authenticateRequest:(BBBRequest *)request error:(NSError **)error;

- (BOOL) authenticateRequest:(BBBRequest *)request forUser:(BBBUser *)user error:(NSError **)error;

@end
