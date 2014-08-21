//
//  BBTOperation.m
//  BBBTool
//
//  Created by Owen Worley on 18/08/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import "BBTOperation.h"
#import "BBTArgument.h"


@interface BBTOperation ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *help;
@property (nonatomic, copy) NSDictionary *arguments;
@property (nonatomic, copy) toolAction action;
@end

@implementation BBTOperation
- (instancetype) initWithName:(NSString *)name
                        help:(NSString *)help
                   arguments:(NSArray *)arguments
                      action:(toolAction)action{
    self = [super init];
    if (self) {
        self.name = name;
        self.help = help;
        NSMutableDictionary *operationArguments = [NSMutableDictionary new];
        for (BBTArgument *arg in arguments) {
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
    for (BBTArgument *argument in [self.arguments allValues]) {
        [helpMessage appendFormat:@"\n\t'%@' - %@", argument.name, argument.help];
    }
    return helpMessage;
}

- (void) performOperationWithArguments:(NSArray *)arguments{
    if (self.action) {
        self.action(arguments);
    }
    else {
        BBPrint(@"No operation to perform");
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

- (NSArray *)tokeniseArgumentParamaters:(NSArray *)argumentParamaters{
    NSMutableArray *tokenisedParamaters = [argumentParamaters mutableCopy];

    for (NSString *argument in argumentParamaters) {

        NSRange rangeOfColon = [argument rangeOfString:@":"];
        //Cant tokenise if there is no value
        if (rangeOfColon.location == NSNotFound) {
            [tokenisedParamaters removeObject:argument];
            continue;
        }

        //Cant tokenise global args.
        NSString *argumentName = [argument substringToIndex:rangeOfColon.location];
        if ([argumentName hasPrefix:@"--"]) {
            [tokenisedParamaters removeObject:argument];
            continue;
        }

        //Cant tokenise, unrecognised paramater name
        BBTArgument *toolArgument = self.arguments[argumentName];
        if (toolArgument == nil) {
            [tokenisedParamaters removeObject:argument];
            continue;
        }

        //If we get here, we can tokenise this paramater so we leave it in the array
    }

    return tokenisedParamaters;
}

- (BOOL) canPerformOperationWithArguments:(NSArray *)arguments{
    if ([arguments count] != [self.arguments count]) {
        return NO;
    }

    NSArray *tokenisedParamaters = [self tokeniseArgumentParamaters:arguments];

    return [tokenisedParamaters count] == self.arguments.count;
}
@end
