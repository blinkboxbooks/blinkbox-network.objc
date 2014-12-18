//
//  BBAAuthData.m
//  BBAAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAAuthData.h"
#import "BBAAuthenticationServiceConstants.h"
#import "BBAAuthDataValidator.h"

@interface BBAAuthData ()
@property (nonatomic, strong) NSMutableSet *validaters;
@end

@implementation BBAAuthData

#pragma mark - Creation

- (instancetype) initWithDictionary:(NSDictionary *)dictionary response:(NSURLResponse *)response{
    
    if (self = [super init]) {
        self.validaters = [NSMutableSet set];
        [self.validaters addObject:[BBAAuthDataValidator new]];
        
        self.accessToken = dictionary[kBBAAuthKeyAccessToken];
        self.tokenType = dictionary[kBBAAuthKeyTokenType];
        self.refreshToken = dictionary[kBBAAuthKeyRefreshToken];
        self.userId = dictionary[kBBAAuthKeyUserId];
        self.userURI = dictionary[kBBAAuthKeyUserURI];
        self.userUserName = dictionary[kBBAAuthKeyUserUserName];
        self.userFirstName = dictionary[kBBAAuthKeyUserFirstName];
        self.userLastName = dictionary[kBBAAuthKeyUserLastName];
        
        self.clientId = dictionary[kBBAAuthKeyClientId];
        self.clientURI = dictionary[kBBAAuthKeyClientURI];
        self.clientName = dictionary[kBBAAuthKeyClientName];
        self.clientBrand = dictionary[kBBAAuthKeyClientBrand];
        self.clientModel = dictionary[kBBAAuthKeyClientModel];
        self.clientOS = dictionary[kBBAAuthKeyClientOS];
        self.clientSecret = dictionary[kBBAAuthKeyClientSecret];
        
        //Read the date from the header, convert it,
        NSNumber *expiresIn = dictionary[kBBAAuthKeyExpiresIn];
        NSString *headerTime = [(NSHTTPURLResponse *)response allHeaderFields][@"Date"];
        NSDate *expiryDate = [self dateForExpiresIn:expiresIn serverTime:headerTime];
        self.accessTokenExpirationDate = expiryDate;
        self.lastUsedDate = [self dateForLastUsed:dictionary[kBBAAuthKeyLastUsedDate]];
    }
    return self;
}

#pragma mark - Public

- (BOOL) isValidForResponse:(NSURLResponse *)response{
    for (BBAAuthDataValidator *validator in self.validaters) {
        if ([validator isValid:self forResponse:response]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Private

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

#pragma mark - NSObject

- (NSString *) description{
    return [NSString stringWithFormat:
            @"%@\r"
            @"accessToken : %@\r"
            @"tokenType : %@\r"
            @"accessTokenExpirationDate : %@\r"
            @"refreshToken : %@\r"
            @"userId : %@\r"
            @"userURI : %@\r"
            @"userUserName : %@\r"
            @"userFirstName : %@\r"
            @"userLastName : %@\r"
            @"clientId : %@\r"
            @"clientSecret : %@\r"
            @"clientURI : %@\r"
            @"clientName : %@\r"
            @"clientBrand : %@\r"
            @"clientModel : %@\r"
            @"clientOS : %@\r"
            @"lastUsedDate : %@\r"
            @"successful : %@\r",
            self.accessToken,
            self.tokenType,
            self.accessTokenExpirationDate,
            self.refreshToken,
            self.userId,
            self.userURI,
            self.userUserName,
            self.userFirstName,
            self.userLastName,
            self.clientId,
            self.clientSecret,
            self.clientURI,
            self.clientName,
            self.clientBrand,
            self.clientModel,
            self.clientOS,
            self.lastUsedDate,
            self.successful];
}

@end


