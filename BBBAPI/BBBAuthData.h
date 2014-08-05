//
//  BBBAuthData.h
//  BBBAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBBAuthData : NSObject

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *tokenType;
@property (nonatomic, strong) NSDate *accessTokenExpirationDate;
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userURI;
@property (nonatomic, copy) NSString *userUserName;
@property (nonatomic, copy) NSString *userFirstName;
@property (nonatomic, copy) NSString *userLastName;
@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *clientSecret;
@property (nonatomic, copy) NSString *clientURI;
@property (nonatomic, readonly, getter = isValid) BOOL validate;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;
@end
