//
//  BBTArgument.h
//  BBBTool
//
//  Created by Owen Worley on 18/08/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBTArgument : NSObject
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *help;
@property (nonatomic, copy) NSString *dataKey;
@property (nonatomic, assign, readonly) Class dataClass;


- (instancetype) initWithName:(NSString *)name help:(NSString *)help;
- (instancetype) initWithName:(NSString *)name
                         help:(NSString *)help
                      dataKey:(NSString *)dataKey
                    dataClass:(Class)dataClass;
@end
