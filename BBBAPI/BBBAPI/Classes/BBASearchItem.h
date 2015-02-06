//
//  BBASearchItem.h
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 09/01/2015.
  

#import <Foundation/Foundation.h>
@class FEMObjectMapping;
/**
 *  Represents a book returned by the search service
 */
@interface BBASearchItem : NSObject
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
