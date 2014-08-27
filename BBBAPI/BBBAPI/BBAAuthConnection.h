//
//  BBAAuthConnection.h
//  BBAAPI
//
//  Created by Tomek Kuźma on 31/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAConnection.h"
#import "BBAAuthenticationServiceConstants.h"

/**
 *  All requests performed by this class have `Content-Type` set to 
 *  `application/x-www-form-urlencoded`. `grantType`, `username`, `password`,
 *  `clientId`, `clientSecret` are appended to the body of the request.
 *  Responses from this connecitons are of the type `application/json`.
 */
@interface BBAAuthConnection : BBAConnection

- (void) setUsername:(NSString *)username;
- (void) setPassword:(NSString *)password;
- (void) setClientId:(NSString *)clientId;
- (void) setClientSecret:(NSString *)clientSecret;
- (void) setClientName:(NSString *)clientName;
- (void) setClientBrand:(NSString *)clientBrand;
- (void) setClientOS:(NSString *)clientOS;
- (void) setClientModel:(NSString *)clientModel;
- (void) setGrantType:(BBAGrantType)grantType;
- (void) setRefreshToken:(NSString *)refreshToken;

- (void) setUsername:(NSString *)username
            password:(NSString *)password
           firstName:(NSString *)firstName
            lastName:(NSString *)lastName
       acceptedTerms:(BOOL)acceptedTerms
      allowMarketing:(BOOL)allowMarketing
          clientName:(NSString *)clientName
         clientBrand:(NSString *)clientBrand
            clientOS:(NSString *)clientOS
         clientModel:(NSString *)clientModel;


@end
