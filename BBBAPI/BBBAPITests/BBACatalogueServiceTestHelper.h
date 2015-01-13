//
//  BBACatalogueServiceTestHelper.h
//  BBBAPI
//
//  Created by Tomek Kuźma on 12/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBACatalogueServiceTestHelper : NSObject
/**
 *  Helper method that returns 300 `BBABookItem` objects
 *
 *  @return array of `BBABookItem` objects with `identifier` property assigned to real ISBN
 */
+ (NSArray *)sampleBigRealItems;

/**
 *  Helper method that generates 150 `BBABookItem` objects
 *
 *  @return array of `BBABookItem` objects with `identifier` as integers from 1 to 151
 */
+ (NSArray *) sampleBigFakeItems;

/**
 *  This method generates sample response with ISBN's in the `range`
 *
 *  @param range range of isbns to generate response
 *
 *  @return sample response with correct structure as of catalogue service
 */
+ (NSDictionary *) sampleBigFakeResponseForRange:(NSRange)range;
@end
