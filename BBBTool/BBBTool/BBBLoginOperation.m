//
//  BBBLoginOperation.m
//  BBBTool
//
//  Created by Owen Worley on 18/08/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import "BBBLoginOperation.h"
#import "BBBToolOperationArgument.h"
#import <BBBAPI/BBBAPI.h>

@implementation BBBLoginOperation
+ (instancetype) loginOperation{

    NSArray *loginOperationArguments =
    @[
      [[BBBToolOperationArgument alloc]initWithName:@"user"
                                               help:@"username to use for login (email address)"],
      [[BBBToolOperationArgument alloc]initWithName:@"pass"
                                               help:@"password to use for login"]
      ];

    NSMutableString *loginHelp = [NSMutableString string];
    [loginHelp appendString:@"Log in a user using email and password.\n"];
    [loginHelp appendString:@"Usage   - login user:'username' pass:'password'\n"];
    [loginHelp appendString:@"Example - login user:xctest_books@blinkbox.com pass:xctest_sexytest"];
    BBBLoginOperation *loginOperation = [[BBBLoginOperation alloc]initWithName:@"login"
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
               completion:^(BBBAuthData *data, NSError *error) {

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
              completion:(void (^)(BBBAuthData *data, NSError *error))completion{

    dispatch_semaphore_t bbb_test_semaphore = dispatch_semaphore_create(0);

    BBBAuthenticationService *service = [BBBAuthenticationService new];
    BBBUserDetails *userDetails = [BBBUserDetails new];
    userDetails.email = userName;
    userDetails.password = password;
    __block BBBAuthData *resultAuthData;
    __block NSError *resultError;
    [service loginUser:userDetails client:nil completion:^(BBBAuthData *data, NSError *error) {
        resultAuthData = data;
        resultError = error;
        dispatch_semaphore_signal(bbb_test_semaphore);
    }];


    dispatch_time_t timeoutTime = dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC);
    dispatch_semaphore_wait(bbb_test_semaphore, timeoutTime);

    completion(resultAuthData, resultError);
}
@end
