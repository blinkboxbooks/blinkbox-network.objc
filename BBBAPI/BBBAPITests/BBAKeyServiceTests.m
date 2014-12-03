//
//  BBAKeyServiceTests.m
//  BBBAPI
//
//  Created by Owen Worley on 27/11/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BBAKeyService.h"
#import "BBAUserDetails.h"
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "BBAConnectionTestsMocks.h"
#import "BBAKeyServiceResponseMapper.h"
#import <OCMock/OCMock.h>
#import "BBAConnection.h"

@interface BBAKeyServiceTests : XCTestCase{
    BBAKeyService *service;
    BBANetworkConfiguration *configuration;
}

@end

@implementation BBAKeyServiceTests

- (void)setUp {
    [super setUp];
    configuration = [BBANetworkConfiguration new];
    service = [BBAKeyService new];
    id<BBAAuthenticator> authenticator = [BBAMockAuthenticator new];
    [configuration setSharedAuthenticator:authenticator];
    [service setValue:configuration forKey:@"configuration"];
}

- (void)tearDown {
    configuration = nil;
    service = nil;
    [OHHTTPStubs removeAllStubs];
    [super tearDown];
}

- (void) testKeyServiceThrowsWithNilUserDetails{
    XCTAssertThrows([service getKeyForURL:[NSURL new]
                                publicKey:@""
                                  forUser:nil
                               completion:^(NSData *key, NSError *error) {

                               }]);
}

- (void) testKeyServiceThrowsWithNilURL{
    XCTAssertThrows([service getKeyForURL:nil
                                publicKey:@""
                                  forUser:[BBAUserDetails new]
                               completion:^(NSData *key, NSError *error) {

                               }]);
}

- (void) testKeyServiceThrowsWithNilPublicKey{
    XCTAssertThrows([service getKeyForURL:[NSURL new]
                                publicKey:nil
                                  forUser:[BBAUserDetails new]
                               completion:^(NSData *key, NSError *error) {

                               }]);
}

- (void) testKeyServiceThrowsWithNilCompletion{
    XCTAssertThrows([service getKeyForURL:[NSURL new]
                                publicKey:@""
                                  forUser:[BBAUserDetails new]
                               completion:nil]);
}

- (id) prepareBBAConnectionMocking{
    id classMock = OCMClassMock([BBAConnection class]);
    OCMStub([classMock alloc]).andReturn(classMock);
    OCMStub([classMock initWithBaseURL:OCMOCK_ANY]).andReturn(classMock);

    return classMock;
}

- (void) testKeyServiceSetsKeyParamaterOnRequest{


    id classMock = [self prepareBBAConnectionMocking];

    NSURL *keyURL = [NSURL URLWithString:@""];
    NSString *publicKey = @"test";
    [service getKeyForURL:keyURL
                publicKey:publicKey
                  forUser:[BBAUserDetails new]
               completion:^(NSData *key, NSError *error) {

               }];

    OCMVerify([classMock addParameterWithKey:[OCMArg isEqual:@"key"] value:[OCMArg isEqual:publicKey]]);
    [classMock stopMocking];
}

- (void) testKeyServiceReturnsKeyWhenServerReturnsSuccess{

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"keys.blinkboxbooks.com"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSString* fixture = OHPathForFileInBundle(@"BBAKeyServiceMock_SuccessResponse.json",nil);
        return [OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                statusCode:201
                                                   headers:@{@"Content-Type":@"text/json"}];
    }];

    NSURL *URL;
    NSString *base64EncodedPublicKey;
    base64EncodedPublicKey = @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwAVlnWSYE6nsCvwIUwiQjNCdtlrvIfeeJM0FTuywWrabteOwO5Veyu";
    URL = [NSURL URLWithString:@"https://keys.blinkboxbooks.com/9780/733/632/297/57a057fbd401c337bf05cd323a69a554.epub.9780733632297.key"];
    BBAUserDetails *userDetails;
    userDetails = [BBAUserDetails new];
    NSData *expectedKey;

    expectedKey = [@"rbYKjzkSmtJnWEWFxTFK0jrXVxdgZYqTq5T/fxGL77F7fJQXlOe4iie+eWTz"
                   "7u9sprYSGPyw6qqB5NSzcXoZ5liUlczcGCFZ6DCOdpKMn3Xz4bc29H1tLbN+"
                   "om/0K0pab/LjK6hzHC3kSUpZiUayxUB8vVpgBayDmCbmSllaob8DtypHZcPg"
                   "KwTnZGBrCRnB9b8oYqtn5otfkpktj/X6elJaIb0zhdYWvU1FKY0RG2OCl6Ug"
                   "gL7yzqN1vFEZgnSzf5pFkMc1r1kERHFqMoDwu81qpvvYSXhKKx9ZvBUH7cvi"
                   "MBy1sV3zC0q3oRG9gYrWgMTfjni2D1BlRaYm62u4Yg==" dataUsingEncoding:NSUTF8StringEncoding];



    __block BOOL serviceReturned = NO;
    BBA_PREPARE_SEMAPHORE();
    [service getKeyForURL:URL
                publicKey:base64EncodedPublicKey
                  forUser:userDetails
               completion:^(NSData *key, NSError *error) {
                   XCTAssertEqualObjects(key, expectedKey);
                   XCTAssertNil(error);
                   serviceReturned = YES;
                   BBA_SIGNAL_SEMAPHORE();
               }];
    BBA_WAIT_FOR_SEMAPHORE();
    XCTAssertTrue(serviceReturned);
}

- (void) testKeyServiceReturnsErrorWhenServerReturnsNotAuthedError{
    NSString *keyAddress = @"https://keys.blinkboxbooks.com/9781/451/658/866/6758f3926dec47bffb4df480dd1fd9dd.epub.9781451658866.key";
    NSURL *URL;
    NSString *base64EncodedPublicKey;
    base64EncodedPublicKey = @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwAVlnWSYE6nsCvwIUwiQjNCdtlrvIfeeJM0FTuywWrabteOwO5Veyu";
    URL = [NSURL URLWithString:keyAddress];
    BBAUserDetails *userDetails;
    userDetails = [BBAUserDetails new];

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"keys.blinkboxbooks.com"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:nil
                                                statusCode:401
                                                   headers:@{@"Content-Type":@"text/json"}];
    }];

    __block BOOL serviceReturned = NO;
    BBA_PREPARE_SEMAPHORE();
    [service getKeyForURL:URL
                publicKey:base64EncodedPublicKey
                  forUser:userDetails
               completion:^(NSData *key, NSError *error) {
                   XCTAssertNil(key);
                   XCTAssertNotNil(error);
                   XCTAssertEqualObjects(error.domain, BBAKeyServiceResponseMapperErrorDomain);
                   XCTAssertEqual(error.code, BBAKeyServiceResponseMapperErrorNotAuthorised);
                   serviceReturned = YES;
                   BBA_SIGNAL_SEMAPHORE();
               }];
    BBA_WAIT_FOR_SEMAPHORE();
    XCTAssertTrue(serviceReturned);
}

- (void) testKeyServiceReturnsErrorWhenServerReturnsNotAllowedKeyError{
    NSString *keyAddress = @"https://keys.blinkboxbooks.com/9781/451/658/866/6758f3926dec47bffb4df480dd1fd9dd.epub.9781451658876.key";
    NSURL *URL;
    NSString *base64EncodedPublicKey;
    base64EncodedPublicKey = @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwAVlnWSYE6nsCvwIUwiQjNCdtlrvIfeeJM0FTuywWrabteOwO5Veyu";
    URL = [NSURL URLWithString:keyAddress];
    BBAUserDetails *userDetails;
    userDetails = [BBAUserDetails new];

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"keys.blinkboxbooks.com"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:nil
                                                statusCode:403
                                                   headers:@{@"Content-Type":@"text/json"}];
    }];

    __block BOOL serviceReturned = NO;
    BBA_PREPARE_SEMAPHORE();
    [service getKeyForURL:URL
                publicKey:base64EncodedPublicKey
                  forUser:userDetails
               completion:^(NSData *key, NSError *error) {
                   XCTAssertNil(key);
                   XCTAssertNotNil(error);
                   XCTAssertEqualObjects(error.domain, BBAKeyServiceResponseMapperErrorDomain);
                   XCTAssertEqual(error.code, BBAKeyServiceResponseMapperErrorNotAllowed);
                   serviceReturned = YES;
                   BBA_SIGNAL_SEMAPHORE();
               }];

    BBA_WAIT_FOR_SEMAPHORE();
    XCTAssertTrue(serviceReturned);
}

- (void) testKeyServiceReturnsErrorWhenServerReturnsKeyLimitExceeded{

    NSString *keyAddress = @"https://keys.blinkboxbooks.com/9781/451/658/866/6758f3926dec47bffb4df480dd1fd9dd.epub.9781451658860.key";
    NSURL *URL;
    NSString *base64EncodedPublicKey;
    base64EncodedPublicKey = @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwAVlnWSYE6nsCvwIUwiQjNCdtlrvIfeeJM0FTuywWrabteOwO5Veyu";
    URL = [NSURL URLWithString:keyAddress];
    BBAUserDetails *userDetails;
    userDetails = [BBAUserDetails new];

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"keys.blinkboxbooks.com"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:nil
                                                statusCode:409
                                                   headers:@{@"Content-Type":@"text/json"}];
    }];

    __block BOOL serviceReturned = NO;
    BBA_PREPARE_SEMAPHORE();
    [service getKeyForURL:URL
                publicKey:base64EncodedPublicKey
                  forUser:userDetails
               completion:^(NSData *key, NSError *error) {
                   XCTAssertNil(key);
                   XCTAssertNotNil(error);
                   XCTAssertEqualObjects(error.domain, BBAKeyServiceResponseMapperErrorDomain);
                   XCTAssertEqual(error.code, BBAKeyServiceResponseMapperErrorKeyLimitExceeded);
                   serviceReturned = YES;
                   BBA_SIGNAL_SEMAPHORE();
               }];
    BBA_WAIT_FOR_SEMAPHORE();
    XCTAssertTrue(serviceReturned);
}

- (void) testKeyServiceReturnsErrorWhenServerReturnsKeyNotFoundError{

    NSString *keyAddress = @"https://keys.blinkboxbooks.com/9781/451/658/866/6758f3926dec47bffb4df480dd1fd9dd.epub.9781451658860.key";
    NSURL *URL;
    NSString *base64EncodedPublicKey;
    base64EncodedPublicKey = @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwAVlnWSYE6nsCvwIUwiQjNCdtlrvIfeeJM0FTuywWrabteOwO5Veyu";
    URL = [NSURL URLWithString:keyAddress];
    BBAUserDetails *userDetails;
    userDetails = [BBAUserDetails new];

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"keys.blinkboxbooks.com"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:nil
                                                statusCode:404
                                                   headers:@{@"Content-Type":@"text/json"}];
    }];

    __block BOOL serviceReturned = NO;
    BBA_PREPARE_SEMAPHORE();
    [service getKeyForURL:URL
                publicKey:base64EncodedPublicKey
                  forUser:userDetails
               completion:^(NSData *key, NSError *error) {
                   XCTAssertNil(key);
                   XCTAssertNotNil(error);
                   XCTAssertEqualObjects(error.domain, BBAKeyServiceResponseMapperErrorDomain);
                   XCTAssertEqual(error.code, BBAKeyServiceResponseMapperErrorNotFound);
                   serviceReturned = YES;
                   BBA_SIGNAL_SEMAPHORE();
               }];
    BBA_WAIT_FOR_SEMAPHORE();
    XCTAssertTrue(serviceReturned);
}

@end
