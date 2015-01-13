//
//  BBABookItem.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 12/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBABookItem.h"

@implementation BBABookItem
- (NSString *) description{
    
    return [NSString stringWithFormat:@"%@, isbn:%@\rtitle:%@\rsynopsis:%@",
            [super description], self.identifier, self.title, self.synopsis];
}
@end
