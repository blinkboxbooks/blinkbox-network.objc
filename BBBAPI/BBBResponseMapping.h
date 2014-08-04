//
//  BBBResponseFactory.h
//  BBBNetworking
//
//  Created by Tomek Kuźma on 29/07/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const BBBResponseMappingErrorDomain;

typedef NS_ENUM(NSInteger, BBBResponseMappingError) {
    BBBResponseMappingErrorUnreadableData = 610,
    BBBResponseMappingErrorUnexpectedDataFormat = 611
};

@protocol BBBResponseMapping <NSObject>
- (id) responseFromData:(NSData *)data response:(NSURLResponse *)response error:(NSError **)error;
@end
