//
//  BBARequest.h
//  BBANetworking
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 29/07/2014.
 

#import <Foundation/Foundation.h>

@interface BBARequest : NSObject <NSCopying>
@property (nonatomic, copy) NSURLRequest *URLRequest;
@property (nonatomic, assign, readonly) NSTimeInterval retryDelay;
@property (nonatomic, strong, readonly) NSDate *lastRequestDate;
@property (nonatomic, assign, readonly) NSUInteger attemptsCount;
@property (nonatomic, assign, readonly) NSUInteger maxAttemptsCount;
+ (BBARequest *)requestWithURLRequest:(NSURLRequest *)request;
@end
