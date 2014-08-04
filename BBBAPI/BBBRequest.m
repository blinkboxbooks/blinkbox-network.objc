//
//  BBBRequest.m
//  BBBNetworking
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBRequest.h"

@interface BBBRequest ()

@property (nonatomic, copy) NSURLRequest *URLRequest;
@property (nonatomic, assign) NSTimeInterval retryDelay;
@property (nonatomic, strong) NSDate *lastRequestDate;
@property (nonatomic, assign) NSUInteger attemptsCount;
@property (nonatomic, assign) NSUInteger maxAttemptsCount;

@end

@implementation BBBRequest
- (id) copyWithZone:(NSZone *)zone{
#warning IMPLEMENT ME
    return nil;
}
@end
