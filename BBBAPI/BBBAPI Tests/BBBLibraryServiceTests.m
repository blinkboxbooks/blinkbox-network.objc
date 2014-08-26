//
//  BBBLibraryServiceTests.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 01/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBLibraryService.h"
#import "BBBConnection.h"
#import "BBBUserDetails.h"
#import "BBBServerDateFormatter.h"
#import "BBBLibraryItem.h"
#import "BBBSwizzlingHelper.h"
#import "BBBMockConnection.h"
#import "BBBAPIErrors.h"
#import "BBBLibraryResponse.h"
#import "BBBStatusResponseMapper.h"
#import "BBBLibraryResponseMapper.h"

@interface BBBLibraryService (Tests)
- (void) performAction:(BBBItemAction)action
                onItem:(BBBLibraryItem *)item
                  user:(BBBUserDetails *)user
            completion:(void (^)(BOOL success, NSError *error))completion;

@end

@interface BBBLibraryResponse (Tests)
@property (nonatomic, strong) NSDate *syncDate;
@property (nonatomic, copy) NSArray *changes;
@end


@interface BBBLibraryServiceTests : XCTestCase{
    BBBLibraryService *libraryService;
    BBBMockConnection *mockConnection;
    IMP oldImplementation;
    id (^initBlock)(id, BBBAPIDomain, NSString *);
    __block NSString *passedRelativeURLString;
    __block BBBAPIDomain passedDomain;
}
@end

@implementation BBBLibraryServiceTests

- (void) setUp{
    [super setUp];
    libraryService = [BBBLibraryService new];
    mockConnection = [BBBMockConnection new];
    
    __weak BBBMockConnection *weakMockConnection = mockConnection;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
    
    initBlock = ^id(id instance, BBBAPIDomain domain, NSString *relative){
        passedRelativeURLString = relative;
        passedDomain = domain;
        return weakMockConnection;
    };
#pragma clang diagnostic pop
    
    Class class = [BBBConnection class];
    SEL selector = @selector(initWithDomain:relativeURL:);
    Method originalMethod = class_getInstanceMethod(class,selector);
    IMP newImplementation = imp_implementationWithBlock(initBlock);
    oldImplementation = class_replaceMethod(class, selector, newImplementation,
                                            method_getTypeEncoding(originalMethod));
    
}

- (void) tearDown{
    
    libraryService = nil;
    
    Class class = [BBBConnection class];
    SEL selector = @selector(initWithDomain:relativeURL:);
    Method originalMethod = class_getInstanceMethod(class,selector); \
    class_replaceMethod(class, selector, oldImplementation, method_getTypeEncoding(originalMethod));
    initBlock = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void) testInit{
    XCTAssertNotNil(libraryService);
}

#pragma mark - GetChanges tests

- (void) testGetChangesNotPassingCompletionBlocksThrowsParameterExcpetion{
    BBBUserDetails *user = [BBBUserDetails new];
    XCTAssertThrows([libraryService getChangesAfterDate:nil items:nil user:user completion:nil],
                    @"Should thorw invalid argument exception");
}

- (void) testGetChangesNotPassingUserThrowsException{
    void (^block)(id,id,id) = ^(NSArray *items, NSDate *syncDate, NSError *error) {};
    XCTAssertThrows([libraryService getChangesAfterDate:nil items:nil user:nil completion:block],
                    @"Should thow ");
}

- (void) testGetChangesNotPassingUserOrCompletionReturnsImmidiatelyWithNils{
    
    BBB_DISABLE_ASSERTIONS();
    __block BOOL callbackWasCalled = NO;
    [libraryService getChangesAfterDate:nil
                                  items:nil
                                   user:nil
                             completion:^(NSArray *items, NSDate *syncDate, NSError *error) {
                                 XCTAssertNil(items);
                                 XCTAssertNil(syncDate);
                                 XCTAssertEqualObjects(error.domain, BBBLibraryServiceErrorDomain);
                                 XCTAssertEqual(error.code, BBBAPIWrongUsage);
                                 callbackWasCalled = YES;
                             }];
    XCTAssertTrue(callbackWasCalled, @"Callback must be called");
    BBB_ENABLE_ASSERTIONS();
}

- (void) testGetChangesThatLastSyncDateIsNotSentIfDateIsNil{
    
    
    [libraryService getChangesAfterDate:nil
                                  items:nil
                                   user:[BBBUserDetails new]
                             completion:^(NSArray *items, NSDate *syncDate, NSError *error) {
                                 
                             }];
    
    XCTAssertNil(mockConnection.passedParameters[@"lastSyncDate"], @"Shouldn't be passed to connection");
    
}

- (void) testGetChangesLastSyncDateIsPassedIfNotNil{
    NSDate *date = [NSDate date];
    [libraryService getChangesAfterDate:date
                                  items:nil
                                   user:[BBBUserDetails new]
                             completion:^(NSArray *items, NSDate *syncDate, NSError *error) {
                                 
                             }];
    NSString *dateString = mockConnection.passedParameters[@"lastSyncDate"];
    NSDateFormatter *dateFormatter = [BBBServerDateFormatter new];
    NSDate *passedDate = [dateFormatter dateFromString:dateString];
    XCTAssertTrue([date timeIntervalSinceDate:passedDate] < 1.0, @"Dates should be the same to the seconds");
}

- (void) testGetChangesPassingISBNOfLibraryItems{
    
    BBBLibraryItem *item1 = [BBBLibraryItem new];
    item1.isbn = @"123";
    BBBLibraryItem *item2 = [BBBLibraryItem new];
    item2.isbn = @"124";
    BBBLibraryItem *item3 = [BBBLibraryItem new];
    item3.isbn = @"125";
    NSArray *items = @[item1, item2, item3];
    
    [libraryService getChangesAfterDate:nil
                                  items:items
                                   user:[BBBUserDetails new]
                             completion:^(NSArray *items, NSDate *syncDate, NSError *error) {}];
    
    NSArray *isbns = mockConnection.passedArrayParameters[@"book"];
    NSArray *itemsIsbns = @[@"123",@"124",@"125"];
    XCTAssertEqualObjects(isbns, itemsIsbns, @"Library items isbns should be passed");
    
}

- (void) testGetChangesServicePassesItemsAndDateFromConnection{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.isbn = @"123";
    NSDate *date = [NSDate date];
    NSArray *itemsToReturn = @[item];
    BBBLibraryResponse *response = [BBBLibraryResponse new];
    response.changes = itemsToReturn;
    response.syncDate = date;
    mockConnection.objectToReturn = response;
    __block BOOL callbackWasCalled = NO;
    [libraryService getChangesAfterDate:nil
                                  items:nil
                                   user:[BBBUserDetails new]
                             completion:^(NSArray *items, NSDate *syncDate, NSError *error) {
                                 XCTAssertEqualObjects(itemsToReturn, items, @"Items array should be passed");
                                 XCTAssertEqualObjects(date, syncDate, @"Date must be passed");
                                 callbackWasCalled = YES;
                             }];
    XCTAssertTrue(callbackWasCalled, @"Callback must be called");
}

- (void) testGetChangesServicePassesErrorFromConnection{
    
    mockConnection.errorToReturn = [NSError errorWithDomain:@"domain" code:123 userInfo:nil];
    __block BOOL callbackWasCalled = NO;
    [libraryService getChangesAfterDate:nil
                                  items:nil
                                   user:[BBBUserDetails new]
                             completion:^(NSArray *items, NSDate *syncDate, NSError *error) {
                                 XCTAssertNil(items, @"items must be nil");
                                 XCTAssertNil(syncDate, @"syncDate must be nil");
                                 XCTAssertEqual(error.code, 123, @"error.code must be equal");
                                 XCTAssertEqualObjects(error.domain, @"domain", @"error.domain must be equal");
                                 callbackWasCalled = YES;
                             }];
    XCTAssertTrue(callbackWasCalled, @"Callback must be called");
}

- (void) testGetChangesAfterDateUserCompletionCallsConnection{
    [libraryService getChangesAfterDate:nil
                                   user:[BBBUserDetails new]
                             completion:^(NSArray *items, NSDate *syncDate, NSError *error) {}];
    
    XCTAssertTrue(mockConnection.wasPerformCompletionCalled,
                  @"Shorter method should call perform on connection");
}

- (void) testGetChangesPassingLibraryResponseMapperForConnectionToUser{
    
    BBBLibraryItem *item1 = [BBBLibraryItem new];
    item1.isbn = @"123";
    BBBLibraryItem *item2 = [BBBLibraryItem new];
    item2.isbn = @"124";
    BBBLibraryItem *item3 = [BBBLibraryItem new];
    item3.isbn = @"125";
    NSArray *items = @[item1, item2, item3];
    
    [libraryService getChangesAfterDate:nil
                                  items:items
                                   user:[BBBUserDetails new]
                             completion:^(NSArray *items, NSDate *syncDate, NSError *error) {}];
    XCTAssertTrue([mockConnection.responseMapper isKindOfClass:[BBBLibraryResponseMapper class]],
                  @"should pass status responsemapper");
    
}

#pragma mark - GetItem tests

- (void) testGetItemWithoutLibraryItemThrows{
    XCTAssertThrows([libraryService getItem:nil user:[BBBUserDetails new]
                                 completion:^(BBBLibraryItem *libraryItem, NSError *error) {
                                     
                                 }], @"Should throw with no item");
    
}

- (void) testGetItemWithoutUserThrows{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"123";
    XCTAssertThrows([libraryService getItem:item user:nil
                                 completion:^(BBBLibraryItem *libraryItem, NSError *error) {}],
                    @"Should throw without user");
}

- (void) testGetItemThrowsWithoutCompletionBlock{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"123";
    XCTAssertThrows([libraryService getItem:item user:[BBBUserDetails new] completion:nil],
                    @"Should throw without completion");
}

- (void) testGetItemReturnsWithErrorIfNoUserButCompletionAndProduction{
    BBB_DISABLE_ASSERTIONS();
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"123";
    __block BOOL callbackCalled = NO;
    [libraryService getItem:item
                       user:nil
                 completion:^(BBBLibraryItem *libraryItem, NSError *error) {
                     XCTAssertNil(libraryItem, @"no library item");
                     XCTAssertEqualObjects(error.domain, BBBLibraryServiceErrorDomain,
                                           @"domain should be service");
                     XCTAssertEqual(error.code, BBBAPIWrongUsage,
                                    @"code should be missing pars");
                     callbackCalled = YES;
                 }];
    XCTAssertTrue(callbackCalled, @"callback should be called");
    BBB_ENABLE_ASSERTIONS();
}

- (void) testGetItemReturnsWithErrorIfNoItemButCompletionAndProduction{
    BBB_DISABLE_ASSERTIONS();
    __block BOOL callbackCalled = NO;
    [libraryService getItem:nil
                       user:[BBBUserDetails new]
                 completion:^(BBBLibraryItem *libraryItem, NSError *error) {
                     XCTAssertNil(libraryItem, @"no library item");
                     XCTAssertEqualObjects(error.domain, BBBLibraryServiceErrorDomain,
                                           @"domain should be service");
                     XCTAssertEqual(error.code, BBBAPIWrongUsage,
                                    @"code should be missing pars");
                     callbackCalled = YES;
                 }];
    XCTAssertTrue(callbackCalled, @"callback should be called");
    BBB_ENABLE_ASSERTIONS();
}

- (void) testGetItemIfLibraryHasNoIdentifier{
    BBBLibraryItem *item = [BBBLibraryItem new];
    
    XCTAssertThrows([libraryService getItem:item user:[BBBUserDetails new]
                                 completion:^(BBBLibraryItem *l, NSError *e) {}],
                    @"Should throw without without identifier");
}

- (void) testGetItemPassesBookToConnection{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"32060+34756";
    BBBUserDetails *user = [BBBUserDetails new];
    [libraryService getItem:item
                       user:user
                 completion:^(BBBLibraryItem *libraryItem, NSError *error) {}];
    XCTAssertEqualObjects(passedRelativeURLString, @"my/library/32060+34756",
                          @"item id should be appended to the base URL");
}

- (void) testGetItemPassesReturnObjectFromConnection{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"32060+34756";
    BBBUserDetails *user = [BBBUserDetails new];
    
    BBBLibraryItem *itemToReturn = [BBBLibraryItem new];
    itemToReturn.isbn = @"123";
    itemToReturn.identifier = @"123+123";
    BBBLibraryResponse *response = [BBBLibraryResponse new];
    response.changes = @[itemToReturn];
    mockConnection.objectToReturn = response;
    mockConnection.shouldCallCompletion = YES;
    __block BOOL wasCalled = NO;
    [libraryService getItem:item
                       user:user
                 completion:^(BBBLibraryItem *libraryItem, NSError *error) {
                     XCTAssertNil(nil, @"error should be nil");
                     XCTAssertEqualObjects(libraryItem, itemToReturn,
                                           @"Service should pass value from connection");
                     wasCalled = YES;
                 }];
    
    XCTAssertTrue(wasCalled, @"completion must be called");
}

- (void) testGetItemPassesErrorFromConnectionInTheCallback{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"32060+34756";
    BBBUserDetails *user = [BBBUserDetails new];
    
    NSError *error = [NSError errorWithDomain:@"domain"
                                         code:123
                                     userInfo:nil];
    mockConnection.errorToReturn = error;
    mockConnection.shouldCallCompletion = YES;
    __block BOOL wasCalled = NO;
    [libraryService getItem:item
                       user:user
                 completion:^(BBBLibraryItem *libraryItem, NSError *error) {
                     XCTAssertEqualObjects(error.domain, @"domain", @"Error domain must be equal");
                     XCTAssertEqual(error.code, 123, @"Error code must be equal");
                     wasCalled = YES;
                 }];
    
    XCTAssertTrue(wasCalled, @"completion must be called");
}

- (void) testGetItemHasGetHTTPMethod{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"32060+34756";
    BBBUserDetails *user = [BBBUserDetails new];
    [libraryService getItem:item
                       user:user
                 completion:^(BBBLibraryItem *libraryItem, NSError *error) {}];
    XCTAssertEqual(mockConnection.passedHTTPMethod, BBBHTTPMethodGET,
                   @"GetItem should be a GET request");
}

- (void) testGetItemPassesLibraryResponseMapper{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"32060+34756";
    BBBUserDetails *user = [BBBUserDetails new];
    [libraryService getItem:item
                       user:user
                 completion:^(BBBLibraryItem *libraryItem, NSError *error) {}];
    XCTAssertTrue([mockConnection.responseMapper isKindOfClass:[BBBLibraryResponseMapper class]],
                  @"should pass status responsemapper");
}

#pragma mark - SetReadingStatus tests

- (void) testSetReadingStatusSendsPUTRequest{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"32060+34756";
    BBBUserDetails *user = [BBBUserDetails new];
    [libraryService setReadingStatus:(BBBReadingStatusReading)
                                item:item
                                user:user
                          completion:^(BOOL success, NSError *error) {}];
    XCTAssertEqual(mockConnection.passedHTTPMethod, BBBHTTPMethodPUT,
                   @"set reading status should be a GET request");
}

- (void) testSetReadingStatusPassesUserIn{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234+56789";
    BBBUserDetails *user = [BBBUserDetails new];
    mockConnection.objectToReturn = @YES;
    
    [libraryService setReadingStatus:(BBBReadingStatusUnread)
                                item:item
                                user:user
                          completion:^(BOOL success, NSError *error) {}];
    XCTAssertEqualObjects(mockConnection.passedUserDetails, user, @"user should be passed to connection");
}

- (void) testSetReadingStatusThrowsWhenNoUser{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"32060+34756";
    XCTAssertThrows([libraryService setReadingStatus:(BBBReadingStatusReading)
                                                item:item
                                                user:nil
                                          completion:^(BOOL success, NSError *error) {}],
                    @"should throw if no user");
}

- (void) testSetReadingStatusThrowsWhenNoItem{
    
    XCTAssertThrows([libraryService setReadingStatus:(BBBReadingStatusReading)
                                                item:nil
                                                user:[BBBUserDetails new]
                                          completion:^(BOOL success, NSError *error) {}],
                    @"should throw if no item");
}

- (void) testSetReadingStatusThrowsWhenCompletion{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"32060+34756";
    XCTAssertThrows([libraryService setReadingStatus:(BBBReadingStatusReading)
                                                item:item
                                                user:[BBBUserDetails new]
                                          completion:nil],
                    @"should throw if no completion block");
}

- (void) testSetReadingStatusThrowsWhenItemHasNoIdentifier{
    BBBLibraryItem *item = [BBBLibraryItem new];
    XCTAssertThrows([libraryService setReadingStatus:(BBBReadingStatusReading)
                                                item:item
                                                user:[BBBUserDetails new]
                                          completion:^(BOOL success, NSError *error) {}],
                    @"should throw if no identifier in the library item");
}

- (void) testSetReadingCallbackWithErrorIfNoItemButCompletionButProduction{
    BBB_DISABLE_ASSERTIONS();
    __block BOOL callbackCalled = NO;
    [libraryService setReadingStatus:(BBBReadingStatusUnread)
                                item:nil
                                user:[BBBUserDetails new]
                          completion:^(BOOL success, NSError *error) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                              
                              XCTAssertEqual(success, NO, @"not a success");
                              
                              XCTAssertEqualObjects(error.domain, BBBLibraryServiceErrorDomain,
                                                    @"domain should be service");
                              XCTAssertEqual(error.code, BBBAPIWrongUsage,
                                             @"code should be missing pars");
                              callbackCalled = YES;
#pragma clang diagnostic pop
                          }];
    XCTAssertTrue(callbackCalled, @"callback should be called");
    BBB_ENABLE_ASSERTIONS();
}

- (void) testSetReadingCallbackWithErrorIfNoUserButCompletionButProduction{
    BBB_DISABLE_ASSERTIONS();
    __block BOOL callbackCalled = NO;
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"123";
    [libraryService setReadingStatus:(BBBReadingStatusUnread)
                                item:item
                                user:nil
                          completion:^(BOOL success, NSError *error) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                              
                              XCTAssertEqual(success, NO, @"not a success");
                              
                              XCTAssertEqualObjects(error.domain, BBBLibraryServiceErrorDomain,
                                                    @"domain should be service");
                              XCTAssertEqual(error.code, BBBAPIWrongUsage,
                                             @"code should be missing pars");
#pragma clang diagnostic pop
                              callbackCalled = YES;
                          }];
    XCTAssertTrue(callbackCalled, @"callback should be called");
    BBB_ENABLE_ASSERTIONS();
}

- (void) testSetReadingStatusSetsContentTypeJSON{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"123";
    BBBUserDetails *user = [BBBUserDetails new];
    [libraryService setReadingStatus:(BBBReadingStatusUnread)
                                item:item
                                user:user
                          completion:^(BOOL success, NSError *error) {}];
    
    XCTAssertEqual(mockConnection.contentType, BBBContentTypeJSON, @"Should be set to JSON");
}

- (void) testSetReadingStatusAppendsBookIdentifierToPayload{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"123";
    BBBUserDetails *user = [BBBUserDetails new];
    [libraryService setReadingStatus:(BBBReadingStatusUnread)
                                item:item
                                user:user
                          completion:^(BOOL success, NSError *error) {}];
    
    XCTAssertEqualObjects(mockConnection.passedParameters[@"readingStatus"], @"UNREAD",
                          @"reading status should be passed in");
}

- (void) testSetReadingStatusCallsPerformRequest{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"123";
    BBBUserDetails *user = [BBBUserDetails new];
    [libraryService setReadingStatus:(BBBReadingStatusUnread)
                                item:item
                                user:user
                          completion:^(BOOL success, NSError *error) {}];
    XCTAssertTrue(mockConnection.wasPerformCompletionCalled, @"service should call perform request");
}

- (void) testSetReadingPassesBookIdInTheURL{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234+56789";
    BBBUserDetails *user = [BBBUserDetails new];
    [libraryService setReadingStatus:(BBBReadingStatusUnread)
                                item:item
                                user:user
                          completion:^(BOOL success, NSError *error) {}];
    XCTAssertEqualObjects(passedRelativeURLString, @"my/library/1234+56789",
                          @"item id should be appended to the base URL");
}

- (void) testSetReadingStatusPassesSuccessFromConnection{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234+56789";
    BBBUserDetails *user = [BBBUserDetails new];
    mockConnection.objectToReturn = @YES;
    __block BOOL wasCallbackCalled = NO;
    [libraryService setReadingStatus:(BBBReadingStatusUnread)
                                item:item
                                user:user
                          completion:^(BOOL success, NSError *error) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                              XCTAssertEqual(success, YES, @"succes should be passed from connection");
                              wasCallbackCalled = YES;
#pragma clang diagnostic pop
                          }];
    
    XCTAssertTrue(wasCallbackCalled, @"callback must be called");
    
}

- (void) testSetReadingStatusPassesFailureFromConnection{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234+56789";
    BBBUserDetails *user = [BBBUserDetails new];
    mockConnection.objectToReturn = @NO;
    __block BOOL wasCallbackCalled = NO;
    [libraryService setReadingStatus:(BBBReadingStatusUnread)
                                item:item
                                user:user
                          completion:^(BOOL success, NSError *error) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                              XCTAssertEqual(success, NO, @"failure should be passed from connection");
                              wasCallbackCalled = YES;
#pragma clang diagnostic pop
                          }];
    XCTAssertTrue(wasCallbackCalled, @"callback must be called");
}

- (void) testSetReadingStatusPassesAnErrorFromConnection{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234+56789";
    BBBUserDetails *user = [BBBUserDetails new];
    __block BOOL wasCallbackCalled = NO;
    mockConnection.errorToReturn = [NSError errorWithDomain:@"domain"
                                                       code:123
                                                   userInfo:nil];
    [libraryService setReadingStatus:(BBBReadingStatusUnread)
                                item:item
                                user:user
                          completion:^(BOOL success, NSError *error) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                              XCTAssertEqual(error.code, 123, @"error code should be passed");
                              XCTAssertEqualObjects(error.domain,
                                                    @"domain", @"error domain should be passed");
                              wasCallbackCalled = YES;
#pragma clang diagnostic pop
                          }];
    XCTAssertTrue(wasCallbackCalled, @"callback must be called");
}

- (void) testSetReadingStatusPassesStatusResponseMapper{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"123";
    BBBUserDetails *user = [BBBUserDetails new];
    [libraryService setReadingStatus:(BBBReadingStatusUnread)
                                item:item
                                user:user
                          completion:^(BOOL success, NSError *error) {}];
    
    XCTAssertTrue([mockConnection.responseMapper isKindOfClass:[BBBStatusResponseMapper class]],
                  @"should pass status responsemapper");
    
}

#pragma mark - Perform action tests

- (void) testPerformActionWithoutLibraryItemThrows{
    
    BBBUserDetails *user = [BBBUserDetails new];
    XCTAssertThrows([libraryService performAction:(BBBItemActionNoAction)
                                           onItem:nil
                                             user:user
                                       completion:^(BOOL s, NSError *e) {}],
                    @"should throw without item");
}

- (void) testPerformActionWithoutUserDoesntThrow{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"123";
    XCTAssertNoThrow([libraryService performAction:(BBBItemActionNoAction)
                                            onItem:item
                                              user:nil
                                        completion:^(BOOL s, NSError *e) {}],
                     @"should't throw without user");
}

- (void) testPerformActionOnItemWithoutIdThrows{
    BBBLibraryItem *item = [BBBLibraryItem new];
    XCTAssertThrows([libraryService performAction:(BBBItemActionNoAction)
                                           onItem:item
                                             user:nil
                                       completion:^(BOOL s, NSError *e) {}],
                    @"should throw on item without id");
}

- (void) testPerformActionWithoutCompletionThrows{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"123";
    BBBUserDetails *user = [BBBUserDetails new];
    XCTAssertThrows([libraryService performAction:(BBBItemActionNoAction)
                                           onItem:item
                                             user:user
                                       completion:nil],@"should throw without completion");
}

- (void) testPerformActionWithoutItemReturnErrorOnProduction{
    BBB_DISABLE_ASSERTIONS();
    BBBUserDetails *user = [BBBUserDetails new];
    __block BOOL wasCompletionCalled = NO;
    [libraryService performAction:(BBBItemActionNoAction)
                           onItem:nil
                             user:user
                       completion:^(BOOL s, NSError *e) {
                           wasCompletionCalled = YES;
                           XCTAssertFalse(s, @"false");
                           XCTAssertEqual(e.code, BBBAPIWrongUsage,
                                          @"missing pars code");
                           XCTAssertEqualObjects(e.domain, BBBLibraryServiceErrorDomain,
                                                 @"expects library domain");
                       }];
    XCTAssertTrue(wasCompletionCalled, @"callback must be called");
    BBB_ENABLE_ASSERTIONS();
}

- (void) testPerformActionArchiveCallsCorrectURL{
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"123";
    [libraryService performAction:(BBBItemActionArchive)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    XCTAssertEqualObjects(passedRelativeURLString, @"my/library/archived",
                          @"`archived` method must be called");
}

- (void) testPerformActionUnarchiveCallCurrentMethod{
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"123";
    [libraryService performAction:(BBBItemActionUnarchive)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    XCTAssertEqualObjects(passedRelativeURLString, @"my/library/current",
                          @"`current` method must be called");
    
}

- (void) testPerformDeleteCallsURLWithItemId{
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234+56789";
    item.purchaseStatus = BBBPurchaseStatusSampled;
    [libraryService performAction:(BBBItemActionDelete)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    XCTAssertEqualObjects(passedRelativeURLString, @"my/library/1234+56789",
                          @"`current` method must be called");
}

- (void) testPerformDeletePurchasedBookReturnsAnError{
    
    BBB_DISABLE_ASSERTIONS();
    __block BOOL wasCallbackCalled = NO;
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234+56789";
    item.purchaseStatus = BBBPurchaseStatusPurchased;
    [libraryService performAction:(BBBItemActionDelete)
                           onItem:item
                             user:user
                       completion:^(BOOL success, NSError *error) {
                           wasCallbackCalled = YES;
                           XCTAssertFalse(success, @"must be failure");
                           XCTAssertEqual(error.code, BBBAPIWrongUsage,
                                          @"wrong parameters errror");
                           XCTAssertEqualObjects(error.domain,BBBLibraryServiceErrorDomain,
                                                 @"library error");
                       }];
    XCTAssertTrue(wasCallbackCalled, @"Callback must be called");
    BBB_ENABLE_ASSERTIONS();
}

- (void) testPerformDeleteNotPurchasedBookReturnsAnError{
    
    BBB_DISABLE_ASSERTIONS();
    __block BOOL wasCallbackCalled = NO;
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234+56789";
    item.purchaseStatus = BBBPurchaseStatusNothing;
    [libraryService performAction:(BBBItemActionDelete)
                           onItem:item
                             user:user
                       completion:^(BOOL success, NSError *error) {
                           wasCallbackCalled = YES;
                           XCTAssertFalse(success, @"must be failure");
                           XCTAssertEqual(error.code, BBBAPIWrongUsage,
                                          @"wrong parameters errror");
                           XCTAssertEqualObjects(error.domain,BBBLibraryServiceErrorDomain,
                                                 @"library error");
                       }];
    XCTAssertTrue(wasCallbackCalled, @"Callback must be called");
    BBB_ENABLE_ASSERTIONS();
}

- (void) testPerformDeletePurchasedBookThrowsInDebug{
    
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234+56789";
    item.purchaseStatus = BBBPurchaseStatusPurchased;
    XCTAssertThrows([libraryService performAction:(BBBItemActionDelete)
                                           onItem:item
                                             user:user
                                       completion:^(BOOL success, NSError *error) {}],
                    @"should throw on not sampled book");
    
}

- (void) testPerformDeleteNotPurchasedBookThrowsInDebug{
    
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234+56789";
    item.purchaseStatus = BBBPurchaseStatusNothing;
    XCTAssertThrows([libraryService performAction:(BBBItemActionDelete)
                                           onItem:item
                                             user:user
                                       completion:^(BOOL success, NSError *error) {}],
                    @"should throw on not sampled book");
}

- (void) testPerformDeletePassesDELETEMethod{
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"123";
    item.purchaseStatus = BBBPurchaseStatusSampled;
    [libraryService performAction:(BBBItemActionDelete)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    XCTAssertEqual(mockConnection.passedHTTPMethod, BBBHTTPMethodDELETE,
                   @"should be a DELETE http request");
}

- (void) testPerformArchivePassesPOSTMethod{
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"123";
    
    [libraryService performAction:(BBBItemActionArchive)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    XCTAssertEqual(mockConnection.passedHTTPMethod, BBBHTTPMethodPOST,
                   @"should be a POST http request");
}

- (void) testPerformUnarchivePassesPOSTMethod{
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"123";
    
    [libraryService performAction:(BBBItemActionUnarchive)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    XCTAssertEqual(mockConnection.passedHTTPMethod, BBBHTTPMethodPOST,
                   @"should be a POST http request");
}

- (void) testPerformArchiveSendsLibrayItemIdInPayload{
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234+56789";
    
    [libraryService performAction:(BBBItemActionArchive)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    
    XCTAssertEqualObjects(mockConnection.passedParameters[@"libraryItemId"],
                          @"1234+56789", @"item id should be passed in");
}

- (void) testPerformUnarchiveSendsLibrayItemIdInPayload{
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234+56789";
    
    [libraryService performAction:(BBBItemActionUnarchive)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    
    XCTAssertEqualObjects(mockConnection.passedParameters[@"libraryItemId"],
                          @"1234+56789", @"item id should be passed in");
}

- (void) testPerformArchiveSetsJSONContentType{
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234+56789";
    
    [libraryService performAction:(BBBItemActionArchive)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    
    XCTAssertEqual(mockConnection.contentType, BBBContentTypeJSON, @"should be json content-type");
}

- (void) testPerformUnarchiveSetsJSONContentType{
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234+56789";
    
    [libraryService performAction:(BBBItemActionUnarchive)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    
    XCTAssertEqual(mockConnection.contentType, BBBContentTypeJSON, @"should be json content-type");
}

- (void) testPerformActionPassesSuccessFromConnection{
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234+56789";
    __block BOOL wasCallbackCalled = NO;
    mockConnection.objectToReturn = @YES;
    [libraryService performAction:(BBBItemActionArchive)
                           onItem:item
                             user:user
                       completion:^(BOOL success, NSError *e) {
                           wasCallbackCalled = YES;
                           XCTAssertTrue(success, @"success should be passed from connetion");
                       }];
    
    XCTAssertTrue(wasCallbackCalled, @"callback must be called");
}

- (void) testPerformActionPassesFailureFromConnection{
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234+56789";
    __block BOOL wasCallbackCalled = NO;
    mockConnection.objectToReturn = @NO;
    [libraryService performAction:(BBBItemActionArchive)
                           onItem:item
                             user:user
                       completion:^(BOOL success, NSError *e) {
                           wasCallbackCalled = YES;
                           XCTAssertFalse(success, @"success should be passed from connetion");
                       }];
    
    XCTAssertTrue(wasCallbackCalled, @"callback must be called");
}

- (void) testPerformActionPassesErrorFromConnection{
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234+56789";
    __block BOOL wasCallbackCalled = NO;
    mockConnection.errorToReturn = [NSError errorWithDomain:@"domain"
                                                       code:123
                                                   userInfo:nil];
    [libraryService performAction:(BBBItemActionArchive)
                           onItem:item
                             user:user
                       completion:^(BOOL success, NSError *error) {
                           wasCallbackCalled = YES;
                           XCTAssertEqual(error.code, 123, @"error code must be passed");
                           XCTAssertEqualObjects(error.domain, @"domain",@"error domain must be equal");
                       }];
    
    XCTAssertTrue(wasCallbackCalled, @"callback must be called");
}

- (void) testArchiveCallsPerformActionWithArchiveParameter{
    Class class = [BBBLibraryService class];
    SEL selector = @selector(performAction:onItem:user:completion:);
    __block BBBItemAction passedAction;
    __block BBBLibraryItem *passedItem;
    __block BBBUserDetails *passedUser;
    __block id passedCompletion;
    void (^block)(id,BBBItemAction,BBBLibraryItem*,BBBUserDetails*,id);
    
    block = ^(id instance, BBBItemAction action,BBBLibraryItem *item,BBBUserDetails *user,id c){
        passedAction = action;
        passedItem = item;
        passedUser = user;
        passedCompletion = c;
    };
    
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    
    void (^completion)(BOOL,NSError *e) = ^(BOOL s, NSError *e){};
    
    BBB_SWIZZLE_INSTANCE_METHOD_WITH_BLOCK(class, selector, block);
    [libraryService archiveItem:item
                           user:user
                     completion:completion];
    XCTAssertEqual(passedAction, BBBItemActionArchive, @"archive action must be passed action");
    XCTAssertEqualObjects(passedItem, item, @"item must be passed");
    XCTAssertEqualObjects(passedUser, user, @"user must be passed");
    XCTAssertEqualObjects(passedCompletion, completion, @"completion must be passed");
    BBB_DESWIZZLE_INSTANCE_METHOD(class, selector);
    
}

- (void) testUnarchiveCallsPerformActionWithUnarchiveParameter{
    Class class = [BBBLibraryService class];
    SEL selector = @selector(performAction:onItem:user:completion:);
    __block BBBItemAction passedAction;
    __block BBBLibraryItem *passedItem;
    __block BBBUserDetails *passedUser;
    __block id passedCompletion;
    void (^block)(id,BBBItemAction,BBBLibraryItem*,BBBUserDetails*,id);
    
    block = ^(id instance, BBBItemAction action,BBBLibraryItem *item,BBBUserDetails *user,id c){
        passedAction = action;
        passedItem = item;
        passedUser = user;
        passedCompletion = c;
    };
    
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    
    void (^completion)(BOOL,NSError *e) = ^(BOOL s, NSError *e){};
    
    BBB_SWIZZLE_INSTANCE_METHOD_WITH_BLOCK(class, selector, block);
    [libraryService unarchiveItem:item
                             user:user
                       completion:completion];
    XCTAssertEqual(passedAction, BBBItemActionUnarchive, @"archive action must be passed action");
    XCTAssertEqualObjects(passedItem, item, @"item must be passed");
    XCTAssertEqualObjects(passedUser, user, @"user must be passed");
    XCTAssertEqualObjects(passedCompletion, completion, @"completion must be passed");
    BBB_DESWIZZLE_INSTANCE_METHOD(class, selector);
}

- (void) testDeleteCallsPerformActionWithDeleteParameter{
    Class class = [BBBLibraryService class];
    SEL selector = @selector(performAction:onItem:user:completion:);
    __block BBBItemAction passedAction;
    __block BBBLibraryItem *passedItem;
    __block BBBUserDetails *passedUser;
    __block id passedCompletion;
    void (^block)(id,BBBItemAction,BBBLibraryItem*,BBBUserDetails*,id);
    
    block = ^(id instance, BBBItemAction action,BBBLibraryItem *item,BBBUserDetails *user,id c){
        passedAction = action;
        passedItem = item;
        passedUser = user;
        passedCompletion = c;
    };
    
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    
    void (^completion)(BOOL,NSError *e) = ^(BOOL s, NSError *e){};
    
    BBB_SWIZZLE_INSTANCE_METHOD_WITH_BLOCK(class, selector, block);
    [libraryService deleteItem:item
                          user:user
                    completion:completion];
    XCTAssertEqual(passedAction, BBBItemActionDelete, @"archive action must be passed action");
    XCTAssertEqualObjects(passedItem, item, @"item must be passed");
    XCTAssertEqualObjects(passedUser, user, @"user must be passed");
    XCTAssertEqualObjects(passedCompletion, completion, @"completion must be passed");
    BBB_DESWIZZLE_INSTANCE_METHOD(class, selector);
}

- (void) testPerformActionPassesStatusResponseMapper{
    BBBUserDetails *user = [BBBUserDetails new];
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"123";
    
    [libraryService performAction:(BBBItemActionUnarchive)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    XCTAssertTrue([mockConnection.responseMapper isKindOfClass:[BBBStatusResponseMapper class]],
                  @"should pass status responsemapper");
}

#pragma mark - Add sample to library tests

- (void) testAddSampleThrowsWithoutItem{
    XCTAssertThrows([libraryService addSampleItem:nil
                                             user:[BBBUserDetails new]
                                       completion:^(BOOL success, NSError *error) {}],
                    @"should throw without item");
}

- (void) testAddSampleThrowsWithoutCompletion{
    XCTAssertThrows([libraryService addSampleItem:[BBBLibraryItem new]
                                             user:[BBBUserDetails new]
                                       completion:nil],
                    @"should throw without completion");
}

- (void) testAddSampleDoesntThrowWithoutUser{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.isbn = @"123";
    XCTAssertNoThrow([libraryService addSampleItem:item
                                              user:nil
                                        completion:^(BOOL s, NSError *r){}],
                     @"should not  throw without user");
}

- (void) testAddSampleItemWithoutISBN{
    
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234-56789";
    
    XCTAssertThrows([libraryService addSampleItem:item
                                             user:nil
                                       completion:^(BOOL success, NSError *error) {}],
                    @"");
}

- (void) testAddSampleReturnsErrorWithoutItemInProduction{
    BBB_DISABLE_ASSERTIONS();
    __block BOOL wasCallbackCalled = NO;
    [libraryService addSampleItem:nil
                             user:nil
                       completion:^(BOOL success, NSError *error) {
                           wasCallbackCalled =YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                           XCTAssertFalse(success, @"failure must be returned");
                           XCTAssertEqual(error.code, BBBAPIWrongUsage,
                                          @"missing parameters error");
                           XCTAssertEqualObjects(error.domain, BBBLibraryServiceErrorDomain,
                                                 @"library error domain");
#pragma clang diagnostic pop
                       }];
    XCTAssertTrue(wasCallbackCalled, @"callback must be called");
    BBB_ENABLE_ASSERTIONS();
}

- (void) testAddSampleCallCorrectURL{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234-56789";
    item.isbn = @"123";
    [libraryService addSampleItem:item
                             user:nil
                       completion:^(BOOL success, NSError *error) {}];
    XCTAssertEqualObjects(passedRelativeURLString, @"my/library/samples", @"samples method must be called");
    
}

- (void) testAddSampleSetsJSONContentType{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234-56789";
    item.isbn = @"123";
    [libraryService addSampleItem:item
                             user:nil
                       completion:^(BOOL success, NSError *error) {}];
    XCTAssertEqual(mockConnection.contentType, BBBContentTypeJSON, @"should be JSON content type");
}

- (void) testAddSampleMakesPOSTRequest{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234-56789";
    item.isbn = @"123";
    [libraryService addSampleItem:item
                             user:nil
                       completion:^(BOOL success, NSError *error) {}];
    XCTAssertEqual(mockConnection.passedHTTPMethod, BBBHTTPMethodPOST, @"must be a POST request");
}

- (void) testAddSampleAssignsStatusResponseMapper{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234-56789";
    item.isbn = @"123456789123456789";
    [libraryService addSampleItem:item
                             user:nil
                       completion:^(BOOL success, NSError *error) {}];
    XCTAssertTrue([mockConnection.responseMapper isKindOfClass:[BBBStatusResponseMapper class]],
                  @"should pass status responsemapper");
}

- (void) testAddSampleSendsItemISBNInThePayload{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234-56789";
    item.isbn = @"123456789123456789";
    [libraryService addSampleItem:item
                             user:nil
                       completion:^(BOOL success, NSError *error) {}];
    XCTAssertEqualObjects(mockConnection.passedParameters[@"isbn"], @"123456789123456789",
                          @"isbn should be sent in the payload");
}

- (void) testAddSamplePassesSuccessFromConnection{
    __block BOOL wasCompletionCalled = NO;
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234-56789";
    item.isbn = @"123456789123456789";
    mockConnection.objectToReturn = @YES;
    [libraryService addSampleItem:item
                             user:nil
                       completion:^(BOOL success, NSError *error) {
                           wasCompletionCalled = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                           XCTAssertTrue(success, @"success should be passed from conneciton");
#pragma clang diagnostic pop
                       }];
    XCTAssertTrue(wasCompletionCalled, @"completion must be called");
}

- (void) testAddSamplePassesFailureFromConnection{
    __block BOOL wasCompletionCalled = NO;
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234-56789";
    item.isbn = @"123456789123456789";
    mockConnection.objectToReturn = @NO;
    [libraryService addSampleItem:item
                             user:nil
                       completion:^(BOOL success, NSError *error) {
                           wasCompletionCalled = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                           XCTAssertFalse(success, @"success should be passed from conneciton");
#pragma clang diagnostic pop
                       }];
    XCTAssertTrue(wasCompletionCalled, @"completion must be called");
}

- (void) testAddSamplePassesErrorFromConnection{
    __block BOOL wasCompletionCalled = NO;
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.identifier = @"1234-56789";
    item.isbn = @"123456789123456789";
    mockConnection.objectToReturn = @NO;
    mockConnection.errorToReturn = [NSError errorWithDomain:@"domain"
                                                       code:123
                                                   userInfo:nil];
    [libraryService addSampleItem:item
                             user:nil
                       completion:^(BOOL success, NSError *error) {
                           wasCompletionCalled = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                           XCTAssertEqualObjects(error.domain, @"domain", @"domain must be passed");
                           XCTAssertEqual(error.code, 123, @"code must be passed");
#pragma clang diagnostic pop
                       }];
    XCTAssertTrue(wasCompletionCalled, @"completion must be called");
}

#pragma mark - Get archived items tests

- (void) testGetArchivedItemDoesNotThrowWithUserNil{
    XCTAssertNoThrow([libraryService getArchivedItemsForUser:nil completion:^(NSArray *items, NSError *error) {}],
                     @"should throw on nil user");
}

- (void) testGetArchivedItemsThrowsOnNilCompletion{
    XCTAssertThrows([libraryService getArchivedItemsForUser:[BBBUserDetails new]
                                                 completion:nil], @"should throw on nil completion ");
}

- (void) testGetArchivedCallsProperAPIMethod{
    [libraryService getArchivedItemsForUser:[BBBUserDetails new]
                                 completion:^(NSArray *items, NSError *error) {}];
    XCTAssertEqualObjects(passedRelativeURLString, @"my/library/archived",
                          @"archived API method should be passed");
}

- (void) testGetArchivedHaveGETHTTTPMethod{
    [libraryService getArchivedItemsForUser:[BBBUserDetails new]
                                 completion:^(NSArray *items, NSError *error) {}];
    XCTAssertEqual(mockConnection.passedHTTPMethod, BBBHTTPMethodGET, @"should be GET request");
}

- (void) testGetArchivedPassesUserToConnection{
    BBBUserDetails *user = [BBBUserDetails new];
    [libraryService getArchivedItemsForUser:user
                                 completion:^(NSArray *items, NSError *error) {}];
    XCTAssertEqualObjects(mockConnection.passedUserDetails, user, @"user should be passed in");
    
}

- (void) testGetArchivedAssignsProperResponseMapper{
    [libraryService getArchivedItemsForUser:[BBBUserDetails new]
                                 completion:^(NSArray *items, NSError *error) {}];
    XCTAssertTrue([mockConnection.responseMapper isKindOfClass:[BBBLibraryResponseMapper class]],
                  @"should library response mapper");
}

- (void) testGetArchivedPassesItemsFromConnection{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.isbn = @"123";
    NSDate *date = [NSDate date];
    NSArray *itemsToReturn = @[item];
    BBBLibraryResponse *response = [BBBLibraryResponse new];
    response.changes = itemsToReturn;
    response.syncDate = date;
    mockConnection.objectToReturn = response;
    
    __block BOOL wasCompletionCalled = NO;
    [libraryService getArchivedItemsForUser:[BBBUserDetails new]
                                 completion:^(NSArray *items, NSError *error) {
                                     wasCompletionCalled = YES;
                                     XCTAssertEqualObjects(items, response.changes,
                                                           @"changes should be passed from connection");
                                 }];
    
    XCTAssertTrue(wasCompletionCalled, @"completion must be called");
}

#pragma mark - Get deleted items tests

- (void) testGetDeletedItemDoesNotThrowWithUserNil{
    XCTAssertNoThrow([libraryService getDeletedItemsForUser:nil completion:^(NSArray *i, NSError *e) {}],
                     @"should throw on nil user");
}

- (void) testGetDeletedItemsThrowsOnNilCompletion{
    XCTAssertThrows([libraryService getDeletedItemsForUser:[BBBUserDetails new]
                                                completion:nil], @"should throw on nil completion ");
}

- (void) testGetDeletedCallsProperAPIMethod{
    [libraryService getDeletedItemsForUser:[BBBUserDetails new]
                                completion:^(NSArray *items, NSError *error) {}];
    XCTAssertEqualObjects(passedRelativeURLString, @"my/library/deleted",
                          @"archived API method should be passed");
}

- (void) testGetDeletedHaveGETHTTTPMethod{
    [libraryService getDeletedItemsForUser:[BBBUserDetails new]
                                completion:^(NSArray *items, NSError *error) {}];
    XCTAssertEqual(mockConnection.passedHTTPMethod, BBBHTTPMethodGET, @"should be GET request");
}

- (void) testGetDeletedPassesUserToConnection{
    BBBUserDetails *user = [BBBUserDetails new];
    [libraryService getDeletedItemsForUser:user
                                completion:^(NSArray *items, NSError *error) {}];
    XCTAssertEqualObjects(mockConnection.passedUserDetails, user, @"user should be passed in");
    
}

- (void) testGetDeletedAssignsProperResponseMapper{
    [libraryService getArchivedItemsForUser:[BBBUserDetails new]
                                 completion:^(NSArray *items, NSError *error) {}];
    XCTAssertTrue([mockConnection.responseMapper isKindOfClass:[BBBLibraryResponseMapper class]],
                  @"should library response mapper");
}

- (void) testGetDeletedPassesItemsFromConnection{
    BBBLibraryItem *item = [BBBLibraryItem new];
    item.isbn = @"123";
    NSDate *date = [NSDate date];
    NSArray *itemsToReturn = @[item];
    BBBLibraryResponse *response = [BBBLibraryResponse new];
    response.changes = itemsToReturn;
    response.syncDate = date;
    mockConnection.objectToReturn = response;
    
    __block BOOL wasCompletionCalled = NO;
    [libraryService getDeletedItemsForUser:[BBBUserDetails new]
                                completion:^(NSArray *items, NSError *error) {
                                    wasCompletionCalled = YES;
                                    XCTAssertEqualObjects(items, response.changes,
                                                          @"changes should be passed from connection");
                                }];
    
    XCTAssertTrue(wasCompletionCalled, @"completion must be called");
}

@end