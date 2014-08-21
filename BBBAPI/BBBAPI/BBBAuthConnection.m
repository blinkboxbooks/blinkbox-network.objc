//
//  BBBAuthConnection.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 31/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBAuthConnection.h"

@implementation BBBAuthConnection

- (instancetype) initWithDomain:(BBBAPIDomain)domain relativeURL:(NSString *)relativeURLString{
    if (self = [super initWithDomain:domain relativeURL:relativeURLString]) {
        self.contentType = BBBContentTypeURLEncodedForm;
    }
    return self;
}

- (void) setUsername:(NSString *)username{
    [self setParameterValue:username withKey:kBBBAuthKeyUsername];
}

- (void) setPassword:(NSString *)password{
    [self setParameterValue:password withKey:kBBBAuthKeyPassword];
}

- (void) setClientId:(NSString *)clientId{
    [self setParameterValue:clientId withKey:kBBBAuthKeyClientId];
}

- (void) setClientSecret:(NSString *)clientSecret{
    [self setParameterValue:clientSecret withKey:kBBBAuthKeyClientSecret];
}

- (void) setClientName:(NSString *)clientName{
    [self setParameterValue:clientName withKey:kBBBAuthKeyClientName];
}

- (void) setClientBrand:(NSString *)clientBrand{
    [self setParameterValue:clientBrand withKey:kBBBAuthKeyClientBrand];
}

- (void) setClientOS:(NSString *)clientOS{
    [self setParameterValue:clientOS withKey:kBBBAuthKeyClientOS];
}

- (void) setClientModel:(NSString *)clientModel{
    [self setParameterValue:clientModel withKey:kBBBAuthKeyClientModel];
}

- (void) setGrantType:(BBBGrantType)grantType{
    NSString *grantTypeString = [BBBAuthenticationServiceConstants stringGrantType:grantType];
    [super addParameterWithKey:kBBBAuthKeyGrantType value:grantTypeString];
}

- (void) setRefreshToken:(NSString *)refreshToken{
    [self setParameterValue:refreshToken withKey:kBBBAuthKeyRefreshToken];
}

- (void) setUsername:(NSString *)username
            password:(NSString *)password
           firstName:(NSString *)firstName
            lastName:(NSString *)lastName
       acceptedTerms:(BOOL)acceptedTerms
      allowMarketing:(BOOL)allowMarketing
          clientName:(NSString *)clientName
         clientBrand:(NSString *)clientBrand
            clientOS:(NSString *)clientOS
         clientModel:(NSString *)clientModel{
    [self setUsername:username];
    [self setPassword:password];
    [self setParameterValue:firstName withKey:kBBBAuthKeyFirstName];
    [self setParameterValue:lastName withKey:kBBBAuthKeyLastName];
    [self setParameterValue:acceptedTerms?@"true":@"false" withKey:kBBBAuthKeyAcceptedTerms];
    [self setParameterValue:allowMarketing?@"true":@"false" withKey:kBBBAuthKeyAllowMarketing];
    [self setParameterValue:clientName withKey:kBBBAuthKeyClientName];
    [self setParameterValue:clientBrand withKey:kBBBAuthKeyClientBrand];
    [self setParameterValue:clientOS withKey:kBBBAuthKeyClientOS];
    [self setParameterValue:clientModel withKey:kBBBAuthKeyClientModel];

}

- (void)setParameterValue:(NSString *)parameter withKey:(NSString *)key{
    if (parameter) {
        [super addParameterWithKey:key value:parameter];
    }
    else {
        [super removeParameterWithKey:key];
    }
}


@end
