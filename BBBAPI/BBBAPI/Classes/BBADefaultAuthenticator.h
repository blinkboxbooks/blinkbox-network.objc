//
//  BBADefaultAuthenticator.h
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 13/08/2014.
 

#import <Foundation/Foundation.h>
#import "BBAAuthenticator.h"
@class BBAUserDetails;
@class BBAClientDetails;
@interface BBADefaultAuthenticator : NSObject <BBAAuthenticator>
@property (nonatomic, strong) BBAUserDetails *currentUser;
@property (nonatomic, strong) BBAClientDetails *currentClient;
@end
