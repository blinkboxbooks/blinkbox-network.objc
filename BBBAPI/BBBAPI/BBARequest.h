//
//  BBARequest.h
//  BBANetworking
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBARequest : NSObject <NSCopying>
@property (nonatomic, copy, readonly) NSURLRequest *URLRequest;
@property (nonatomic, assign, readonly) NSTimeInterval retryDelay;
@property (nonatomic, strong, readonly) NSDate *lastRequestDate;
@property (nonatomic, assign, readonly) NSUInteger attemptsCount;
@property (nonatomic, assign, readonly) NSUInteger maxAttemptsCount;
+ (BBARequest *)requestWithURLRequest:(NSURLRequest *)request;
@end
