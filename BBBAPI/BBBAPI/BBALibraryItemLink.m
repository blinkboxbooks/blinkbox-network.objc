//
//  BBALibraryItemLink.m
//  BBAAPI
//
//  Created by Tomek Kuźma on 31/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBALibraryItemLink.h"

@implementation BBALibraryItemLink
/*
 @property (nonatomic, copy) NSString *relationship;
 @property (nonatomic, copy) NSString *address;
 @property (nonatomic, copy) NSString *title;
 */

- (NSString *) description{
    return [NSString stringWithFormat:@"%@ \rtitle: %@\rrelation: %@\raddress: %@",
            [super description],
            self.title,
            self.relationship,
            self.address];
}
@end
