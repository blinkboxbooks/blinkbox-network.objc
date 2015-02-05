//
//  BBARequest.m
//  BBANetworking
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBARequest.h"

@interface BBARequest ()

@property (nonatomic, assign) NSTimeInterval retryDelay;
@property (nonatomic, strong) NSDate *lastRequestDate;
@property (nonatomic, assign) NSUInteger attemptsCount;
@property (nonatomic, assign) NSUInteger maxAttemptsCount;

@end

@implementation BBARequest

+ (BBARequest *) requestWithURLRequest:(NSURLRequest *)request {
    BBARequest *bbaRequest = [BBARequest new];
    bbaRequest.URLRequest = request;
    
    return bbaRequest;
}

- (id) copyWithZone:(NSZone *)zone{
    BBARequest *request = [BBARequest new];
    request.URLRequest = [self.URLRequest copyWithZone:zone];
    request.retryDelay = self.retryDelay;
    request.lastRequestDate = [self.lastRequestDate copyWithZone:zone];
    request.attemptsCount = self.attemptsCount;
    request.maxAttemptsCount = self.maxAttemptsCount;
    return request;
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
