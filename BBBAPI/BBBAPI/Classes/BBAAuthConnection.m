//
//  BBAAuthConnection.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 31/07/2014.
 

#import "BBAAuthConnection.h"

@implementation BBAAuthConnection

- (instancetype) initWithDomain:(BBAAPIDomain)domain relativeURL:(NSString *)relativeURLString{
    if (self = [super initWithDomain:domain relativeURL:relativeURLString]) {
        self.contentType = BBAContentTypeURLEncodedForm;
    }
    return self;
}

- (void) setUsername:(NSString *)username{
    [self setParameterValue:username withKey:kBBAAuthKeyUsername];
}

- (void) setPassword:(NSString *)password{
    [self setParameterValue:password withKey:kBBAAuthKeyPassword];
}

- (void) setClientId:(NSString *)clientId{
    [self setParameterValue:clientId withKey:kBBAAuthKeyClientId];
}

- (void) setClientSecret:(NSString *)clientSecret{
    [self setParameterValue:clientSecret withKey:kBBAAuthKeyClientSecret];
}

- (void) setClientName:(NSString *)clientName{
    [self setParameterValue:clientName withKey:kBBAAuthKeyClientName];
}

- (void) setClientBrand:(NSString *)clientBrand{
    [self setParameterValue:clientBrand withKey:kBBAAuthKeyClientBrand];
}

- (void) setClientOS:(NSString *)clientOS{
    [self setParameterValue:clientOS withKey:kBBAAuthKeyClientOS];
}

- (void) setClientModel:(NSString *)clientModel{
    [self setParameterValue:clientModel withKey:kBBAAuthKeyClientModel];
}

- (void) setGrantType:(BBAGrantType)grantType{
    NSString *grantTypeString = [BBAAuthenticationServiceConstants stringGrantType:grantType];
    [super addParameterWithKey:kBBAAuthKeyGrantType value:grantTypeString];
}

- (void) setRefreshToken:(NSString *)refreshToken{
    [self setParameterValue:refreshToken withKey:kBBAAuthKeyRefreshToken];
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
    [self setParameterValue:firstName withKey:kBBAAuthKeyFirstName];
    [self setParameterValue:lastName withKey:kBBAAuthKeyLastName];
    [self setParameterValue:acceptedTerms?@"true":@"false" withKey:kBBAAuthKeyAcceptedTerms];
    [self setParameterValue:allowMarketing?@"true":@"false" withKey:kBBAAuthKeyAllowMarketing];
    [self setParameterValue:clientName withKey:kBBAAuthKeyClientName];
    [self setParameterValue:clientBrand withKey:kBBAAuthKeyClientBrand];
    [self setParameterValue:clientOS withKey:kBBAAuthKeyClientOS];
    [self setParameterValue:clientModel withKey:kBBAAuthKeyClientModel];

}



@end
