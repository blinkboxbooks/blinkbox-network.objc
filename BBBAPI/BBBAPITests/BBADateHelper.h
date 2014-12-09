//
//  BBADateHelper.h
//  BBBAPI
//
//  Created by Owen Worley on 09/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBADateHelper : NSObject
+ (NSString *) dateFormat;
+ (NSDate *)dateFromString:(NSString *)string;
@end
