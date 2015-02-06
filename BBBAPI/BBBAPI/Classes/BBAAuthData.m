//
//  BBAAuthData.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 30/07/2014.
 

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
            @"\r"
            @"1. accessToken : %@\r"
            @"2. tokenType : %@\r"
            @"3. accessTokenExpirationDate : %@\r"
            @"4. refreshToken : %@\r"
            @"5. userId : %@\r"
            @"6. userURI : %@\r"
            @"7. userUserName : %@\r"
            @"8. userFirstName : %@\r"
            @"9. userLastName : %@\r"
            @"10. clientId : %@\r"
            @"11. clientSecret : %@\r"
            @"12. clientURI : %@\r"
            @"13. clientName : %@\r"
            @"14. clientBrand : %@\r"
            @"15. clientModel : %@\r"
            @"16. clientOS : %@\r"
            @"17. lastUsedDate : %@\r"
            @"18. successful : %@\r",
            /*1*/ self.accessToken,
            /*2*/self.tokenType,
            /*3*/self.accessTokenExpirationDate,
            /*4*/self.refreshToken,
            /*5*/self.userId,
            /*6*/self.userURI,
            /*7*/self.userUserName,
            /*8*/self.userFirstName,
            /*9*/self.userLastName,
            /*10*/self.clientId,
            /*11*/self.clientSecret,
            /*12*/self.clientURI,
            /*13*/self.clientName,
            /*14*/self.clientBrand,
            /*15*/self.clientModel,
            /*16*/self.clientOS,
            /*17*/self.lastUsedDate,
            /*18*/@(self.successful)];
}

@end


