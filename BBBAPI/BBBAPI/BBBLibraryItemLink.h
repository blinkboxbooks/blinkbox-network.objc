//
//  BBBLibraryItemLink.h
//  BBBAPI
//
//  Created by Tomek Kuźma on 31/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBBLibraryItemLink : NSObject
@property (nonatomic, copy) NSString *relationship;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *title;
@end