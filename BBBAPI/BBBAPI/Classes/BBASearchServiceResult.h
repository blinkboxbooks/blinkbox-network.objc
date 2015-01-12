//
//  BBASearchServiceResult.h
//  BBBAPI
//
//  Created by Owen Worley on 12/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FastEasyMapping/FastEasyMapping.h>
/**
 *  Represents data provided from the search service when searching for books
 */
@interface BBASearchServiceResult : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSArray *links;
@property (nonatomic, assign) NSInteger numberOfResults;
@property (nonatomic, copy) NSArray *books;

/**
 *  Object mapping to convert server search result to `BBASearchServiceResult`
 */
+ (FEMObjectMapping *) searchServiceResultMapping;
@end
