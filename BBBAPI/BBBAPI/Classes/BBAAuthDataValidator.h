//
//  BBAAuthDataValidator.h
//  BBAAPI
//
//  Created by Owen Worley on 12/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BBAAuthData;
@interface BBAAuthDataValidator : NSObject

- (BOOL) isValid:(BBAAuthData *)data forResponse:(NSURLResponse *)response;

@end