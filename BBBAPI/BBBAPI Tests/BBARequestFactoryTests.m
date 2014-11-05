//
//  BBARequestFactoryTests.m
//  BBBAPI
//
//  Created by Owen Worley on 29/10/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BBARequestFactory.h"
#import "BBARequest.h"

@interface BBARequestFactoryTests : XCTestCase{
    BBARequestFactory *requestFactory;
    NSURL *validURL;
}

@end

@implementation BBARequestFactoryTests

- (void) setUp{
    [super setUp];
    requestFactory = [BBARequestFactory new];
    validURL = [NSURL URLWithString:@"https://blinkbox.com/test"];
}

- (void) tearDown{
    requestFactory = nil;
    validURL= nil;
    [super tearDown];
}

- (void) testInit{
    XCTAssertNotNil(requestFactory);
}

- (void) testRequestWithNilURLThrows{
    XCTAssertThrows([requestFactory requestWith:nil
                                     parameters:@{}
                                        headers:@{}
                                         method:BBAHTTPMethodGET
                                    contentType:BBAContentTypeJSON
                                          error:nil]);
}

- (void) testRequestFactoryReturnsErrorForUnexpectedContentType{
    NSError *error;

    BBARequest *request;
    request = [requestFactory requestWith:validURL
                               parameters:nil
                                  headers:nil
                                   method:BBAHTTPMethodPOST
                              contentType:BBAContentTypeUnknown
                                    error:&error];
    XCTAssertNil(request);
    XCTAssertEqualObjects(error.domain, BBARequestFactoryDomain);
    XCTAssertEqual(error.code, BBARequestFactoryErrorCouldNotCreateRequest);
}

- (void) testRequestFactorySetsURLRequestWithCorrectURL{
    BBARequest *request;
    request = [requestFactory requestWith:validURL
                               parameters:@{}
                                  headers:@{}
                                   method:BBAHTTPMethodGET
                              contentType:BBAContentTypeJSON
                                    error:nil];

    XCTAssertEqualObjects(request.URLRequest.URL, validURL);
}

- (void) testRequestFactorySetsHTTPMethodForGET{
    BBARequest *request;
    request = [requestFactory requestWith:validURL
                               parameters:@{}
                                  headers:@{}
                                   method:BBAHTTPMethodGET
                              contentType:BBAContentTypeJSON
                                    error:nil];

    XCTAssertEqualObjects(request.URLRequest.HTTPMethod, @"GET");
}

- (void) testRequestFactorySetsHTTPMethodForPOST{
    BBARequest *request;
    request = [requestFactory requestWith:validURL
                               parameters:@{}
                                  headers:@{}
                                   method:BBAHTTPMethodPOST
                              contentType:BBAContentTypeJSON
                                    error:nil];

    XCTAssertEqualObjects(request.URLRequest.HTTPMethod, @"POST");
}

- (void) testRequestFactorySetsHTTPMethodForPUT{
    BBARequest *request;
    request = [requestFactory requestWith:validURL
                               parameters:@{}
                                  headers:@{}
                                   method:BBAHTTPMethodPUT
                              contentType:BBAContentTypeJSON
                                    error:nil];

    XCTAssertEqualObjects(request.URLRequest.HTTPMethod, @"PUT");
}

- (void) testRequestFactorySetsHTTPMethodForDELETE{
    BBARequest *request;
    request = [requestFactory requestWith:validURL
                               parameters:@{}
                                  headers:@{}
                                   method:BBAHTTPMethodDELETE
                              contentType:BBAContentTypeJSON
                                    error:nil];

    XCTAssertEqualObjects(request.URLRequest.HTTPMethod, @"DELETE");
}

- (void) testRequestFactoryAppendsParamatersToRequestForGETRequests{
    BBARequest *request;
    request = [requestFactory requestWith:validURL
                               parameters:@{@"key1" : @"value1", @"key2" : @"value2" }
                                  headers:@{}
                                   method:BBAHTTPMethodGET
                              contentType:BBAContentTypeUnknown
                                    error:nil];

    NSString *resultURLString = [request.URLRequest.URL absoluteString];

    XCTAssertTrue([resultURLString rangeOfString:@"key1=value1"].location != NSNotFound);
    XCTAssertTrue([resultURLString rangeOfString:@"key2=value2"].location != NSNotFound);

}

- (void) testRequestFactoryAddsParamatersToBodyForPOSTRequests{
    BBARequest *request;
    request = [requestFactory requestWith:validURL
                               parameters:@{@"key1" : @"value1", @"key2" : @"value2" }
                                  headers:@{}
                                   method:BBAHTTPMethodPOST
                              contentType:BBAContentTypeJSON
                                    error:nil];
    NSData *expectedData = [@"{\"key1\":\"value1\",\"key2\":\"value2\"}"
                            dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(expectedData, request.URLRequest.HTTPBody);

}

- (void) testRequestFactoryAddsParamatersToBodyForDELETERequests{
    BBARequest *request;
    request = [requestFactory requestWith:validURL
                               parameters:@{@"key1" : @"value1", @"key2" : @"value2" }
                                  headers:@{}
                                   method:BBAHTTPMethodDELETE
                              contentType:BBAContentTypeJSON
                                    error:nil];

    NSData *expectedData = [@"{\"key1\":\"value1\",\"key2\":\"value2\"}"
                            dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(expectedData, request.URLRequest.HTTPBody);
}

- (void) testRequestFactoryAddsParamatersToBodyForPUTRequests{
    BBARequest *request;
    request = [requestFactory requestWith:validURL
                               parameters:@{@"key1" : @"value1", @"key2" : @"value2" }
                                  headers:@{}
                                   method:BBAHTTPMethodPUT
                              contentType:BBAContentTypeJSON
                                    error:nil];

    NSData *expectedData = [@"{\"key1\":\"value1\",\"key2\":\"value2\"}"
                            dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(expectedData, request.URLRequest.HTTPBody);
}

- (void) testRequestFactoryAddsHeadersToRequests{
    BBARequest *request;
    request = [requestFactory requestWith:validURL
                               parameters:@{}
                                  headers:@{@"headerkey" : @"headervalue"}
                                   method:BBAHTTPMethodPUT
                              contentType:BBAContentTypeJSON
                                    error:nil];

    XCTAssertEqualObjects(request.URLRequest.allHTTPHeaderFields[@"headerkey"], @"headervalue");

}

- (void) testRequestFactoryAppendsArrayValuesInParamatersToRequestForGETRequests{
    BBARequest *request;
    request = [requestFactory requestWith:validURL
                               parameters:@{@"id" : @[@"one",@"two"]}
                                  headers:@{}
                                   method:BBAHTTPMethodGET
                              contentType:BBAContentTypeUnknown
                                    error:nil];
    NSURL *expectedURL = [NSURL URLWithString:@"?id=one&id=two"relativeToURL:validURL];
    XCTAssertEqualObjects([request.URLRequest.URL absoluteString],
                          [expectedURL absoluteString]);
}

- (void) testRequestFactoryAssertsWithInvalidHTTPMethod{
    XCTAssertThrows([requestFactory requestWith:validURL
                                     parameters:@{}
                                        headers:@{}
                                         method:(BBAHTTPMethod)666
                                    contentType:BBAContentTypeJSON
                                          error:nil]);
}
@end
