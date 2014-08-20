//
//  BBBToolOperation.m
//  BBBTool
//
//  Created by Owen Worley on 18/08/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import "BBBToolOperation.h"
#import "BBBToolOperationArgument.h"


@interface BBBToolOperation ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *help;
@property (nonatomic, copy) NSDictionary *arguments;
@property (nonatomic, copy) toolAction action;
@end

@implementation BBBToolOperation
- (instancetype) initWithName:(NSString *)name
                        help:(NSString *)help
                   arguments:(NSArray *)arguments
                      action:(toolAction)action{
    self = [super init];
    if (self) {
        self.name = name;
        self.help = help;
        NSMutableDictionary *operationArguments = [NSMutableDictionary new];
        for (BBBToolOperationArgument *arg in arguments) {
            operationArguments[arg.name] = arg;
        }
        self.arguments = operationArguments;
        self.action = action;
    }
    return self;
}

- (NSString *) help{
    NSMutableString *helpMessage = [_help mutableCopy];
    [helpMessage appendFormat:@"\n\tArguments:"];
    for (BBBToolOperationArgument *argument in [self.arguments allValues]) {
        [helpMessage appendFormat:@"\n\t'%@' - %@", argument.name, argument.help];
    }
    return helpMessage;
}

- (void) performOperationWithArguments:(NSArray *)arguments{
    if (self.action) {
        self.action(arguments);
    }
    else {
        NSPrint(@"No operation to perform");
    }
}

- (NSArray *)trimmedArguments:(NSArray *)arguments{
    NSMutableArray *trimmedArguments = [NSMutableArray new];

    for (NSString *arg in arguments) {
        NSString *trimmed = [arg substringFromIndex:[arg rangeOfString:@":"].location+1];
        [trimmedArguments addObject:trimmed];
    }
    return trimmedArguments;
}

- (BOOL) canPerformOperationWithArguments:(NSArray *)arguments{
    if ([arguments count] != [self.arguments count]) {
        return NO;
    }

    for (NSString *argument in arguments) {
        NSRange rangeOfColon = [argument rangeOfString:@":"];
        if (rangeOfColon.location == NSNotFound) {
            NSPrint(@"%@ is a required argument for %@", argument, self.name);
            return NO;
        }

        NSString *argumentName = [argument substringToIndex:rangeOfColon.location];
        BBBToolOperationArgument *toolArgument = self.arguments[argumentName];
        if (toolArgument == nil) {
            NSPrint(@"Unrecognised argument '%@' for %@", argumentName, self.name);
            return NO;
        }
    }
    return YES;
}
@end
