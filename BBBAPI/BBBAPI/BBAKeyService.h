//
//  BBAKeyService.h
//  BBAAPI
//
//  Created by Tomek Kuźma on 30/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBAUserDetails;

@interface BBAKeyService : NSObject
- (void) getKeyForURL:(NSURL *)keyURL
              forUser:(BBAUserDetails *)user
           completion:(void (^)(NSString *key, NSError *error))completion;
@end
