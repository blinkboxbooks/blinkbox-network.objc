//
//  BBABookItem.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 12/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBABookItem.h"

/*
 NSString *identifier;
 @property (nonatomic, copy) NSString *guid;
 @property (nonatomic, copy) NSString *title;
 @property (nonatomic, assign) BOOL sampleEligible;
 @property (nonatomic, strong) NSDate *publicationDate;
 @property (nonatomic, copy) NSArray *images;
 @property (nonatomic, copy) NSArray *links;
 @property (nonatomic, copy) NSString *synopsis;
 */

@implementation BBABookItem
- (NSString *) description{
    
    return [NSString stringWithFormat:@"%@, isbn:%@\rtitle:%@\rsynopsis:%@",
            [super description], self.identifier, self.title, self.synopsis];
}
@end
