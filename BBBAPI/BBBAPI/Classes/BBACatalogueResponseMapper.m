//
//  BBACatalogueResponseMapper.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 11/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBACatalogueResponseMapper.h"

@implementation BBACatalogueResponseMapper
- (id) responseFromData:(NSData *)data
               response:(NSURLResponse *)response
                  error:(NSError **)error{
    id object = [super responseFromData:data response:response error:error];
    
    if (!object) {
        return nil;
    }
    
    
    
    return nil;
}
@end
