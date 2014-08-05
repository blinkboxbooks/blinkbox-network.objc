//
//  BBBAuthData.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBAuthData.h"

@interface BBBAuthDataValidator : NSObject

- (BOOL) isValid:(BBBAuthData *)data;

@end

@implementation BBBAuthDataValidator
- (BOOL) isValid:(BBBAuthData *)data{

    //Login without client
    NSInteger expectedValidProperties = 9;

    NSInteger numValidProperties = 0;
    numValidProperties += (data.accessToken != nil);
    numValidProperties += (data.tokenType != nil);
    numValidProperties += (data.accessTokenExpirationDate != nil);
    numValidProperties += (data.refreshToken != nil);
    numValidProperties += (data.userId != nil);
    numValidProperties += (data.userURI != nil);
    numValidProperties += (data.userUserName != nil);
    numValidProperties += (data.userFirstName != nil);
    numValidProperties += (data.userLastName != nil);

    if (numValidProperties>=expectedValidProperties) {
        return YES;
    }
    return NO;
}


@end

@interface BBBAuthData ()
@property (nonatomic, strong) NSMutableSet *validaters;
@end

@implementation BBBAuthData

- (instancetype) initWithDictionary:(NSDictionary *)dictionary{

    if (self = [super init]) {
        self.validaters = [NSMutableSet set];
        [self.validaters addObject:[BBBAuthDataValidator new]];

        self.accessToken = dictionary[@"access_token"];
        self.tokenType = dictionary[@"token_type"];

#warning implement date formatter
        self.accessTokenExpirationDate = [NSDate new];
        self.refreshToken = dictionary[@"refresh_token"];
        self.userId = dictionary[@"user_id"];
        self.userURI = dictionary[@"user_uri"];
        self.userUserName = dictionary[@"user_username"];
        self.userFirstName = dictionary[@"user_first_name"];
        self.userLastName = dictionary[@"user_last_name"];

    }
    return self;
}

- (BOOL) isValid{
    for (BBBAuthDataValidator *validator in self.validaters) {
        if ([validator isValid:self]) {
            return YES;
        }
    }
    return NO;
}

@end


