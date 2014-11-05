//
//  BBAConnectionTests.m
//  BBAAPI
//
//  Created by Tomek Kuźma on 13/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBAConnection.h"
#import "BBATestMacros.h"
#import "BBAConnectionTestsMocks.h"
#import "BBASwizzlingHelper.h"
#import "BBARequest.h"


extern NSString * BBANSStringFromBBAContentType(BBAContentType type);

@interface BBAConnectionTests : XCTestCase{
    BBAConnection *connection;
    BBAMockAuthenticator *authenticator;
    BBAMockNetworkConfiguration *configuration;
    BBAMockRequestFactory *factory;
    IMP oldImplementation;
    id (^block)(id);
}

@end

@implementation BBAConnectionTests

- (void) setUp{
    [super setUp];
    
    connection = [[BBAConnection alloc] initWithBaseURL:[self validBaseURL]];
    authenticator = [BBAMockAuthenticator new];
    configuration = [BBAMockNetworkConfiguration new];
    connection.authenticator = authenticator;
    factory = [BBAMockRequestFactory new];
    connection.requestFactory = factory;
    
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
    [super tearDown];
}

- (NSURL *) validBaseURL{
    return [NSURL URLWithString:@"http://www.blinkbox.com"];
}

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

- (void) testPerformThrowsWithoutCompletion{
    XCTAssertThrows([connection perform:(BBAHTTPMethodGET) completion:nil]);
}

- (void) testInitWithDomainAsksNetworkConfiguratorForBaseURL{
    id c = [[BBAConnection alloc] initWithDomain:BBAAPIDomainREST relativeURL:@"books"];
    c = nil;
    XCTAssertEqual(configuration.passedDomain, BBAAPIDomainREST);
}

- (void) testPerformCreatesRequestFromRequestFactoryAndPassesAllNeededParamatersAndMethod{
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
    factory.errorToReturn = [NSError errorWithDomain:@"domain" code:123 userInfo:nil];
    NSString *domain = @"domain";
    NSInteger code = 123;
    [connection perform:(BBAHTTPMethodGET)
             completion:^(id response, NSError *error) {
                 XCTAssertNil(response);
                 BBBAssertErrorHasCodeAndDomain(error, code, domain);
             }];
}

- (void) testPerformAsksAuthenticatorToAuthenticateRequestIfRequiresAuthentication{
    connection.requiresAuthentication = YES;
    factory.requestToReturn = [BBARequest new];
    [connection perform:(BBAHTTPMethodGET)
             completion:^(id response, NSError *error) {
                 
             }];
    XCTAssertTrue(authenticator.wasAskedToAuthenticate);
    
    
}

@end
