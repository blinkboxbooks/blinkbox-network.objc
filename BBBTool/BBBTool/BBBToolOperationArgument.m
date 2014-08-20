//
//  BBBToolOperationArgument.m
//  BBBTool
//
//  Created by Owen Worley on 18/08/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import "BBBToolOperationArgument.h"

@interface BBBToolOperationArgument ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *help;
@end

@implementation BBBToolOperationArgument
- (instancetype) initWithName:(NSString *)name help:(NSString *)help{
    self = [super init];
    if (self) {
        self.name = name;
        self.help = help;
    }
    return self;
}
@end
