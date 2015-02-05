//
//  BBAClientDetails.h
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBAClientDetails : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *brand;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *operatingSystem;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *uri;
@property (nonatomic, copy) NSString *secret;
@property (nonatomic, copy) NSString *lastUsedDate;
@end
