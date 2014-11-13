//
//  BBTLibraryOperation.m
//  BBBTool
//
//  Created by Tomek Kuźma on 03/11/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import "BBTLibraryOperation.h"
#import "BBTArgument.h"
#import "BBBAPI.h"

@implementation BBTLibraryOperation

+ (instancetype) libraryContentsOperation{
    
    NSMutableString *help = [NSMutableString string];
    [help appendString:@"Grab user's library usingemail and password.\n"];
    [help appendString:@"Usage   - library user:'username' pass:'password'\n"];
    [help appendString:@"Example - library user:xctest_books@blinkbox.com pass:xctest_sexytest"];
    
    NSArray *arguments =
    @[
      [[BBTArgument alloc] initWithName:@"user"
                                   help:@"username to use for login (email address)"],
      [[BBTArgument alloc] initWithName:@"pass"
                                   help:@"password to use for login"]
      ];
    
    BBTLibraryOperation *operation = [[BBTLibraryOperation alloc] initWithName:@"library"
                                                                          help:help
                                                                     arguments:arguments
                                                                        action:nil];
    return operation;
}

- (void) performOperationWithArguments:(NSArray *)arguments{
    
    NSArray *trimmedArguments = [super trimmedArguments:arguments];
    NSString *user = trimmedArguments[0];
    NSString *pass = trimmedArguments[1];
    
    BBPrint(@"Login with user '%@', password '%@'", user, [@"" stringByPaddingToLength:pass.length
                                                                            withString:@"*"
                                                                       startingAtIndex:0]);
    
    BBALibraryService *service = [BBALibraryService new];
    
    NSDate *date;
    
    BBAUserDetails *userDetails = [BBAUserDetails new];
    userDetails.email = user;
    userDetails.password = pass;
    
    dispatch_semaphore_t bbb_test_semaphore = dispatch_semaphore_create(0);
    [service getChangesAfterDate:date
                            user:userDetails
                      completion:^(NSArray *items, NSDate *syncDate, NSError *error) {
                          if (!items) {
                              BBPrint(@"Can't fetch user library :%@", [error description]);
                          }
                          else{
                              [self printContentsOfLibrary:items date:syncDate];
                          }
                          dispatch_semaphore_signal(bbb_test_semaphore);
                      }];
    
    
    dispatch_time_t timeoutTime = dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC);
    dispatch_semaphore_wait(bbb_test_semaphore, timeoutTime);
    
}

- (void) printContentsOfLibrary:(NSArray *)items date:(NSDate *)syncDate{
    for (NSInteger i = 0; i < items.count; i ++) {
        BBALibraryItem *item =  items[i];
        BBPrint(@"item %ld\r %@", i , [item description]);
    }
    
    BBPrint(@"---- total %ld items, synced on %@ ----", items.count, [syncDate description]);

    
}

@end
