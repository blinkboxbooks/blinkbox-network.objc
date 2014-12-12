//
//  BBABooksResponseMapper.h
//  BBBAPI
//
//  Created by Tomek Kuźma on 11/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BBABookItem;

@interface BBABooksMapper : NSObject
- (BBABookItem *)itemFromDictionary:(NSDictionary *)dictionary;
@end


