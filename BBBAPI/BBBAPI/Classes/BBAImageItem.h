//
//  BBAImageItem.h
//  BBBAPI
//
//  Created by Tomek Kuźma on 12/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Represents image link
 */
@interface BBAImageItem : NSObject


@property (nonatomic, copy) NSString *relative;
/**
 *  URL of the given image
 */
@property (nonatomic, strong) NSURL *url;

@end