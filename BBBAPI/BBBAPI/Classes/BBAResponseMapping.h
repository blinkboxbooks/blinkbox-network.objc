//
//  BBAResponseFactory.h
//  BBANetworking
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const BBAResponseMappingErrorDomain;

typedef NS_ENUM(NSInteger, BBAResponseMappingError) {
    BBAResponseMappingErrorUnreadableData = 610,
    BBAResponseMappingErrorUnexpectedDataFormat = 611,
    BBAResponseMappingErrorNotFound = 612
};

@protocol BBAResponseMapping <NSObject>
- (id) responseFromData:(NSData *)data response:(NSURLResponse *)response error:(NSError **)error;
@end
