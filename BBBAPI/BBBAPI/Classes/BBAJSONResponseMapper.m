//
//  BBAJSONResponseMapper.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 31/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAJSONResponseMapper.h"

@implementation BBAJSONResponseMapper
- (id)responseFromData:(NSData *)data response:(NSURLResponse *)response error:(NSError *__autoreleasing *)error{
    
    id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    
    return responseJSON;

}
@end
