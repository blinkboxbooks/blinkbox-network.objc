//
//  BBAUserDetails.h
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 29/07/2014.
 

#import <Foundation/Foundation.h>

@interface BBAUserDetails : NSObject

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) BOOL acceptsTermsAndConditions;
@property (nonatomic, assign) BOOL allowMarketing;
@property (nonatomic, copy) NSString *refreshToken;

@end

