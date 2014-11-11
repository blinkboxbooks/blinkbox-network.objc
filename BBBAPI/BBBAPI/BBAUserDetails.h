//
//  BBAUserDetails.h
//  BBAAPI
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

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

