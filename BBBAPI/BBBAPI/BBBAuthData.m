//
//  BBBAuthData.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBAuthData.h"
#import "BBBAuthenticationServiceConstants.h"
#import "BBBAuthDataValidator.h"

@interface BBBAuthData ()
@property (nonatomic, strong) NSMutableSet *validaters;
@end

@implementation BBBAuthData
- (NSDate *) dateForExpiresIn:(NSNumber *)expiresIn serverTime:(NSString *)serverTime{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_GB"]];
    });

    NSDate *nowDate = serverTime? [formatter dateFromString:serverTime] : [NSDate new];
    return [nowDate dateByAddingTimeInterval:[expiresIn doubleValue]];
}

- (NSDate *) dateForLastUsed:(NSString *)lastUsedTime{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-mm-dd"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_GB"]];
    });

    NSDate *nowDate = lastUsedTime? [formatter dateFromString:lastUsedTime] : [NSDate new];
    return nowDate;
}


- (instancetype) initWithDictionary:(NSDictionary *)dictionary response:(NSURLResponse *)response{

    if (self = [super init]) {
        self.validaters = [NSMutableSet set];
        [self.validaters addObject:[BBBAuthDataValidator new]];

        self.accessToken = dictionary[kBBBAuthKeyAccessToken];
        self.tokenType = dictionary[kBBBAuthKeyTokenType];
        self.refreshToken = dictionary[kBBBAuthKeyRefreshToken];
        self.userId = dictionary[kBBBAuthKeyUserId];
        self.userURI = dictionary[kBBBAuthKeyUserURI];
        self.userUserName = dictionary[kBBBAuthKeyUserUserName];
        self.userFirstName = dictionary[kBBBAuthKeyUserFirstName];
        self.userLastName = dictionary[kBBBAuthKeyUserLastName];

        self.clientId = dictionary[kBBBAuthKeyClientId];
        self.clientURI = dictionary[kBBBAuthKeyClientURI];
        self.clientName = dictionary[kBBBAuthKeyClientName];
        self.clientBrand = dictionary[kBBBAuthKeyClientBrand];
        self.clientModel = dictionary[kBBBAuthKeyClientModel];
        self.clientOS = dictionary[kBBBAuthKeyClientOS];
        self.clientSecret = dictionary[kBBBAuthKeyClientSecret];

        //Read the date from the header, convert it,
        NSNumber *expiresIn = dictionary[kBBBAuthKeyExpiresIn];
        NSString *headerTime = [(NSHTTPURLResponse *)response allHeaderFields][@"Date"];
        NSDate *expiryDate = [self dateForExpiresIn:expiresIn serverTime:headerTime];
        self.accessTokenExpirationDate = expiryDate;
        self.lastUsedDate = [self dateForLastUsed:dictionary[kBBBAuthKeyLastUsedDate]];
    }
    return self;
}

- (BOOL) isValidForResponse:(NSURLResponse *)response{
    for (BBBAuthDataValidator *validator in self.validaters) {
        if ([validator isValid:self forResponse:response]) {
            return YES;
        }
    }
    return NO;
}

@end


