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
@property (nonatomic, assign) Class dataClass;
@end

@implementation BBBToolOperationArgument
- (instancetype) initWithName:(NSString *)name
                         help:(NSString *)help
                      dataKey:(NSString *)dataKey
                    dataClass:(Class)dataClass{
    self = [super init];
    if (self) {
        self.name = name;
        self.help = help;
        self.dataKey = dataKey;
        self.dataClass = dataClass;
    }
    return self;
}
- (instancetype) initWithName:(NSString *)name help:(NSString *)help{
    self = [self initWithName:name help:help dataKey:nil dataClass:nil];
    return self;
}
@end
