//
//  BBASearchServiceSuggestion.h
//  BBBAPI
//
//  Created by Owen Worley on 12/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBASearchServiceBook.h"
@class FEMObjectMapping;
/**
 *  Represents a search service suggestion
 */
@interface BBASearchServiceSuggestion : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *identifier;
/**
 *  Contains NSString values
 */
@property (nonatomic, copy) NSArray *authors;

/**
 *  Object mapping to convert server data to object respresentation
 */
+ (FEMObjectMapping *) objectMapping;
@end
