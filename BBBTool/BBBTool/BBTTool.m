//
//  BBTTool.m
//  BBBTool
//
//  Created by Owen Worley on 18/08/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import "BBTTool.h"
#import "BBTOperation.h"
#import "BBTArgument.h"
#import "BBTLoginOperation.h"

NSString *const kBBTDataKeyUserName = @"username";
NSString *const kBBTDataKeyPassword = @"password";
NSString *const kBBTDataKeyDebug = @"debugVerbose";

@interface BBTTool ()
@property (nonatomic, copy) NSArray *cliArguments;
@property (nonatomic, copy) NSDictionary *operations;
@property (nonatomic, copy) NSDictionary *globalArguments;
@property (nonatomic, copy) NSDictionary *globalVariables;
@end

@implementation BBTTool

- (instancetype) init{
    self = [super init];
    if (self) {
        NSMutableArray *arguments = [[[NSProcessInfo processInfo]arguments]mutableCopy];
        if ([arguments count]>0) {
            [arguments removeObjectAtIndex:0];
        }
        self.cliArguments = arguments;
        [self initOperations];
        [self initGlobalArguments];

        self.globalVariables = [NSMutableDictionary new];
    }
    return self;
}

- (void) initGlobalArguments{

    NSMutableDictionary *args = [NSMutableDictionary new];

    NSString *name;
    NSString *help;
    BBTArgument *argument;

    name = @"--with-user";
    help = @"Specify a user to perform this action on";
    argument = [[BBTArgument alloc]initWithName:name
                                                        help:help
                                                     dataKey:kBBTDataKeyUserName
                                                   dataClass:[NSString class]];
    [args setObject:argument forKey:name];

    name = @"--with-password";
    help = @"Specify a password to perform this action on";
    argument = [[BBTArgument alloc]initWithName:name
                                                        help:help
                                                     dataKey:kBBTDataKeyPassword
                                                   dataClass:[NSString class]];
    [args setObject:argument forKey:name];


    name = @"--debug";
    help = @"Enable debug output (very verbose)";
    argument = [[BBTArgument alloc]initWithName:name
                                                        help:help
                                                     dataKey:kBBTDataKeyDebug
                                                   dataClass:nil];
    [args setObject:argument forKey:name];



    self.globalArguments = args;
}

- (void) initOperations{
    NSMutableDictionary *dict = [NSMutableDictionary new];

    BBTLoginOperation *loginOperation = [BBTLoginOperation loginOperation];

    __weak typeof(self) weakSelf = self;
    BBTOperation *helpOperation = [[BBTOperation alloc]initWithName:@"help"
                                                                       help:@"Print help"
                                                                  arguments:nil
                                                                     action:^(NSArray *cliArguments) {
                                                                         [weakSelf printHelp];
                                                                     }];

    BBTOperation *refreshOperation = [[BBTOperation alloc]initWithName:@"refreshtoken"
                                                                          help:@"Refresh an access token with a refresh token"
                                                                     arguments:@[
                                                                                 [[BBTArgument alloc]initWithName:@"token" help:@"the refresh token"]
                                                                                 ]
                                                                        action:^(NSArray *cliArguments) {
                                                                            BBPrint(@"Not implemented yet");
                                                                        }];


    [dict setObject:loginOperation forKey:loginOperation.name];
    [dict setObject:helpOperation forKey:helpOperation.name];
    [dict setObject:refreshOperation forKey:refreshOperation.name];

    self.operations = dict;
}

- (void) printHelp{
    BBPrint(@"Valid commands:");
    for (BBTOperation *operation in [self.operations allValues]) {
        BBPrint(@"%@ - %@\n", operation.name, operation.help);
    }
}

/**
 *  Parse the CLI Argument array and add return a dictionary of any global key-value options.
 *  This method will remove parsed arguments from the `arguments` parameter
 *
 *  @param arguments A list of CLI arguments to parse. Parsed arguments are removed from this array.
 *
 *  @return An NSDictionary of key-value global options.
 */
- (NSDictionary *) globalDataForArguments:(NSArray **)arguments{

    NSMutableDictionary *globalData = [NSMutableDictionary new];
    NSMutableArray *parsedArguments = [*arguments mutableCopy];

    //GLOBAL ARGUMENTS
    for (NSString *arg in *arguments) {
        //If it doesnt have a colon, try to get argument that has nil dataClass
        if ([arg rangeOfString:@":"].location == NSNotFound) {
            BBTArgument *globalArgument = self.globalArguments[arg];
            if (!globalArgument) {
                continue;
            }
            if (!globalArgument.dataClass) {
                [globalData setObject:@(YES) forKey:globalArgument.dataKey];
                [parsedArguments removeObject:arg];
                continue;
            }

        }
        NSRange rangeOfColon = [arg rangeOfString:@":"];
        if (rangeOfColon.location == NSNotFound) {
            continue;
        }

        NSString *argName = [arg substringToIndex:rangeOfColon.location];
        if ([argName length] == 0) {
            continue;
        }

        BBTArgument *globalArgument = self.globalArguments[argName];
        if (!globalArgument) {
            continue;
        }

        NSString *value = [arg substringFromIndex:rangeOfColon.location+1];
        if ([value length] == 0) {
            continue;
        }

        if (globalData[globalArgument.dataKey] != nil) {
            [self reportDuplicateArgument:globalArgument withValue:value];
            [self exitWithError];

        }

        [globalData setObject:value forKey:globalArgument.dataKey];
        [parsedArguments removeObject:arg];

    }

    *arguments = parsedArguments;

    return globalData;
}

/**
 *  Parse the CLI Argument array and add return an array of any commands detected.
 *  This method will remove parsed arguments from the `arguments` parameter
 *
 *  @param arguments A list of CLI arguments to parse. Parsed arguments are removed from this array.
 *
 *  @return An NSArray of `BBBToolOperations` detected in the CLI arguments.
 */
- (NSArray *)commandsForArguments:(NSArray **)allArguments{

    NSMutableArray *parsedCommands = [NSMutableArray new];
    NSMutableArray *parsedArguments = [*allArguments mutableCopy];

    for (NSString *arg in *allArguments) {
        BBTOperation *operation = self.operations[arg];
        if (operation != nil) {
            NSMutableArray *argumentParamaters = [parsedArguments mutableCopy];
            [argumentParamaters removeObject:arg];
            NSArray *tokenisedParamters = [operation tokeniseArgumentParamaters:argumentParamaters];

            if ([operation canPerformOperationWithArguments:tokenisedParamters]) {
                [parsedArguments removeObject:arg];
                [parsedArguments removeObjectsInArray:tokenisedParamters];
                operation.tokenisedParamaters = tokenisedParamters;
                [parsedCommands addObject:operation];
                continue;
            }
        }
    }

    *allArguments = parsedArguments;
    return parsedCommands;
}

- (void) processArguments{

    if ([self.cliArguments count] == 0) {
        [self printHelp];
        return;
    }

    //Parse Global Arguments. Arguments will have any global args removed after parsing
    NSArray *arguments = self.cliArguments;
    self.globalVariables = [self globalDataForArguments:&arguments];


    //Parse Command Arguments. Arguments will have any recognised commands removed after parsing
    NSArray *commands = [self commandsForArguments:&arguments];

    //Print help for commands with incorrect arguments
    if ([arguments count]>0) {
        for (NSString *unrecognisedCommand in arguments) {
            BBTOperation *operation = self.operations[unrecognisedCommand];
            if (operation) {
                BBPrint(@"Error with command '%@'. See help:", unrecognisedCommand);
                BBPrint(@"%@", operation.help);
                BBPrint(@"\n");
            }
        }
    }

    //Perform commands
    for (BBTOperation *operation in commands) {
        [operation performOperationWithArguments:operation.tokenisedParamaters];
    }



    if (self.globalVariables[kBBTDataKeyDebug]) {
        [self printDebugArgumentInfo];
    }

}

- (void) printDebugArgumentInfo{
    BBPrint(@"-----DEBUG-----");
    BBPrint(@"--All Command line arguments--");
    for (NSString *cliArg in self.cliArguments) {
        BBPrint(@"\t%@", cliArg);
    }
    BBPrint(@"\n");
    BBPrint(@"--Parsed Global arguments--");
    NSInteger paddingAmount = 2;

    NSInteger longestDataKey = [[self.globalVariables.allKeys
                                            valueForKeyPath: @"@max.length"] integerValue];
    longestDataKey+= paddingAmount;
    NSArray *allStringValues = [self.globalVariables.allValues filteredArrayUsingPredicate:
                                [NSPredicate predicateWithFormat:@"class == %@", [NSString class]]];

    NSInteger longestDataValue = [[allStringValues valueForKeyPath: @"@max.length"] integerValue];
    longestDataValue+= paddingAmount;
    longestDataValue = MAX(longestDataValue,longestDataKey);

    NSMutableString *header = [NSMutableString new];
    NSString *keyLineSeperator = [@"" stringByPaddingToLength:longestDataKey
                                                withString:@"="
                                           startingAtIndex:0];
    NSString *valLineSeperator = [@"" stringByPaddingToLength:longestDataValue
                                                   withString:@"="
                                              startingAtIndex:0];
    [header appendString:keyLineSeperator];
    [header appendString:valLineSeperator];
    [header appendString:@"\n"];

    [header appendString:[@"= dataKey" stringByPaddingToLength:longestDataKey
                                                  withString:@" "
                                             startingAtIndex:0]];
    [header appendString:@":"];
    NSString *dataValueNameString = @"dataValue =";
    NSString *padding = [@"" stringByPaddingToLength:longestDataValue - dataValueNameString.length - 1
                                                                                     withString:@" "
                                     startingAtIndex:0];

    NSString *dataValueString = [NSString stringWithFormat:@"%@%@", padding, dataValueNameString];
    [header appendString:dataValueString];
    [header appendString:@"\n"];
    [header appendString:keyLineSeperator];
    [header appendString:valLineSeperator];

    BBPrint(@"%@", header);

    for (NSString *globalVariable in self.globalVariables) {
        id value = self.globalVariables[globalVariable];
        NSString *stringValue = @"";
        if ([value isKindOfClass:[NSNumber class]]) {
            stringValue = [value boolValue]?@"Yes":@"No";
        }
        else if ([value isKindOfClass:[NSString class]]){
            stringValue = value;
        }
        NSString *dataKey = [globalVariable stringByPaddingToLength:longestDataKey
                                                         withString:@" "
                                                    startingAtIndex:0];

        NSInteger valuePaddingLength = longestDataValue - [stringValue length] - 1;
        NSString *valuePadding = [@"" stringByPaddingToLength:valuePaddingLength
                                                   withString:@" "
                                              startingAtIndex:0];

        NSString *dataValue = [NSString stringWithFormat:@"%@%@", valuePadding, stringValue];

        BBPrint(@"%@:%@", dataKey , dataValue);
    }
    BBPrint(@"\n");

}

- (void) reportDuplicateArgument:(BBTArgument *)argument withValue:(NSString *)value{
    BBPrint(@"Duplicate argument detected trying to set %@.", argument.name);
    NSString *currentValue = self.globalVariables[argument.dataKey];
    BBPrint(@"The old value '%@' would be replaced with '%@'",currentValue, value);
}

- (void) exitWithError{
    exit(EXIT_FAILURE);
}

@end
