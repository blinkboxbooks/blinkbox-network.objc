//
//  BBBLibraryResponseTests.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 11/08/2014.
//  Copyright (c) 2014 Blinkbox Books. All rights reserved.
//

#import "BBBLibraryResponse.h"
#import "BBBServerDateFormatter.h"
#import "BBBTestHelper.h"
#import "BBBLibraryItem.h"
#import "BBBResponseMapping.h"
#import "BBBLibraryItemLink.h"

extern BBBReadingStatus BBBReadingStatusFromString(NSString *status);
extern BBBPurchaseStatus BBBPurchaseStatusFromString(NSString *status);
extern BBBVisiblityStatus BBBVisibiliyStatusFromString(NSString *status);
extern NSString * BBBNSStringFromBBBReadingStatus(BBBReadingStatus status);

@interface BBBLibraryResponseTests : XCTestCase{
    BBBLibraryResponse *response;
}

@end

@implementation BBBLibraryResponseTests

#pragma mark - SetUp/TearDown

- (void) setUp{
    [super setUp];
    response = [BBBLibraryResponse new];
}

- (void) tearDown{
    response = nil;
    [super tearDown];
}

#pragma mark - Functions tests


- (void) testReadingStatusMappingFunction{

    BBB_DISABLE_ASSERTIONS();
    XCTAssertEqual(BBBReadingStatusUnknown, BBBReadingStatusFromString(@"SOMETHING"));
    XCTAssertEqual(BBBReadingStatusRead, BBBReadingStatusFromString(@"FINISHED"));
    XCTAssertEqual(BBBReadingStatusUnread, BBBReadingStatusFromString(@"UNREAD"));
    XCTAssertEqual(BBBReadingStatusReading, BBBReadingStatusFromString(@"READING"));
    BBB_ENABLE_ASSERTIONS();
}

- (void) testPurchaseStatusMappingFunction{
    BBB_DISABLE_ASSERTIONS();
    XCTAssertEqual(BBBPurchaseStatusNothing, BBBPurchaseStatusFromString(@"adsdsd"));
    XCTAssertEqual(BBBPurchaseStatusPurchased, BBBPurchaseStatusFromString(@"PURCHASED"));
    XCTAssertEqual(BBBPurchaseStatusSampled, BBBPurchaseStatusFromString(@"SAMPLED"));
    BBB_ENABLE_ASSERTIONS();
}

- (void) testVisibilityStatusMappingFunction{
    BBB_DISABLE_ASSERTIONS();
    XCTAssertEqual(BBBVisiblityStatusUnknown, BBBVisibiliyStatusFromString(@"adsdsd"));
    XCTAssertEqual(BBBVisiblityStatusCurrent, BBBVisibiliyStatusFromString(@"CURRENT"));
    XCTAssertEqual(BBBVisiblityStatusArchived, BBBVisibiliyStatusFromString(@"ARCHIVED"));
    XCTAssertEqual(BBBVisiblityStatusDeleted, BBBVisibiliyStatusFromString(@"DELETED"));
    BBB_ENABLE_ASSERTIONS();
}

- (void) testReadingStatusToNSStringMappingFunction{

    XCTAssertEqualObjects(BBBNSStringFromBBBReadingStatus(BBBReadingStatusRead), @"FINISHED");
    XCTAssertEqualObjects(BBBNSStringFromBBBReadingStatus(BBBReadingStatusUnread), @"UNREAD");
    XCTAssertEqualObjects(BBBNSStringFromBBBReadingStatus(BBBReadingStatusReading), @"READING");

}

#pragma mark - Tests

- (void) testInit{
    XCTAssertNotNil(response);
}

- (void) testParsingValidDataReturnsSuccessAsReturnValue{
    XCTAssertTrue([response parseJSON:[self validDataThreeItems] error:nil]);
}

- (void) testNumberOfItemsCorrectSingle{
    [response parseJSON:[self validDataSingleItem]
                  error:nil];
    XCTAssertEqual([response.changes count], (NSUInteger)1);
}

- (void) testNumberOfItemsCorrectThree{
    [response parseJSON:[self validDataThreeItems]
                  error:nil];
    XCTAssertEqual([response.changes count], (NSUInteger)3);
}

- (void) testNumberOfItemsCorrectZero{
    [response parseJSON:[self validDataNoItems]
                  error:nil];
    XCTAssertNotNil(response.changes);
    XCTAssertEqual([response.changes count], (NSUInteger)0);
}

- (void) testISBNOfTheItem{
    [response parseJSON:[self validDataSingleItem]
                  error:nil];
    BBBLibraryItem *item = [response.changes firstObject];
    XCTAssertEqualObjects(item.isbn,@"9781472214119", @"isbn should be parsed");
}

- (void) testIdentifierOfTheItem{
    [response parseJSON:[self validDataSingleItem]
                  error:nil];
    BBBLibraryItem *item = [response.changes firstObject];
    XCTAssertEqualObjects(item.identifier,@"32060+34756", @"id should be parsed");
}

- (void) testMappingOfStatuses{
    [response parseJSON:[self validDataSingleItem]
                  error:nil];
    BBBLibraryItem *item = [response.changes firstObject];
    XCTAssertEqual(item.readingStatus, BBBReadingStatusReading);
    XCTAssertEqual(item.visibilityStatus, BBBVisiblityStatusCurrent);
    XCTAssertEqual(item.purchaseStatus, BBBPurchaseStatusPurchased);
}

- (void) testMappingOfPurchaseDate{

    NSDate *date = [self serverDateFromString:@"2014-05-06T18:28:28Z"];
    
    [response parseJSON:[self validDataSingleItem]
                  error:nil];
    
    BBBLibraryItem *item = [response.changes firstObject];
    XCTAssertNotNil(item.purchasedDate);
    XCTAssertTrue(ABS([date timeIntervalSinceDate:item.purchasedDate]) < 1.0,
                  @"purchased date %@ is not close to %@", date, item.purchasedDate);
}

- (void) testMappingDeletedDate{

    NSDate *date = [self serverDateFromString:@"2012-01-06T18:28:28Z"];
    
    [response parseJSON:[self validDataDeletedItem]
                  error:nil];
    
    BBBLibraryItem *item = [response.changes firstObject];
    XCTAssertNotNil(item.deletedDate);
    XCTAssertTrue(ABS([date timeIntervalSinceDate:item.deletedDate]) < 1.0,
                  @"deleted date %@ is not close to %@", date, item.deletedDate);
}

- (void) testMappingSampledDate{
    NSDate *date = [self serverDateFromString:@"2013-05-06T13:56:12Z"];
    
    [response parseJSON:[self validDataSampledItem]
                  error:nil];
    
    BBBLibraryItem *item = [response.changes firstObject];
    XCTAssertNotNil(item.sampledDate);
    XCTAssertTrue(ABS([date timeIntervalSinceDate:item.sampledDate]) < 1.0,
                  @"sampled date %@ is not close to %@", date, item.sampledDate);
}

- (void) testMappingArchivedDate{
    NSDate *date = [self serverDateFromString:@"2011-01-01T13:00:00Z"];
    
    [response parseJSON:[self validDataArchivedItem]
                  error:nil];
    
    BBBLibraryItem *item = [response.changes firstObject];
    XCTAssertNotNil(item.archivedDate);
    XCTAssertTrue(ABS([date timeIntervalSinceDate:item.archivedDate]) < 1.0,
                  @"archived date %@ is not close to %@", date, item.archivedDate);
}

- (void) testMappingNumbersOfDevices{

    [response parseJSON:[self validDataSingleItem]
                  error:nil];
    
    BBBLibraryItem *item = [response.changes firstObject];
    XCTAssertEqual(item.numberOfAuthorisedDevices, 1);
    XCTAssertEqual(item.maxNumberOfAuthorisedDevices, 5);
}

- (void) testNumberOfLinks{
    [response parseJSON:[self validDataSingleItem]
                  error:nil];
    BBBLibraryItem *item = [response.changes firstObject];
    XCTAssertEqual([item.links count],(NSUInteger)4, @"item should have 4 links");
}

- (void) testLinksData{
    [response parseJSON:[self validDataSingleItem]
                  error:nil];
    BBBLibraryItem *item = [response.changes firstObject];
    BBBLibraryItemLink *link = [item.links firstObject];

    XCTAssertEqualObjects(link.relationship, @"urn:blinkboxbooks:schema:book",
                          @"link relationship must be equal");
    
    XCTAssertEqualObjects(link.address, @"http://api.blinkboxbooks.com/service/catalogue/books/9781472214119",
                          @"link address must be equal");
    
    XCTAssertEqualObjects(link.title, @"Book",
                          @"link title must be equal");

}

- (void) testInvalidDataReturnsUnexpectedDataFormatError{
    
    BBB_DISABLE_ASSERTIONS();
    NSError *error;
    [response parseJSON:[self invalidData]
                  error:&error];
    
    XCTAssertEqual(error.code, BBBResponseMappingErrorUnexpectedDataFormat);
    XCTAssertEqualObjects(error.domain, BBBResponseMappingErrorDomain);
    BBB_ENABLE_ASSERTIONS();
}

- (void) testInvalidDataReturnsFalseAsReturnValue{
    
    BBB_DISABLE_ASSERTIONS();
    XCTAssertFalse([response parseJSON:[self invalidData] error:nil]);
    BBB_ENABLE_ASSERTIONS();
}

- (void) testParsingEmptyArchivedResponseDoesntThrow{
    XCTAssertNoThrow([response parseJSON:[self validEmptyArchivedResponse] error:nil],
                     @"parsing empty archive response should throw");
}

- (void) testParsingEmptyArchiveResponseReturnsEmptyArrayAndNilSyncDate{
    [response parseJSON:[self validEmptyArchivedResponse] error:nil];
    XCTAssertNotNil(response.changes, @"array should exist");
    XCTAssertEqual([response.changes count], (NSUInteger)0, @"empty array expected");
    XCTAssertNil(response.syncDate, @"sync date should be nil");
}

- (void) testParsingArchiveResponseParsesItemCorrectly{
    
    NSDate *archivedDate = [self serverDateFromString:@"2014-08-19T10:55:50Z"];
    NSDate *purchasedDate = [self serverDateFromString:@"2014-01-08T09:44:17Z"];
    
    [response parseJSON:[self validArchivedResponse] error:nil];
    NSArray *items = response.changes;
    XCTAssertEqual(items.count, (NSUInteger)1, @"one item in the response");
    BBBLibraryItem *item = [items firstObject];
    XCTAssertTrue([item isKindOfClass:[BBBLibraryItem class]], @"must be lib item");
    XCTAssertEqualObjects(item.isbn, @"9781451658866", @"ISBN must be parsed");
    XCTAssertEqualObjects(item.identifier, @"2070+2204", @"id must be parsed");
    XCTAssertEqual(item.visibilityStatus, BBBVisiblityStatusArchived, @"item is archived");
    XCTAssertTrue(ABS([item.archivedDate timeIntervalSinceDate:archivedDate]) < 1.0,
                  @"archived date must be parsed");
    XCTAssertTrue(ABS([item.purchasedDate timeIntervalSinceDate:purchasedDate]) < 1.0,
                  @"purchased date must be parsed");
    XCTAssertEqual(item.readingStatus, BBBReadingStatusRead, @"reading status must be parsed");
    XCTAssertEqual(item.purchaseStatus, BBBPurchaseStatusPurchased, @"purchased status must be parsed");
    XCTAssertEqual(item.links.count, (NSUInteger)4, @"4 links in the array");
    
}

- (void) testParsingArchivedResponseReturnsSuccess{
   BOOL status = [response parseJSON:[self validArchivedResponse] error:nil];
    XCTAssertTrue(status, @"should return success with valid archvied responses");
}

- (void) testParsingDeletedResponseDoesntThrow{
    XCTAssertNoThrow([response parseJSON:[self validDeletedResponse] error:nil],
                     @"shouldn't throw on valid deleted response from lib service");
}

- (void) testParsingDeletedResponseParsesResponseCorrectly{
    NSDate *deletedDate = [self serverDateFromString:@"2014-04-02T16:16:01Z"];
    NSDate *purchasedDate = [self serverDateFromString:@"2014-01-27T15:09:52Z"];
    
    [response parseJSON:[self validDeletedResponse] error:nil];
    NSArray *items = [response changes];
    XCTAssertEqual(items.count, (NSUInteger)2, @"should produce two items");
    
    BBBLibraryItem *item = items[1];
    XCTAssertTrue([item isKindOfClass:[BBBLibraryItem class]], @"must be lib item");
    XCTAssertEqualObjects(item.isbn, @"9780007453597", @"ISBN must be parsed");
    XCTAssertEqualObjects(item.identifier, @"2725+3021", @"id must be parsed");
    XCTAssertEqual(item.visibilityStatus, BBBVisiblityStatusDeleted, @"item is archived");
    XCTAssertTrue(ABS([item.deletedDate timeIntervalSinceDate:deletedDate]) < 1.0,
                  @"archived date must be parsed");
    XCTAssertTrue(ABS([item.purchasedDate timeIntervalSinceDate:purchasedDate]) < 1.0,
                  @"purchased date must be parsed");
    XCTAssertEqual(item.readingStatus, BBBReadingStatusReading, @"reading status must be parsed");
    XCTAssertEqual(item.purchaseStatus, BBBPurchaseStatusSampled, @"purchased status must be parsed");
    XCTAssertEqual(item.links.count, (NSUInteger)2, @"2 links in the array");
}

- (void) testParsingDeletedResponseReturnsSuccess{
    BOOL status = [response parseJSON:[self validDeletedResponse] error:nil];
    XCTAssertTrue(status, @"should return success with valid deleted responses");
}

- (void) testParsingDataWithInvalidTypeRetunsFalseAndProducesError{
    BBB_DISABLE_ASSERTIONS();
    NSError *error;
    BOOL status = [response parseJSON:[self invalidDataType]
                                error:&error];
    XCTAssertFalse(status, @"should return NO");
    XCTAssertEqual(error.code, BBBResponseMappingErrorUnexpectedDataFormat, @"unexpected data fornat");
    XCTAssertEqualObjects(error.domain, BBBResponseMappingErrorDomain, @"response mapping domain");
    BBB_ENABLE_ASSERTIONS();
}

#pragma mark - Test data generation

- (id) validDataSingleItem{
    return [self validTestDataFromFile:@"libResponse_single_item_purchased.json"];
}

- (id) validDataThreeItems{
    return [self validTestDataFromFile:@"libResponse.json"];
}

- (id) validDataNoItems{
    return [self validTestDataFromFile:@"libResponse_no_items.json"];
}

- (id) validDataArchivedItem{
    return [self validTestDataFromFile:@"libResponse_single_item_archived.json"];
}

- (id) validDataDeletedItem{
    return [self validTestDataFromFile:@"libResponse_single_item_deleted.json"];
}

- (id) validDataSampledItem{
    return [self validTestDataFromFile:@"libResponse_single_item_sampled.json"];
}

- (id) validEmptyArchivedResponse{
    return [self validTestDataFromFile:@"libResponse_empty_archived.json"];
}

- (id) validArchivedResponse{
    return [self validTestDataFromFile:@"libResponse_archived.json"];
}

- (id) validDeletedResponse{
    return [self validTestDataFromFile:@"libResponse_deleted.json"];
}

- (id) invalidData{
    return [self validTestDataFromFile:@"libResponse_invalid_data_format.json"];
}

- (id) invalidDataType{
    return [self validTestDataFromFile:@"libResponse_invalid_type.json"];
}

- (id) validTestDataFromFile:(NSString *)fileName{
    NSData *data = [BBBTestHelper dataForTestBundleFileNamed:fileName
                                                forTestClass:[self class]];
    
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

#pragma mark - Helpers

- (NSDate *) serverDateFromString:(NSString *)string{
    NSDateFormatter *formatter = [BBBServerDateFormatter new];
    NSDate *date = [formatter dateFromString:string];
    return date;
}

@end