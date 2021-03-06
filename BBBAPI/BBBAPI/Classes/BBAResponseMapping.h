//
//  BBAResponseFactory.h
//  BBANetworking
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 29/07/2014.
 

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
