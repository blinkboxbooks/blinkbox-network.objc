//
//  BBBClientDetails.h
//  BBBAPI
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBBClientDetails : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *brand;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *operatingSystem;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *secret;
@end
