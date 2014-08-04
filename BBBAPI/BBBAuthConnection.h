//
//  BBBAuthConnection.h
//  BBBAPI
//
//  Created by Tomek Kuźma on 31/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBConnection.h"

typedef NS_ENUM(NSInteger, BBBGrantType) {
    BBBGrantTypePassword = 1,
    BBBGrantTypeRegistration = 2,
    BBBGrantTypeRefreshToken = 3,
};

/**
 *  All requests performed by this class have `Content-Type` set to 
 *  `application/x-www-form-urlencoded`. `grantType`, `username`, `password`,
 *  `clientId`, `clientSecret` are appended to the body of the request.
 *  Responses from this connecitons are of the type `application/json`.
 */
@interface BBBAuthConnection : BBBConnection
@property (nonatomic, assign) BBBGrantType grantType;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *clientSecret;
@end
