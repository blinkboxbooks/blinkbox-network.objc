//
//  BBALibraryServiceTests.m
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 01/08/2014.
 

#import "BBALibraryService.h"
#import "BBAConnection.h"
#import "BBAUserDetails.h"
#import "BBAServerDateFormatter.h"
#import "BBALibraryItem.h"
#import "BBASwizzlingHelper.h"
#import "BBAMockConnection.h"
#import "BBAAPIErrors.h"
#import "BBALibraryResponse.h"
#import "BBAStatusResponseMapper.h"
#import "BBALibraryResponseMapper.h"

@interface BBALibraryService (Tests)
- (void) performAction:(BBAItemAction)action
                onItem:(BBALibraryItem *)item
                  user:(BBAUserDetails *)user
            completion:(void (^)(BOOL success, NSError *error))completion;

@end

@interface BBALibraryResponse (Tests)
@property (nonatomic, strong) NSDate *syncDate;
@property (nonatomic, copy) NSArray *changes;
@end


@interface BBALibraryServiceTests : XCTestCase{
    BBALibraryService *libraryService;
    BBAMockConnection *mockConnection;
    IMP oldImplementation;
    id (^initBlock)(id, BBAAPIDomain, NSString *);
    __block NSString *passedRelativeURLString;
    __block BBAAPIDomain passedDomain;
}
@end

@implementation BBALibraryServiceTests

- (void) setUp{
    [super setUp];
    libraryService = [BBALibraryService new];
    mockConnection = [BBAMockConnection new];
    
    __weak BBAMockConnection *weakMockConnection = mockConnection;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
    
    initBlock = ^id(id instance, BBAAPIDomain domain, NSString *relative){
        passedRelativeURLString = relative;
        passedDomain = domain;
        return weakMockConnection;
    };
#pragma clang diagnostic pop
    
    Class class = [BBAConnection class];
    SEL selector = @selector(initWithDomain:relativeURL:);
    Method originalMethod = class_getInstanceMethod(class,selector);
    IMP newImplementation = imp_implementationWithBlock(initBlock);
    oldImplementation = class_replaceMethod(class, selector, newImplementation,
                                            method_getTypeEncoding(originalMethod));
    
}

- (void) tearDown{
    
    libraryService = nil;
    
    Class class = [BBAConnection class];
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
    BBAUserDetails *user = [BBAUserDetails new];
    XCTAssertThrows([libraryService getChangesAfterDate:nil items:nil user:user completion:nil],
                    @"Should thorw invalid argument exception");
}

- (void) testGetChangesNotPassingUserThrowsException{
    void (^block)(id,id,id) = ^(NSArray *items, NSDate *syncDate, NSError *error) {};
    XCTAssertThrows([libraryService getChangesAfterDate:nil items:nil user:nil completion:block],
                    @"Should thow ");
}

- (void) testGetChangesNotPassingUserOrCompletionReturnsImmidiatelyWithNils{
    
    BBA_DISABLE_ASSERTIONS();
    __block BOOL callbackWasCalled = NO;
    [libraryService getChangesAfterDate:nil
                                  items:nil
                                   user:nil
                             completion:^(NSArray *items, NSDate *syncDate, NSError *error) {
                                 XCTAssertNil(items);
                                 XCTAssertNil(syncDate);
                                 XCTAssertEqualObjects(error.domain, BBALibraryServiceErrorDomain);
                                 XCTAssertEqual(error.code, BBAAPIWrongUsage);
                                 callbackWasCalled = YES;
                             }];
    XCTAssertTrue(callbackWasCalled, @"Callback must be called");
    BBA_ENABLE_ASSERTIONS();
}

- (void) testGetChangesThatLastSyncDateIsNotSentIfDateIsNil{
    
    
    [libraryService getChangesAfterDate:nil
                                  items:nil
                                   user:[BBAUserDetails new]
                             completion:^(NSArray *items, NSDate *syncDate, NSError *error) {
                                 
                             }];
    
    XCTAssertNil(mockConnection.passedParameters[@"lastSyncDate"], @"Shouldn't be passed to connection");
    
}

- (void) testGetChangesLastSyncDateIsPassedIfNotNil{
    NSDate *date = [NSDate date];
    [libraryService getChangesAfterDate:date
                                  items:nil
                                   user:[BBAUserDetails new]
                             completion:^(NSArray *items, NSDate *syncDate, NSError *error) {
                                 
                             }];
    NSString *dateString = mockConnection.passedParameters[@"lastSyncDate"];
    NSDateFormatter *dateFormatter = [BBAServerDateFormatter new];
    NSDate *passedDate = [dateFormatter dateFromString:dateString];
    XCTAssertTrue([date timeIntervalSinceDate:passedDate] < 1.0, @"Dates should be the same to the seconds");
}

- (void) testGetChangesPassingISBNOfLibraryItems{
    
    BBALibraryItem *item1 = [BBALibraryItem new];
    item1.isbn = @"123";
    BBALibraryItem *item2 = [BBALibraryItem new];
    item2.isbn = @"124";
    BBALibraryItem *item3 = [BBALibraryItem new];
    item3.isbn = @"125";
    NSArray *items = @[item1, item2, item3];
    
    [libraryService getChangesAfterDate:nil
                                  items:items
                                   user:[BBAUserDetails new]
                             completion:^(NSArray *items, NSDate *syncDate, NSError *error) {}];
    
    NSArray *isbns = mockConnection.passedArrayParameters[@"book"];
    NSArray *itemsIsbns = @[@"123",@"124",@"125"];
    XCTAssertEqualObjects(isbns, itemsIsbns, @"Library items isbns should be passed");
    
}

- (void) testGetChangesServicePassesItemsAndDateFromConnection{
    BBALibraryItem *item = [BBALibraryItem new];
    item.isbn = @"123";
    NSDate *date = [NSDate date];
    NSArray *itemsToReturn = @[item];
    BBALibraryResponse *response = [BBALibraryResponse new];
    response.changes = itemsToReturn;
    response.syncDate = date;
    mockConnection.objectToReturn = response;
    __block BOOL callbackWasCalled = NO;
    [libraryService getChangesAfterDate:nil
                                  items:nil
                                   user:[BBAUserDetails new]
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
                                   user:[BBAUserDetails new]
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
                                   user:[BBAUserDetails new]
                             completion:^(NSArray *items, NSDate *syncDate, NSError *error) {}];
    
    XCTAssertTrue(mockConnection.wasPerformCompletionCalled,
                  @"Shorter method should call perform on connection");
}

- (void) testGetChangesPassingLibraryResponseMapperForConnectionToUser{
    
    BBALibraryItem *item1 = [BBALibraryItem new];
    item1.isbn = @"123";
    BBALibraryItem *item2 = [BBALibraryItem new];
    item2.isbn = @"124";
    BBALibraryItem *item3 = [BBALibraryItem new];
    item3.isbn = @"125";
    NSArray *items = @[item1, item2, item3];
    
    [libraryService getChangesAfterDate:nil
                                  items:items
                                   user:[BBAUserDetails new]
                             completion:^(NSArray *items, NSDate *syncDate, NSError *error) {}];
    XCTAssertTrue([mockConnection.responseMapper isKindOfClass:[BBALibraryResponseMapper class]],
                  @"should pass status responsemapper");
    
}

#pragma mark - GetItem tests

- (void) testGetItemWithoutLibraryItemThrows{
    XCTAssertThrows([libraryService getItem:nil user:[BBAUserDetails new]
                                 completion:^(BBALibraryItem *libraryItem, NSError *error) {
                                     
                                 }], @"Should throw with no item");
    
}

- (void) testGetItemWithoutUserThrows{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"123";
    XCTAssertThrows([libraryService getItem:item user:nil
                                 completion:^(BBALibraryItem *libraryItem, NSError *error) {}],
                    @"Should throw without user");
}

- (void) testGetItemThrowsWithoutCompletionBlock{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"123";
    XCTAssertThrows([libraryService getItem:item user:[BBAUserDetails new] completion:nil],
                    @"Should throw without completion");
}

- (void) testGetItemReturnsWithErrorIfNoUserButCompletionAndProduction{
    BBA_DISABLE_ASSERTIONS();
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"123";
    __block BOOL callbackCalled = NO;
    [libraryService getItem:item
                       user:nil
                 completion:^(BBALibraryItem *libraryItem, NSError *error) {
                     XCTAssertNil(libraryItem, @"no library item");
                     XCTAssertEqualObjects(error.domain, BBALibraryServiceErrorDomain,
                                           @"domain should be service");
                     XCTAssertEqual(error.code, BBAAPIWrongUsage,
                                    @"code should be missing pars");
                     callbackCalled = YES;
                 }];
    XCTAssertTrue(callbackCalled, @"callback should be called");
    BBA_ENABLE_ASSERTIONS();
}

- (void) testGetItemReturnsWithErrorIfNoItemButCompletionAndProduction{
    BBA_DISABLE_ASSERTIONS();
    __block BOOL callbackCalled = NO;
    [libraryService getItem:nil
                       user:[BBAUserDetails new]
                 completion:^(BBALibraryItem *libraryItem, NSError *error) {
                     XCTAssertNil(libraryItem, @"no library item");
                     XCTAssertEqualObjects(error.domain, BBALibraryServiceErrorDomain,
                                           @"domain should be service");
                     XCTAssertEqual(error.code, BBAAPIWrongUsage,
                                    @"code should be missing pars");
                     callbackCalled = YES;
                 }];
    XCTAssertTrue(callbackCalled, @"callback should be called");
    BBA_ENABLE_ASSERTIONS();
}

- (void) testGetItemIfLibraryHasNoIdentifier{
    BBALibraryItem *item = [BBALibraryItem new];
    
    XCTAssertThrows([libraryService getItem:item user:[BBAUserDetails new]
                                 completion:^(BBALibraryItem *l, NSError *e) {}],
                    @"Should throw without without identifier");
}

- (void) testGetItemPassesBookToConnection{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"32060+34756";
    BBAUserDetails *user = [BBAUserDetails new];
    [libraryService getItem:item
                       user:user
                 completion:^(BBALibraryItem *libraryItem, NSError *error) {}];
    XCTAssertEqualObjects(passedRelativeURLString, @"my/library/32060+34756",
                          @"item id should be appended to the base URL");
}

- (void) testGetItemPassesReturnObjectFromConnection{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"32060+34756";
    BBAUserDetails *user = [BBAUserDetails new];
    
    BBALibraryItem *itemToReturn = [BBALibraryItem new];
    itemToReturn.isbn = @"123";
    itemToReturn.identifier = @"123+123";
    BBALibraryResponse *response = [BBALibraryResponse new];
    response.changes = @[itemToReturn];
    mockConnection.objectToReturn = response;
    mockConnection.shouldCallCompletion = YES;
    __block BOOL wasCalled = NO;
    [libraryService getItem:item
                       user:user
                 completion:^(BBALibraryItem *libraryItem, NSError *error) {
                     XCTAssertNil(nil, @"error should be nil");
                     XCTAssertEqualObjects(libraryItem, itemToReturn,
                                           @"Service should pass value from connection");
                     wasCalled = YES;
                 }];
    
    XCTAssertTrue(wasCalled, @"completion must be called");
}

- (void) testGetItemPassesErrorFromConnectionInTheCallback{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"32060+34756";
    BBAUserDetails *user = [BBAUserDetails new];
    
    NSError *error = [NSError errorWithDomain:@"domain"
                                         code:123
                                     userInfo:nil];
    mockConnection.errorToReturn = error;
    mockConnection.shouldCallCompletion = YES;
    __block BOOL wasCalled = NO;
    [libraryService getItem:item
                       user:user
                 completion:^(BBALibraryItem *libraryItem, NSError *error) {
                     XCTAssertEqualObjects(error.domain, @"domain", @"Error domain must be equal");
                     XCTAssertEqual(error.code, 123, @"Error code must be equal");
                     wasCalled = YES;
                 }];
    
    XCTAssertTrue(wasCalled, @"completion must be called");
}

- (void) testGetItemHasGetHTTPMethod{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"32060+34756";
    BBAUserDetails *user = [BBAUserDetails new];
    [libraryService getItem:item
                       user:user
                 completion:^(BBALibraryItem *libraryItem, NSError *error) {}];
    XCTAssertEqual(mockConnection.passedHTTPMethod, BBAHTTPMethodGET,
                   @"GetItem should be a GET request");
}

- (void) testGetItemPassesLibraryResponseMapper{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"32060+34756";
    BBAUserDetails *user = [BBAUserDetails new];
    [libraryService getItem:item
                       user:user
                 completion:^(BBALibraryItem *libraryItem, NSError *error) {}];
    XCTAssertTrue([mockConnection.responseMapper isKindOfClass:[BBALibraryResponseMapper class]],
                  @"should pass status responsemapper");
}

#pragma mark - SetReadingStatus tests

- (void) testSetReadingStatusSendsPUTRequest{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"32060+34756";
    BBAUserDetails *user = [BBAUserDetails new];
    [libraryService setReadingStatus:(BBAReadingStatusReading)
                                item:item
                                user:user
                          completion:^(BOOL success, NSError *error) {}];
    XCTAssertEqual(mockConnection.passedHTTPMethod, BBAHTTPMethodPUT,
                   @"set reading status should be a GET request");
}

- (void) testSetReadingStatusPassesUserIn{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234+56789";
    BBAUserDetails *user = [BBAUserDetails new];
    mockConnection.objectToReturn = @YES;
    
    [libraryService setReadingStatus:(BBAReadingStatusUnread)
                                item:item
                                user:user
                          completion:^(BOOL success, NSError *error) {}];
    XCTAssertEqualObjects(mockConnection.passedUserDetails, user, @"user should be passed to connection");
}

- (void) testSetReadingStatusThrowsWhenNoUser{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"32060+34756";
    XCTAssertThrows([libraryService setReadingStatus:(BBAReadingStatusReading)
                                                item:item
                                                user:nil
                                          completion:^(BOOL success, NSError *error) {}],
                    @"should throw if no user");
}

- (void) testSetReadingStatusThrowsWhenNoItem{
    
    XCTAssertThrows([libraryService setReadingStatus:(BBAReadingStatusReading)
                                                item:nil
                                                user:[BBAUserDetails new]
                                          completion:^(BOOL success, NSError *error) {}],
                    @"should throw if no item");
}

- (void) testSetReadingStatusThrowsWhenCompletion{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"32060+34756";
    XCTAssertThrows([libraryService setReadingStatus:(BBAReadingStatusReading)
                                                item:item
                                                user:[BBAUserDetails new]
                                          completion:nil],
                    @"should throw if no completion block");
}

- (void) testSetReadingStatusThrowsWhenItemHasNoIdentifier{
    BBALibraryItem *item = [BBALibraryItem new];
    XCTAssertThrows([libraryService setReadingStatus:(BBAReadingStatusReading)
                                                item:item
                                                user:[BBAUserDetails new]
                                          completion:^(BOOL success, NSError *error) {}],
                    @"should throw if no identifier in the library item");
}

- (void) testSetReadingCallbackWithErrorIfNoItemButCompletionButProduction{
    BBA_DISABLE_ASSERTIONS();
    __block BOOL callbackCalled = NO;
    [libraryService setReadingStatus:(BBAReadingStatusUnread)
                                item:nil
                                user:[BBAUserDetails new]
                          completion:^(BOOL success, NSError *error) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                              
                              XCTAssertEqual(success, NO, @"not a success");
                              
                              XCTAssertEqualObjects(error.domain, BBALibraryServiceErrorDomain,
                                                    @"domain should be service");
                              XCTAssertEqual(error.code, BBAAPIWrongUsage,
                                             @"code should be missing pars");
                              callbackCalled = YES;
#pragma clang diagnostic pop
                          }];
    XCTAssertTrue(callbackCalled, @"callback should be called");
    BBA_ENABLE_ASSERTIONS();
}

- (void) testSetReadingCallbackWithErrorIfNoUserButCompletionButProduction{
    BBA_DISABLE_ASSERTIONS();
    __block BOOL callbackCalled = NO;
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"123";
    [libraryService setReadingStatus:(BBAReadingStatusUnread)
                                item:item
                                user:nil
                          completion:^(BOOL success, NSError *error) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                              
                              XCTAssertEqual(success, NO, @"not a success");
                              
                              XCTAssertEqualObjects(error.domain, BBALibraryServiceErrorDomain,
                                                    @"domain should be service");
                              XCTAssertEqual(error.code, BBAAPIWrongUsage,
                                             @"code should be missing pars");
#pragma clang diagnostic pop
                              callbackCalled = YES;
                          }];
    XCTAssertTrue(callbackCalled, @"callback should be called");
    BBA_ENABLE_ASSERTIONS();
}

- (void) testSetReadingStatusSetsContentTypeJSON{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"123";
    BBAUserDetails *user = [BBAUserDetails new];
    [libraryService setReadingStatus:(BBAReadingStatusUnread)
                                item:item
                                user:user
                          completion:^(BOOL success, NSError *error) {}];
    
    XCTAssertEqual(mockConnection.contentType, BBAContentTypeJSON, @"Should be set to JSON");
}

- (void) testSetReadingStatusAppendsBookIdentifierToPayload{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"123";
    BBAUserDetails *user = [BBAUserDetails new];
    [libraryService setReadingStatus:(BBAReadingStatusUnread)
                                item:item
                                user:user
                          completion:^(BOOL success, NSError *error) {}];
    
    XCTAssertEqualObjects(mockConnection.passedParameters[@"readingStatus"], @"UNREAD",
                          @"reading status should be passed in");
}

- (void) testSetReadingStatusCallsPerformRequest{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"123";
    BBAUserDetails *user = [BBAUserDetails new];
    [libraryService setReadingStatus:(BBAReadingStatusUnread)
                                item:item
                                user:user
                          completion:^(BOOL success, NSError *error) {}];
    XCTAssertTrue(mockConnection.wasPerformCompletionCalled, @"service should call perform request");
}

- (void) testSetReadingPassesBookIdInTheURL{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234+56789";
    BBAUserDetails *user = [BBAUserDetails new];
    [libraryService setReadingStatus:(BBAReadingStatusUnread)
                                item:item
                                user:user
                          completion:^(BOOL success, NSError *error) {}];
    XCTAssertEqualObjects(passedRelativeURLString, @"my/library/1234+56789",
                          @"item id should be appended to the base URL");
}

- (void) testSetReadingStatusPassesSuccessFromConnection{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234+56789";
    BBAUserDetails *user = [BBAUserDetails new];
    mockConnection.objectToReturn = @YES;
    __block BOOL wasCallbackCalled = NO;
    [libraryService setReadingStatus:(BBAReadingStatusUnread)
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
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234+56789";
    BBAUserDetails *user = [BBAUserDetails new];
    mockConnection.objectToReturn = @NO;
    __block BOOL wasCallbackCalled = NO;
    [libraryService setReadingStatus:(BBAReadingStatusUnread)
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
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234+56789";
    BBAUserDetails *user = [BBAUserDetails new];
    __block BOOL wasCallbackCalled = NO;
    mockConnection.errorToReturn = [NSError errorWithDomain:@"domain"
                                                       code:123
                                                   userInfo:nil];
    [libraryService setReadingStatus:(BBAReadingStatusUnread)
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
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"123";
    BBAUserDetails *user = [BBAUserDetails new];
    [libraryService setReadingStatus:(BBAReadingStatusUnread)
                                item:item
                                user:user
                          completion:^(BOOL success, NSError *error) {}];
    
    XCTAssertTrue([mockConnection.responseMapper isKindOfClass:[BBAStatusResponseMapper class]],
                  @"should pass status responsemapper");
    
}

#pragma mark - Perform action tests

- (void) testPerformActionWithoutLibraryItemThrows{
    
    BBAUserDetails *user = [BBAUserDetails new];
    XCTAssertThrows([libraryService performAction:(BBAItemActionNoAction)
                                           onItem:nil
                                             user:user
                                       completion:^(BOOL s, NSError *e) {}],
                    @"should throw without item");
}

- (void) testPerformActionWithoutUserDoesntThrow{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"123";
    XCTAssertNoThrow([libraryService performAction:(BBAItemActionNoAction)
                                            onItem:item
                                              user:nil
                                        completion:^(BOOL s, NSError *e) {}],
                     @"should't throw without user");
}

- (void) testPerformActionOnItemWithoutIdThrows{
    BBALibraryItem *item = [BBALibraryItem new];
    XCTAssertThrows([libraryService performAction:(BBAItemActionNoAction)
                                           onItem:item
                                             user:nil
                                       completion:^(BOOL s, NSError *e) {}],
                    @"should throw on item without id");
}

- (void) testPerformActionWithoutCompletionThrows{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"123";
    BBAUserDetails *user = [BBAUserDetails new];
    XCTAssertThrows([libraryService performAction:(BBAItemActionNoAction)
                                           onItem:item
                                             user:user
                                       completion:nil],@"should throw without completion");
}

- (void) testPerformActionWithoutItemReturnErrorOnProduction{
    BBA_DISABLE_ASSERTIONS();
    BBAUserDetails *user = [BBAUserDetails new];
    __block BOOL wasCompletionCalled = NO;
    [libraryService performAction:(BBAItemActionNoAction)
                           onItem:nil
                             user:user
                       completion:^(BOOL s, NSError *e) {
                           wasCompletionCalled = YES;
                           XCTAssertFalse(s, @"false");
                           XCTAssertEqual(e.code, BBAAPIWrongUsage,
                                          @"missing pars code");
                           XCTAssertEqualObjects(e.domain, BBALibraryServiceErrorDomain,
                                                 @"expects library domain");
                       }];
    XCTAssertTrue(wasCompletionCalled, @"callback must be called");
    BBA_ENABLE_ASSERTIONS();
}

- (void) testPerformActionArchiveCallsCorrectURL{
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"123";
    [libraryService performAction:(BBAItemActionArchive)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    XCTAssertEqualObjects(passedRelativeURLString, @"my/library/archived",
                          @"`archived` method must be called");
}

- (void) testPerformActionUnarchiveCallCurrentMethod{
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"123";
    [libraryService performAction:(BBAItemActionUnarchive)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    XCTAssertEqualObjects(passedRelativeURLString, @"my/library/current",
                          @"`current` method must be called");
    
}

- (void) testPerformDeleteCallsURLWithItemId{
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234+56789";
    item.purchaseStatus = BBAPurchaseStatusSampled;
    [libraryService performAction:(BBAItemActionDelete)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    XCTAssertEqualObjects(passedRelativeURLString, @"my/library/1234+56789",
                          @"`current` method must be called");
}

- (void) testPerformDeletePurchasedBookReturnsAnError{
    
    BBA_DISABLE_ASSERTIONS();
    __block BOOL wasCallbackCalled = NO;
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234+56789";
    item.purchaseStatus = BBAPurchaseStatusPurchased;
    [libraryService performAction:(BBAItemActionDelete)
                           onItem:item
                             user:user
                       completion:^(BOOL success, NSError *error) {
                           wasCallbackCalled = YES;
                           XCTAssertFalse(success, @"must be failure");
                           XCTAssertEqual(error.code, BBAAPIWrongUsage,
                                          @"wrong parameters errror");
                           XCTAssertEqualObjects(error.domain,BBALibraryServiceErrorDomain,
                                                 @"library error");
                       }];
    XCTAssertTrue(wasCallbackCalled, @"Callback must be called");
    BBA_ENABLE_ASSERTIONS();
}

- (void) testPerformDeleteNotPurchasedBookReturnsAnError{
    
    BBA_DISABLE_ASSERTIONS();
    __block BOOL wasCallbackCalled = NO;
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234+56789";
    item.purchaseStatus = BBAPurchaseStatusNothing;
    [libraryService performAction:(BBAItemActionDelete)
                           onItem:item
                             user:user
                       completion:^(BOOL success, NSError *error) {
                           wasCallbackCalled = YES;
                           XCTAssertFalse(success, @"must be failure");
                           XCTAssertEqual(error.code, BBAAPIWrongUsage,
                                          @"wrong parameters errror");
                           XCTAssertEqualObjects(error.domain,BBALibraryServiceErrorDomain,
                                                 @"library error");
                       }];
    XCTAssertTrue(wasCallbackCalled, @"Callback must be called");
    BBA_ENABLE_ASSERTIONS();
}

- (void) testPerformDeletePurchasedBookThrowsInDebug{
    
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234+56789";
    item.purchaseStatus = BBAPurchaseStatusPurchased;
    XCTAssertThrows([libraryService performAction:(BBAItemActionDelete)
                                           onItem:item
                                             user:user
                                       completion:^(BOOL success, NSError *error) {}],
                    @"should throw on not sampled book");
    
}

- (void) testPerformDeleteNotPurchasedBookThrowsInDebug{
    
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234+56789";
    item.purchaseStatus = BBAPurchaseStatusNothing;
    XCTAssertThrows([libraryService performAction:(BBAItemActionDelete)
                                           onItem:item
                                             user:user
                                       completion:^(BOOL success, NSError *error) {}],
                    @"should throw on not sampled book");
}

- (void) testPerformDeletePassesDELETEMethod{
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"123";
    item.purchaseStatus = BBAPurchaseStatusSampled;
    [libraryService performAction:(BBAItemActionDelete)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    XCTAssertEqual(mockConnection.passedHTTPMethod, BBAHTTPMethodDELETE,
                   @"should be a DELETE http request");
}

- (void) testPerformArchivePassesPOSTMethod{
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"123";
    
    [libraryService performAction:(BBAItemActionArchive)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    XCTAssertEqual(mockConnection.passedHTTPMethod, BBAHTTPMethodPOST,
                   @"should be a POST http request");
}

- (void) testPerformUnarchivePassesPOSTMethod{
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"123";
    
    [libraryService performAction:(BBAItemActionUnarchive)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    XCTAssertEqual(mockConnection.passedHTTPMethod, BBAHTTPMethodPOST,
                   @"should be a POST http request");
}

- (void) testPerformArchiveSendsLibrayItemIdInPayload{
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234+56789";
    
    [libraryService performAction:(BBAItemActionArchive)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    
    XCTAssertEqualObjects(mockConnection.passedParameters[@"libraryItemId"],
                          @"1234+56789", @"item id should be passed in");
}

- (void) testPerformUnarchiveSendsLibrayItemIdInPayload{
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234+56789";
    
    [libraryService performAction:(BBAItemActionUnarchive)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    
    XCTAssertEqualObjects(mockConnection.passedParameters[@"libraryItemId"],
                          @"1234+56789", @"item id should be passed in");
}

- (void) testPerformArchiveSetsJSONContentType{
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234+56789";
    
    [libraryService performAction:(BBAItemActionArchive)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    
    XCTAssertEqual(mockConnection.contentType, BBAContentTypeJSON, @"should be json content-type");
}

- (void) testPerformUnarchiveSetsJSONContentType{
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234+56789";
    
    [libraryService performAction:(BBAItemActionUnarchive)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    
    XCTAssertEqual(mockConnection.contentType, BBAContentTypeJSON, @"should be json content-type");
}

- (void) testPerformActionPassesSuccessFromConnection{
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234+56789";
    __block BOOL wasCallbackCalled = NO;
    mockConnection.objectToReturn = @YES;
    [libraryService performAction:(BBAItemActionArchive)
                           onItem:item
                             user:user
                       completion:^(BOOL success, NSError *e) {
                           wasCallbackCalled = YES;
                           XCTAssertTrue(success, @"success should be passed from connetion");
                       }];
    
    XCTAssertTrue(wasCallbackCalled, @"callback must be called");
}

- (void) testPerformActionPassesFailureFromConnection{
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234+56789";
    __block BOOL wasCallbackCalled = NO;
    mockConnection.objectToReturn = @NO;
    [libraryService performAction:(BBAItemActionArchive)
                           onItem:item
                             user:user
                       completion:^(BOOL success, NSError *e) {
                           wasCallbackCalled = YES;
                           XCTAssertFalse(success, @"success should be passed from connetion");
                       }];
    
    XCTAssertTrue(wasCallbackCalled, @"callback must be called");
}

- (void) testPerformActionPassesErrorFromConnection{
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234+56789";
    __block BOOL wasCallbackCalled = NO;
    mockConnection.errorToReturn = [NSError errorWithDomain:@"domain"
                                                       code:123
                                                   userInfo:nil];
    [libraryService performAction:(BBAItemActionArchive)
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
    Class class = [BBALibraryService class];
    SEL selector = @selector(performAction:onItem:user:completion:);
    __block BBAItemAction passedAction;
    __block BBALibraryItem *passedItem;
    __block BBAUserDetails *passedUser;
    __block id passedCompletion;
    void (^block)(id,BBAItemAction,BBALibraryItem*,BBAUserDetails*,id);
    
    block = ^(id instance, BBAItemAction action,BBALibraryItem *item,BBAUserDetails *user,id c){
        passedAction = action;
        passedItem = item;
        passedUser = user;
        passedCompletion = c;
    };
    
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    
    void (^completion)(BOOL,NSError *e) = ^(BOOL s, NSError *e){};
    
    BBA_SWIZZLE_INSTANCE_METHOD_WITH_BLOCK(class, selector, block);
    [libraryService archiveItem:item
                           user:user
                     completion:completion];
    XCTAssertEqual(passedAction, BBAItemActionArchive, @"archive action must be passed action");
    XCTAssertEqualObjects(passedItem, item, @"item must be passed");
    XCTAssertEqualObjects(passedUser, user, @"user must be passed");
    XCTAssertEqualObjects(passedCompletion, completion, @"completion must be passed");
    BBA_DESWIZZLE_INSTANCE_METHOD(class, selector);
    
}

- (void) testUnarchiveCallsPerformActionWithUnarchiveParameter{
    Class class = [BBALibraryService class];
    SEL selector = @selector(performAction:onItem:user:completion:);
    __block BBAItemAction passedAction;
    __block BBALibraryItem *passedItem;
    __block BBAUserDetails *passedUser;
    __block id passedCompletion;
    void (^block)(id,BBAItemAction,BBALibraryItem*,BBAUserDetails*,id);
    
    block = ^(id instance, BBAItemAction action,BBALibraryItem *item,BBAUserDetails *user,id c){
        passedAction = action;
        passedItem = item;
        passedUser = user;
        passedCompletion = c;
    };
    
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    
    void (^completion)(BOOL,NSError *e) = ^(BOOL s, NSError *e){};
    
    BBA_SWIZZLE_INSTANCE_METHOD_WITH_BLOCK(class, selector, block);
    [libraryService unarchiveItem:item
                             user:user
                       completion:completion];
    XCTAssertEqual(passedAction, BBAItemActionUnarchive, @"archive action must be passed action");
    XCTAssertEqualObjects(passedItem, item, @"item must be passed");
    XCTAssertEqualObjects(passedUser, user, @"user must be passed");
    XCTAssertEqualObjects(passedCompletion, completion, @"completion must be passed");
    BBA_DESWIZZLE_INSTANCE_METHOD(class, selector);
}

- (void) testDeleteCallsPerformActionWithDeleteParameter{
    Class class = [BBALibraryService class];
    SEL selector = @selector(performAction:onItem:user:completion:);
    __block BBAItemAction passedAction;
    __block BBALibraryItem *passedItem;
    __block BBAUserDetails *passedUser;
    __block id passedCompletion;
    void (^block)(id,BBAItemAction,BBALibraryItem*,BBAUserDetails*,id);
    
    block = ^(id instance, BBAItemAction action,BBALibraryItem *item,BBAUserDetails *user,id c){
        passedAction = action;
        passedItem = item;
        passedUser = user;
        passedCompletion = c;
    };
    
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    
    void (^completion)(BOOL,NSError *e) = ^(BOOL s, NSError *e){};
    
    BBA_SWIZZLE_INSTANCE_METHOD_WITH_BLOCK(class, selector, block);
    [libraryService deleteItem:item
                          user:user
                    completion:completion];
    XCTAssertEqual(passedAction, BBAItemActionDelete, @"archive action must be passed action");
    XCTAssertEqualObjects(passedItem, item, @"item must be passed");
    XCTAssertEqualObjects(passedUser, user, @"user must be passed");
    XCTAssertEqualObjects(passedCompletion, completion, @"completion must be passed");
    BBA_DESWIZZLE_INSTANCE_METHOD(class, selector);
}

- (void) testPerformActionPassesStatusResponseMapper{
    BBAUserDetails *user = [BBAUserDetails new];
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"123";
    
    [libraryService performAction:(BBAItemActionUnarchive)
                           onItem:item
                             user:user
                       completion:^(BOOL s, NSError *e) {}];
    XCTAssertTrue([mockConnection.responseMapper isKindOfClass:[BBAStatusResponseMapper class]],
                  @"should pass status responsemapper");
}

#pragma mark - Add sample to library tests

- (void) testAddSampleThrowsWithoutItem{
    XCTAssertThrows([libraryService addSampleItem:nil
                                             user:[BBAUserDetails new]
                                       completion:^(BOOL success, NSError *error) {}],
                    @"should throw without item");
}

- (void) testAddSampleThrowsWithoutCompletion{
    XCTAssertThrows([libraryService addSampleItem:[BBALibraryItem new]
                                             user:[BBAUserDetails new]
                                       completion:nil],
                    @"should throw without completion");
}

- (void) testAddSampleDoesntThrowWithoutUser{
    BBALibraryItem *item = [BBALibraryItem new];
    item.isbn = @"123";
    XCTAssertNoThrow([libraryService addSampleItem:item
                                              user:nil
                                        completion:^(BOOL s, NSError *r){}],
                     @"should not  throw without user");
}

- (void) testAddSampleItemWithoutISBN{
    
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234-56789";
    
    XCTAssertThrows([libraryService addSampleItem:item
                                             user:nil
                                       completion:^(BOOL success, NSError *error) {}],
                    @"");
}

- (void) testAddSampleReturnsErrorWithoutItemInProduction{
    BBA_DISABLE_ASSERTIONS();
    __block BOOL wasCallbackCalled = NO;
    [libraryService addSampleItem:nil
                             user:nil
                       completion:^(BOOL success, NSError *error) {
                           wasCallbackCalled =YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                           XCTAssertFalse(success, @"failure must be returned");
                           XCTAssertEqual(error.code, BBAAPIWrongUsage,
                                          @"missing parameters error");
                           XCTAssertEqualObjects(error.domain, BBALibraryServiceErrorDomain,
                                                 @"library error domain");
#pragma clang diagnostic pop
                       }];
    XCTAssertTrue(wasCallbackCalled, @"callback must be called");
    BBA_ENABLE_ASSERTIONS();
}

- (void) testAddSampleCallCorrectURL{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234-56789";
    item.isbn = @"123";
    [libraryService addSampleItem:item
                             user:nil
                       completion:^(BOOL success, NSError *error) {}];
    XCTAssertEqualObjects(passedRelativeURLString, @"my/library/samples", @"samples method must be called");
    
}

- (void) testAddSampleSetsJSONContentType{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234-56789";
    item.isbn = @"123";
    [libraryService addSampleItem:item
                             user:nil
                       completion:^(BOOL success, NSError *error) {}];
    XCTAssertEqual(mockConnection.contentType, BBAContentTypeJSON, @"should be JSON content type");
}

- (void) testAddSampleMakesPOSTRequest{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234-56789";
    item.isbn = @"123";
    [libraryService addSampleItem:item
                             user:nil
                       completion:^(BOOL success, NSError *error) {}];
    XCTAssertEqual(mockConnection.passedHTTPMethod, BBAHTTPMethodPOST, @"must be a POST request");
}

- (void) testAddSampleAssignsStatusResponseMapper{
    BBALibraryItem *item = [BBALibraryItem new];
    item.identifier = @"1234-56789";
    item.isbn = @"123456789123456789";
    [libraryService addSampleItem:item
                             user:nil
                       completion:^(BOOL success, NSError *error) {}];
    XCTAssertTrue([mockConnection.responseMapper isKindOfClass:[BBAStatusResponseMapper class]],
                  @"should pass status responsemapper");
}

- (void) testAddSampleSendsItemISBNInThePayload{
    BBALibraryItem *item = [BBALibraryItem new];
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
    BBALibraryItem *item = [BBALibraryItem new];
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
    BBALibraryItem *item = [BBALibraryItem new];
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
    BBALibraryItem *item = [BBALibraryItem new];
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
    XCTAssertThrows([libraryService getArchivedItemsForUser:[BBAUserDetails new]
                                                 completion:nil], @"should throw on nil completion ");
}

- (void) testGetArchivedCallsProperAPIMethod{
    [libraryService getArchivedItemsForUser:[BBAUserDetails new]
                                 completion:^(NSArray *items, NSError *error) {}];
    XCTAssertEqualObjects(passedRelativeURLString, @"my/library/archived",
                          @"archived API method should be passed");
}

- (void) testGetArchivedHaveGETHTTTPMethod{
    [libraryService getArchivedItemsForUser:[BBAUserDetails new]
                                 completion:^(NSArray *items, NSError *error) {}];
    XCTAssertEqual(mockConnection.passedHTTPMethod, BBAHTTPMethodGET, @"should be GET request");
}

- (void) testGetArchivedPassesUserToConnection{
    BBAUserDetails *user = [BBAUserDetails new];
    [libraryService getArchivedItemsForUser:user
                                 completion:^(NSArray *items, NSError *error) {}];
    XCTAssertEqualObjects(mockConnection.passedUserDetails, user, @"user should be passed in");
    
}

- (void) testGetArchivedAssignsProperResponseMapper{
    [libraryService getArchivedItemsForUser:[BBAUserDetails new]
                                 completion:^(NSArray *items, NSError *error) {}];
    XCTAssertTrue([mockConnection.responseMapper isKindOfClass:[BBALibraryResponseMapper class]],
                  @"should library response mapper");
}

- (void) testGetArchivedPassesItemsFromConnection{
    BBALibraryItem *item = [BBALibraryItem new];
    item.isbn = @"123";
    NSDate *date = [NSDate date];
    NSArray *itemsToReturn = @[item];
    BBALibraryResponse *response = [BBALibraryResponse new];
    response.changes = itemsToReturn;
    response.syncDate = date;
    mockConnection.objectToReturn = response;
    
    __block BOOL wasCompletionCalled = NO;
    [libraryService getArchivedItemsForUser:[BBAUserDetails new]
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
    XCTAssertThrows([libraryService getDeletedItemsForUser:[BBAUserDetails new]
                                                completion:nil], @"should throw on nil completion ");
}

- (void) testGetDeletedCallsProperAPIMethod{
    [libraryService getDeletedItemsForUser:[BBAUserDetails new]
                                completion:^(NSArray *items, NSError *error) {}];
    XCTAssertEqualObjects(passedRelativeURLString, @"my/library/deleted",
                          @"archived API method should be passed");
}

- (void) testGetDeletedHaveGETHTTTPMethod{
    [libraryService getDeletedItemsForUser:[BBAUserDetails new]
                                completion:^(NSArray *items, NSError *error) {}];
    XCTAssertEqual(mockConnection.passedHTTPMethod, BBAHTTPMethodGET, @"should be GET request");
}

- (void) testGetDeletedPassesUserToConnection{
    BBAUserDetails *user = [BBAUserDetails new];
    [libraryService getDeletedItemsForUser:user
                                completion:^(NSArray *items, NSError *error) {}];
    XCTAssertEqualObjects(mockConnection.passedUserDetails, user, @"user should be passed in");
    
}

- (void) testGetDeletedAssignsProperResponseMapper{
    [libraryService getArchivedItemsForUser:[BBAUserDetails new]
                                 completion:^(NSArray *items, NSError *error) {}];
    XCTAssertTrue([mockConnection.responseMapper isKindOfClass:[BBALibraryResponseMapper class]],
                  @"should library response mapper");
}

- (void) testGetDeletedPassesItemsFromConnection{
    BBALibraryItem *item = [BBALibraryItem new];
    item.isbn = @"123";
    NSDate *date = [NSDate date];
    NSArray *itemsToReturn = @[item];
    BBALibraryResponse *response = [BBALibraryResponse new];
    response.changes = itemsToReturn;
    response.syncDate = date;
    mockConnection.objectToReturn = response;
    
    __block BOOL wasCompletionCalled = NO;
    [libraryService getDeletedItemsForUser:[BBAUserDetails new]
                                completion:^(NSArray *items, NSError *error) {
                                    wasCompletionCalled = YES;
                                    XCTAssertEqualObjects(items, response.changes,
                                                          @"changes should be passed from connection");
                                }];
    
    XCTAssertTrue(wasCompletionCalled, @"completion must be called");
}

@end