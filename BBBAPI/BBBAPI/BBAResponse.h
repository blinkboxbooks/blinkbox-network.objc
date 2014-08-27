//
//  BBAResponse.h
//  BBANetworking
//
//  Created by Tomek Kuźma on 24/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBAResponse : NSObject

@property (nonatomic, strong) NSData *data;

@property (nonatomic, assign) NSInteger statusCode;

@property (nonatomic, strong) NSData *serverDare;

@end
