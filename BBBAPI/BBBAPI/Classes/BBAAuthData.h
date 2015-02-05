//
//  BBAAuthData.h
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBAAuthData : NSObject

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *tokenType;
@property (nonatomic, copy) NSDate *accessTokenExpirationDate;
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userURI;
@property (nonatomic, copy) NSString *userUserName;
@property (nonatomic, copy) NSString *userFirstName;
@property (nonatomic, copy) NSString *userLastName;
@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *clientSecret;
@property (nonatomic, copy) NSString *clientURI;
@property (nonatomic, copy) NSString *clientName;
@property (nonatomic, copy) NSString *clientBrand;
@property (nonatomic, copy) NSString *clientModel;
@property (nonatomic, copy) NSString *clientOS;
@property (nonatomic, copy) NSDate *lastUsedDate;

@property (nonatomic, assign) BOOL successful;

- (BOOL) isValidForResponse:(NSURLResponse *)response;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary response:(NSURLResponse *)response;
@end
