//
//  BBAClientDetails.m
//  BBAAPI
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAClientDetails.h"

@implementation BBAClientDetails

- (NSString *) description{
    return [NSString stringWithFormat:@"%@, \rname: %@, \rbrand: %@, \rmodel: %@, \rOS: %@, \rid: %@, \ruri: %@, \rsecret: %@, \rlast used date: %@",
            [super description],
            self.name,
            self.brand,
            self.model,
            self.operatingSystem,
            self.identifier,
            self.uri,
            self.secret,
            self.lastUsedDate];
}

@end
