//
//  BBASearchServiceBook.h
//  BBBAPI
//
//  Created by Owen Worley on 09/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FEMObjectMapping;
/**
 *  Represents a book returned by the search service
 */
@interface BBASearchServiceBook : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSArray *authors;

/**
 *  Object mapping to convert server data to object respresentation
 */
+ (FEMObjectMapping *) objectMapping;
@end
