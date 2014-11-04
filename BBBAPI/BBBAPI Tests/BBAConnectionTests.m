//
//  BBAConnectionTests.m
//  BBAAPI
//
//  Created by Tomek Kuźma on 13/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAConnection.h"
#import "BBATestMacros.h"
#import "BBAAPIErrors.h"
#import "BBAConnectionTestsMocks.h"
#import "BBASwizzlingHelper.h"
#import "BBARequest.h"

@interface BBAConnection (Tests)
@property (nonatomic, strong) NSURLSession *session;
@end


extern NSString * BBANSStringFromBBAContentType(BBAContentType type);

@interface BBAConnectionTests : XCTestCase{
    BBAConnection *connection;
    BBAMockAuthenticator *authenticator;
    BBAMockNetworkConfiguration *configuration;
    BBAMockRequestFactory *factory;
    BBAMockURLSessionDataTask *task;
    BBAMockURLSession *session;
    BBAMockResponseMapper *responseMapper;
    IMP oldImplementation;
    id (^block)(id);
}

@end

@implementation BBAConnectionTests

#pragma mark - Setup/Teardown

- (void) setUp{
    [super setUp];
    
    connection = [[BBAConnection alloc] initWithBaseURL:[self validBaseURL]];
    authenticator = [BBAMockAuthenticator new];
    configuration = [BBAMockNetworkConfiguration new];
    connection.authenticator = authenticator;
    factory = [BBAMockRequestFactory new];
    connection.requestFactory = factory;
    session = [BBAMockURLSession new];
    task = [BBAMockURLSessionDataTask new];
    responseMapper = [BBAMockResponseMapper new];
    connection.responseMapper = responseMapper;
    
    __weak typeof(configuration) wconfiguration = configuration;
    block = ^id(id o){
        return wconfiguration;
    };
    
    Class c = [BBANetworkConfiguration class];
    c = object_getClass((id)c);
    SEL selector = @selector(defaultConfiguration);
    Method originalMethod = class_getClassMethod(c, selector);
    IMP newImplementation = imp_implementationWithBlock(block);
    oldImplementation = method_setImplementation(originalMethod, newImplementation);
    
}

- (void) tearDown{
    
    Class c = [BBANetworkConfiguration class];
    c = object_getClass((id)c);
    SEL selector = @selector(defaultConfiguration);
    Method originalMethod = class_getInstanceMethod(c,selector);
    class_replaceMethod(c, selector, oldImplementation, method_getTypeEncoding(originalMethod));
    block = nil;
    connection = nil;
    authenticator = nil;
    factory = nil;
    session = nil;
    task = nil;
    responseMapper = nil;
    [super tearDown];
}

#pragma mark - Helpers

- (NSURL *) validBaseURL{
    return [NSURL URLWithString:@"http://www.blinkbox.com"];
}

#pragma mark - Tests

- (void) testContentTypeStringMappingFunctionWorkForProperTypes{
    XCTAssertEqualObjects(BBANSStringFromBBAContentType(BBAContentTypeJSON),
                          @"application/vnd.blinkboxbooks.data.v1+json",
                          @"JSON content type name should be equal");
    XCTAssertEqualObjects(BBANSStringFromBBAContentType(BBAContentTypeURLEncodedForm),
                          @"application/x-www-form-urlencoded",
                          @"JSON content type name should be equal");
}

- (void) testContentTypeStringMappingFunctionThrowsForUnknownType{
    XCTAssertThrows(BBANSStringFromBBAContentType(-12), @"should throw on wrong encoding type");
}


- (void) testInitWithBaseURLReturnsNotNil{
    NSURL *url = [self validBaseURL];
    XCTAssertNotNil([[BBAConnection alloc] initWithBaseURL:url]);
}

- (void) testInitWithDomainReturnsNotNil{
    XCTAssertNotNil([[BBAConnection alloc] initWithDomain:BBAAPIDomainREST relativeURL:@"books"]);
}

- (void) testInitWithNilBaseURLThrows{
    XCTAssertThrows([[BBAConnection alloc] initWithBaseURL:nil]);
}

- (void) testInitWithNilBaseURLReturnsNil{
    BBA_DISABLE_ASSERTIONS();
    XCTAssertNil([[BBAConnection alloc] initWithBaseURL:nil]);
    BBA_ENABLE_ASSERTIONS();
}

- (void) testInitWithDomainAsksNetworkConfiguratorForBaseURL{
    id c = [[BBAConnection alloc] initWithDomain:BBAAPIDomainREST relativeURL:@"books"];
    c = nil;
    XCTAssertEqual(configuration.passedDomain, BBAAPIDomainREST);
}


- (void) testAddArrayParameterThrowsWhenKeyIsNil{
    XCTAssertThrows([connection addParameterWithKey:nil arrayValue:@[]]);
}

- (void) testAddArrayParameterThrowsWhenArrayIsNil{
    XCTAssertThrows([connection addParameterWithKey:@"key" arrayValue:nil]);
}

- (void) testAddParameterThrowsWithNilKey{
    XCTAssertThrows([connection addParameterWithKey:nil value:@"value"]);
}

- (void) testAddParameterThrowsWithNilValue{
    XCTAssertThrows([connection addParameterWithKey:@"key" value:nil]);
}

- (void) testAddParameterThrowsOnNotStringKey{
    XCTAssertThrows([connection addParameterWithKey:(NSString *)@0 value:@"value"]);
}

- (void) testAddParameterThrowsOnNotStringValue{
    XCTAssertThrows([connection addParameterWithKey:@"key" value:(NSString *)@0]);
}

- (void) testSetParameterThrowsWithNilKey{
    XCTAssertThrows([connection setParameterValue:@"value" withKey:nil]);
}

- (void) testSetParameterWithValueAddsItToRequestParameters{
    [connection setParameterValue:@"value" withKey:@"key"];
    factory.requestToReturn = [BBARequest new];
    [connection perform:(BBAHTTPMethodGET)
             completion:^(id response, NSError *error) {
                 
             }];
    XCTAssertEqualObjects(factory.passedParameters, @{@"key" : @"value"});
}

- (void) testSetParameterWithoutValueRemovesItFromRequestParameters{
    [connection setParameterValue:@"value" withKey:@"key"];
    [connection setParameterValue:nil withKey:@"key"];
    factory.requestToReturn = [BBARequest new];
    [connection perform:(BBAHTTPMethodGET)
             completion:^(id response, NSError *error) {
                 
             }];
    XCTAssertEqualObjects(factory.passedParameters, @{});
}

- (void) testSetParameterWithoutValueDoesntAddItToRequestParameters{
    [connection setParameterValue:nil withKey:@"key"];
    factory.requestToReturn = [BBARequest new];
    [connection perform:(BBAHTTPMethodGET)
             completion:^(id response, NSError *error) {
                 
             }];
    XCTAssertEqualObjects(factory.passedParameters, @{});
}


- (void) testPerformThrowsWithoutCompletion{
    XCTAssertThrows([connection perform:(BBAHTTPMethodGET) completion:nil]);
}

- (void) testPerformCreatesRequestFromRequestFactoryAndPassesAllNeededParamatersAndMethod{
    factory.requestToReturn = [BBARequest new];
    [connection addParameterWithKey:@"key" value:@"value1"];
    [connection addHeaderFieldWithKey:@"key" value:@"value2"];
    [connection perform:(BBAHTTPMethodGET)
             completion:^(id response, NSError *error) {
                 
             }];
    XCTAssertEqualObjects(factory.passedParameters, @{@"key" : @"value1"});
    XCTAssertEqualObjects(factory.passedHeaders, @{@"key" : @"value2"});
    XCTAssertEqual(factory.passedMethod, BBAHTTPMethodGET);
    
}

- (void) testPerformCallCompletionWithNilDataAndErrorIfRequestFactoryReturnsNil{
    BBA_DISABLE_ASSERTIONS();
    factory.errorToReturn = [NSError errorWithDomain:@"domain" code:123 userInfo:nil];
    NSString *domain = @"domain";
    NSInteger code = 123;
    [connection perform:(BBAHTTPMethodGET)
             completion:^(id response, NSError *error) {
                 XCTAssertNil(response);
                 BBBAssertErrorHasCodeAndDomain(error, code, domain);
             }];
    BBA_ENABLE_ASSERTIONS();
}

- (void) testPerformAsksAuthenticatorToAuthenticateRequestIfRequiresAuthentication{
    connection.requiresAuthentication = YES;
    factory.requestToReturn = [BBARequest new];
    [connection perform:(BBAHTTPMethodGET)
             completion:^(id response, NSError *error) {
                 
             }];
    XCTAssertTrue(authenticator.wasAskedToAuthenticate);
    
    
}

- (void) testPerformCreatesDataTaskAndPassesRequestFromRequestFactory{
    connection.session = session;
    session.taskToReturn = task;
    connection.responseMapper = responseMapper;
    NSURLRequest *urlRequest = [NSURLRequest new];
    BBARequest *request = [BBARequest requestWithURLRequest:urlRequest];
    factory.requestToReturn = request;
    [connection perform:(BBAHTTPMethodGET) completion:^(id response, NSError *error) {
        
    }];
    
    XCTAssertEqualObjects(session.passedRequest, urlRequest);
    
    
}

- (void) testPerformThrowsIfResponseMapperIsNil{
    connection.responseMapper = nil;
    XCTAssertThrows([connection perform:(BBAHTTPMethodGET) completion:^(id response, NSError *error) {}]);
    
}

- (void) testConnectionReturnsCouldNotConnectErrorAndNilResonseWhenTaskCompletesWithoutResponse{
    connection.session = session;
    session.taskToReturn = task;
    connection.responseMapper = responseMapper;
    NSURLRequest *urlRequest = [NSURLRequest new];
    BBARequest *request = [BBARequest requestWithURLRequest:urlRequest];
    factory.requestToReturn = request;
    
    session.responseToReturn = nil;
    
    NSInteger code = BBAAPIErrorCouldNotConnect;
    NSString *domain = BBAConnectionErrorDomain;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Connection completion"];
    [connection perform:(BBAHTTPMethodGET) completion:^(id response, NSError *error) {
        XCTAssertNil(response);
        BBBAssertErrorHasCodeAndDomain(error, code, domain);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:0.1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Test timeout Error: %@", error);
        }
    }];
}

- (void) testConnectionReturnsDataAndErrorFromResponseMapper{
    connection.session = session;
    session.taskToReturn = task;
    connection.responseMapper = responseMapper;
    NSURLRequest *urlRequest = [NSURLRequest new];
    BBARequest *request = [BBARequest requestWithURLRequest:urlRequest];
    factory.requestToReturn = request;
    
    session.responseToReturn = [NSURLResponse new];
    
    NSInteger code = 123;
    NSString *domain = @"domain";
    
    responseMapper.objectToReturn = @"12345";
    responseMapper.errorToReturn = [NSError errorWithDomain:domain code:code userInfo:nil];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Connection completion"];
    [connection perform:(BBAHTTPMethodGET) completion:^(id response, NSError *error) {
        XCTAssertEqualObjects(response, @"12345");
        BBBAssertErrorHasCodeAndDomain(error,code, domain);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:0.1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Test timeout Error: %@", error);
        }
    }];
}

@end
