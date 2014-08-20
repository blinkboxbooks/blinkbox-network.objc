//
//  BBBTool.m
//  BBBTool
//
//  Created by Owen Worley on 18/08/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import "BBBTool.h"
#import "BBBToolOperation.h"
#import "BBBToolOperationArgument.h"
#import "BBBLoginOperation.h"
@interface BBBTool ()
@property (nonatomic, copy) NSArray *cliArguments;
@property (nonatomic, copy) NSDictionary *operations;
@end

@implementation BBBTool

- (instancetype) init{
    self = [super init];
    if (self) {
        NSMutableArray *arguments = [[[NSProcessInfo processInfo]arguments]mutableCopy];
        if ([arguments count]>0) {
            [arguments removeObjectAtIndex:0];
        }
        self.cliArguments = arguments;
        [self initOperations];
    }
    return self;
}

- (void) initOperations{
    NSMutableDictionary *dict = [NSMutableDictionary new];

    BBBLoginOperation *loginOperation = [BBBLoginOperation loginOperation];

    __weak typeof(self) weakSelf = self;
    BBBToolOperation *helpOperation = [[BBBToolOperation alloc]initWithName:@"help"
                                                                       help:@"Print help"
                                                                  arguments:nil
                                                                     action:^(NSArray *cliArguments) {
                                                                         [weakSelf printHelp];
                                                                     }];

    BBBToolOperation *refreshOperation = [[BBBToolOperation alloc]initWithName:@"refreshtoken"
                                                                          help:@"Refresh an access token with a refresh token"
                                                                     arguments:@[
                                                                                 [[BBBToolOperationArgument alloc]initWithName:@"token" help:@"the refresh token"]
                                                                                 ]
                                                                        action:^(NSArray *cliArguments) {
                                                                            NSPrint(@"Not implemented yet");
                                                                        }];
    
    
    [dict setObject:loginOperation forKey:loginOperation.name];
    [dict setObject:helpOperation forKey:helpOperation.name];
    [dict setObject:refreshOperation forKey:refreshOperation.name];

    self.operations = dict;
}

- (void) printHelp{
    NSPrint(@"Valid commands:");
    for (BBBToolOperation *operation in [self.operations allValues]) {
        NSPrint(@"%@ - %@\n", operation.name, operation.help);
    }
}

- (void) processArguments{

    if ([self.cliArguments count] == 0) {
        [self printHelp];
        return;
    }

    for (NSString *arg in self.cliArguments) {
        BBBToolOperation *operation = self.operations[arg];
        if (operation != nil) {
            NSMutableArray *arguments = [self.cliArguments mutableCopy];
            [arguments removeObject:arg];
            if ([operation canPerformOperationWithArguments:arguments]) {
                [operation performOperationWithArguments:arguments];
                return;
            }
            NSPrint([operation help]);
            return;
        }
    }

    NSPrint(@"Unrecognised command, see help");
}

@end
