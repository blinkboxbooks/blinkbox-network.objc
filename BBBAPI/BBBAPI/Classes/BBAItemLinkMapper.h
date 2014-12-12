//
//  BBAItemLinkMapper.h
//  BBBAPI
//
//  Created by Tomek Kuźma on 12/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BBAItemLink;
@interface BBAItemLinkMapper : NSObject
- (BBAItemLink *) linkFromDictionary:(NSDictionary *)dictionary;
@end
