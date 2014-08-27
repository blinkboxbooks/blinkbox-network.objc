//
//  BBADefaultAuthenticator.h
//  BBAAPI
//
//  Created by Owen Worley on 13/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBAAuthenticator.h"
@class BBAUserDetails;
@class BBAClientDetails;
@interface BBADefaultAuthenticator : NSObject <BBAAuthenticator>
@property (nonatomic, strong) BBAUserDetails *currentUser;
@property (nonatomic, strong) BBAClientDetails *currentClient;
@end
