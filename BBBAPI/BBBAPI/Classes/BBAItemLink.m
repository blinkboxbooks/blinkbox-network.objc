//
//  BBALibraryItemLink.m
//  BBAAPI
//
//  Created by Tomek Kuźma on 31/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAItemLink.h"

@implementation BBAItemLink
/*
 @property (nonatomic, copy) NSString *relationship;
 @property (nonatomic, copy) NSString *address;
 @property (nonatomic, copy) NSString *title;
 */

- (NSString *) description{
    NSString *newLine = @"\n";
    return [NSString stringWithFormat:@"%@ %@title: %@%@relation: %@%@address: %@",
            [super description],
            newLine,
            self.title,
            newLine,
            self.relationship,
            newLine,
            self.address];
}
@end
