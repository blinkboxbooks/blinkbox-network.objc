//
//  BBALinkItem.h
//  BBBAPI
//
//  Created by Owen Worley on 09/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FEMObjectMapping;

@interface BBALinkItem : NSObject

@property (nonatomic, copy) NSString *rel;
@property (nonatomic, copy) NSString *href;
@property (nonatomic, copy) NSString *targetGuid;
@property (nonatomic, copy) NSString *title;

+ (FEMObjectMapping *) linkItemMapping;
@end
