//
//  BBTLoginOperation.m
//  BBBTool
//
//  Created by Owen Worley on 18/08/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import "BBTLoginOperation.h"
#import "BBTArgument.h"
#import <BBBAPI/BBBAPI.h>

@implementation BBTLoginOperation
+ (instancetype) loginOperation{

    NSArray *loginOperationArguments =
    @[
      [[BBTArgument alloc]initWithName:@"user"
                                               help:@"username to use for login (email address)"],
      [[BBTArgument alloc]initWithName:@"pass"
                                               help:@"password to use for login"]
      ];

    NSMutableString *loginHelp = [NSMutableString string];
    [loginHelp appendString:@"Log in a user using email and password.\n"];
    [loginHelp appendString:@"Usage   - login user:'username' pass:'password'\n"];
    [loginHelp appendString:@"Example - login user:xctest_books@blinkbox.com pass:xctest_sexytest"];
    BBTLoginOperation *loginOperation = [[BBTLoginOperation alloc]initWithName:@"login"
                                                                          help:loginHelp
                                                                     arguments:loginOperationArguments
                                                                        action:nil];

    return loginOperation;
}

- (void) performOperationWithArguments:(NSArray *)arguments{

    NSArray *trimmedArguments = [super trimmedArguments:arguments];
    NSString *user = trimmedArguments[0];
    NSString *pass = trimmedArguments[1];

    BBPrint(@"Login with user '%@', password '%@'", user, [@"" stringByPaddingToLength:pass.length
                                                                          withString:@"*"
                                                                     startingAtIndex:0]);

    [self doLoginWithUser:user
                 password:pass
               completion:^(BBAAuthData *data, NSError *error) {

                   BBPrint(@"Login result %@", data ? @"Success" : @"Fail");
                   if (data) {
                       BBPrint(@"Access token:\n%@\n\nRefresh token:\n%@\n\n", data.accessToken, data.refreshToken);
                   }
                   else if (error) {
                       BBPrint(@"Error domain %@ code %li", error.domain, (long)error.code);
                   }
               }];
}

- (void) doLoginWithUser:(NSString *)userName
                password:(NSString *)password
              completion:(void (^)(BBAAuthData *data, NSError *error))completion{

    dispatch_semaphore_t bbb_test_semaphore = dispatch_semaphore_create(0);

    BBAAuthenticationService *service = [BBAAuthenticationService new];
    BBAUserDetails *userDetails = [BBAUserDetails new];
    userDetails.email = userName;
    userDetails.password = password;
    __block BBAAuthData *resultAuthData;
    __block NSError *resultError;
    [service loginUser:userDetails client:nil completion:^(BBAAuthData *data, NSError *error) {
        resultAuthData = data;
        resultError = error;
        dispatch_semaphore_signal(bbb_test_semaphore);
    }];


    dispatch_time_t timeoutTime = dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC);
    dispatch_semaphore_wait(bbb_test_semaphore, timeoutTime);

    completion(resultAuthData, resultError);
}
@end
