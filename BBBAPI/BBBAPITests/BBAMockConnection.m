//
//  BBAMockConnection.m
//  BBAAPI
//
//  Created by Tomek Kuźma on 04/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAMockConnection.h"

@interface BBAMockConnection ()

@end

@implementation BBAMockConnection


- (void) perform:(BBAHTTPMethod)method completion:(void (^)(id data, NSError *))completion{
    [self perform:method forUser:nil completion:completion];
}

- (void) perform:(BBAHTTPMethod)method forUser:(BBAUserDetails *)user completion:(void (^)(id, NSError *))completion{
    self.wasPerformCompletionCalled = YES;
    self.passedUserDetails = user;
    self.passedHTTPMethod = method;
    
    completion(self.objectToReturn, self.errorToReturn);
    
}


- (void) addParameterWithKey:(NSString *)key value:(NSString *)value{
    self.passedParameters[key] = value;
}

- (void) addParameterWithKey:(NSString *)key arrayValue:(NSArray *)value{
    self.passedArrayParameters[key] = value;
}

- (void) addHeaderFieldWithKey:(NSString *)key value:(NSString *)value{
    self.passedHeaders[key] = value;
}


- (NSMutableDictionary *) passedParameters{
    if (_passedParameters == nil) {
        _passedParameters = [NSMutableDictionary new];
    }
    return _passedParameters;
}

- (NSMutableDictionary *) passedArrayParameters{
    if (_passedArrayParameters == nil) {
        _passedArrayParameters = [NSMutableDictionary new];
    }
    return _passedArrayParameters;
}

- (NSMutableDictionary *) passedHeaders{
    if (_passedHeaders == nil) {
        _passedHeaders = [NSMutableDictionary new];
    }
    return _passedHeaders;
}


@end
