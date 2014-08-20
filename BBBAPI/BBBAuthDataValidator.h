//
//  BBBAuthDataValidator.h
//  BBBAPI
//
//  Created by Owen Worley on 12/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BBBAuthData;
@interface BBBAuthDataValidator : NSObject

- (BOOL) isValid:(BBBAuthData *)data forResponse:(NSURLResponse *)response;

@end