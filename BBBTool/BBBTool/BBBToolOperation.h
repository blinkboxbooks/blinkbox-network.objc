//
//  BBBToolOperation.h
//  BBBTool
//
//  Created by Owen Worley on 18/08/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^toolAction)(NSArray *cliArguments);

@interface BBBToolOperation : NSObject
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *help;
@property (nonatomic, copy, readonly) NSDictionary *arguments;
- (instancetype) initWithName:(NSString *)name
                         help:(NSString *)help
                    arguments:(NSArray *)arguments
                       action:(toolAction)action;
- (void) performOperationWithArguments:(NSArray *)arguments;

- (BOOL) canPerformOperationWithArguments:(NSArray *)array;

- (NSArray *)trimmedArguments:(NSArray *)arguments;
@end
