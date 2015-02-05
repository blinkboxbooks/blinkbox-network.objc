//
//  BBASuggestionItem.h
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 12/01/2015.
//  Copyright (c) 2015 Blinkbox Entertainment Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BBASuggestionType) {
    BBASuggestionTypeBook = 0,
    BBASuggestionTypeAuthor = 1,
};

@class FEMObjectMapping;
/**
 *  Represents a search service suggestion
 */
@interface BBASuggestionItem : NSObject

@property (nonatomic, assign) BBASuggestionType type;
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
