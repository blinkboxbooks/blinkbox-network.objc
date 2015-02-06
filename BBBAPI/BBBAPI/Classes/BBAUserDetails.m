//
//  BBAUserDetails.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 29/07/2014.
 

#import "BBAUserDetails.h"

@implementation BBAUserDetails
- (NSString *) description{
    return [NSString stringWithFormat:@"%@, \rfirst name:%@, \rlast name: %@, \remail:%@, \rpassword: %@, \ridentifier: %@, \raccepts T&C: %d, \rallowsMarketing: %d, \rrefresh token: %@", [super description],
            self.firstName, self.lastName, self.email, self.password, self.identifier,
            self.acceptsTermsAndConditions, self.allowMarketing, self.refreshToken];

}
@end
