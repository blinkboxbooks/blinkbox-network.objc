//
//  BBBJSONResponseMapper.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 31/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBJSONResponseMapper.h"

@implementation BBBJSONResponseMapper
- (id)responseFromData:(NSData *)data response:(NSURLResponse *)response error:(NSError *__autoreleasing *)error{
    
    id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    
    return responseJSON;

}
@end
