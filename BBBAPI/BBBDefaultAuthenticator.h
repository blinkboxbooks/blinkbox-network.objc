//
//  BBBDefaultAuthenticator.h
//  BBBAPI
//
//  Created by Owen Worley on 13/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBBAuthenticator.h"
@class BBBUserDetails;
@class BBBClientDetails;
@interface BBBDefaultAuthenticator : NSObject <BBBAuthenticator>
@property (nonatomic, strong) BBBUserDetails *currentUser;
@property (nonatomic, strong) BBBClientDetails *currentClient;
@end
