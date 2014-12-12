//
//  BBACatalogueResponseMapper.m
//  BBBAPI
//
//  Created by Tomek Kuźma on 11/12/2014.
//  Copyright (c) 2014 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBACatalogueResponseMapper.h"
#import "BBABookItem.h"
#import "BBALinkItem.h"
#import "BBABooksMapper.h"

static NSString *const kListType = @"urn:blinkboxbooks:schema:list";
static NSString *const kSynopsisType = @"urn:blinkboxbooks:schema:synopsis";

@interface BBACatalogueResponseMapper ()
@property (strong, nonatomic) BBABooksMapper *bookMapper;
@end

@implementation BBACatalogueResponseMapper

#pragma mark - BBAResponseMapping

- (id) responseFromData:(NSData *)data
               response:(NSURLResponse *)response
                  error:(NSError **)error{
    id object = [super responseFromData:data response:response error:error];
    NSAssert(object, @"cant parse JSON");
    if (!object) {
        return nil;
    }
    
    if (![object isKindOfClass:[NSDictionary class]]) {
        NSAssert(NO, @"wrong data type");
        [self wrongDataError:error];
        return nil;
    }
    
    NSDictionary *dictionary = (NSDictionary *)object;
    
    NSString *type = dictionary[@"type"];
    
    if ([type isEqualToString:kListType]) {
        return [self listResponseFromList:dictionary[@"items"] error:error];
    }
    else if ([type isEqualToString:kSynopsisType]){
        return [self synopsisResponseFromDictionary:dictionary[@"items"] error:error];
    }
    else{
        [self wrongDataError:error];
    }
    NSAssert(NO, @"wrong data type");
    return nil;
}

#pragma mark - Private

- (NSArray *) listResponseFromList:(NSArray *)array
                             error:(NSError **)error{
    
    NSMutableArray *items = [NSMutableArray new];
    for (id object in array) {
        BBABookItem *item = [self.bookMapper itemFromDictionary:object];
        if (!item) {
            continue;
        }
        
        [items addObject:item];
    }
    return array;;
}

- (BBABookItem *) synopsisResponseFromDictionary:(NSDictionary *)dictionary
                                              error:(NSError **)error{
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        [self wrongDataError:error];
        return nil;
    }
    NSString *isbn = dictionary[@"id"];
    NSString *text = dictionary[@"text"];
    
    if (!isbn || !text) {
        [self wrongDataError:error];
        return nil;
    }
    
    BBABookItem *item = [BBABookItem new];
    item.identifier = isbn;
    item.synopsis = text;
    return item;
}

- (void) wrongDataError:(NSError **)error{
    if (error != nil) {
        *error = [NSError errorWithDomain:BBAResponseMappingErrorDomain
                                     code:BBAResponseMappingErrorUnreadableData
                                 userInfo:nil];
    }
}

@end
