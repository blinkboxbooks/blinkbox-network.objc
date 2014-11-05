//
//  BBARequest.m
//  BBANetworking
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBARequest.h"

@interface BBARequest ()

@property (nonatomic, copy) NSURLRequest *URLRequest;
@property (nonatomic, assign) NSTimeInterval retryDelay;
@property (nonatomic, strong) NSDate *lastRequestDate;
@property (nonatomic, assign) NSUInteger attemptsCount;
@property (nonatomic, assign) NSUInteger maxAttemptsCount;

@end

@implementation BBARequest

+ (BBARequest *)requestWithURLRequest:(NSURLRequest *)request {
    BBARequest *bbaRequest = [BBARequest new];
    bbaRequest.URLRequest = request;

    return bbaRequest;
}

- (id) copyWithZone:(NSZone *)zone{
#warning IMPLEMENT ME
    return nil;
}

- (NSString *) description{
    return [NSString stringWithFormat:@"%@ request %@, delay:%f, last request :%@, attempts %ld out of %ld",
            [super description],
            self.URLRequest,
            self.retryDelay,
            self.lastRequestDate,
            self.attemptsCount,
            self.maxAttemptsCount];
}

@end
