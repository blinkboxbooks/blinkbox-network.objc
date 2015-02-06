//
//  BBALinkItem.h
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 09/12/2014.
  

#import <Foundation/Foundation.h>

@class FEMObjectMapping;

/**
 *  `BBALinkItem` provides a data representation of a link present in various responses form the service.
 *  Services like Bookmarks and Catalogue can use this as part of deserialisation.
 */
@interface BBALinkItem : NSObject

@property (nonatomic, copy) NSString *rel;
@property (nonatomic, copy) NSString *href;
@property (nonatomic, copy) NSString *targetGuid;
@property (nonatomic, copy) NSString *title;

/**
 *  Returns a `FEMObjectMapping` to map external data representation to a `BBALinkItem`
 *
 *  @return `FEMObjectMapping` describing the mapping between JSON data and `BBALinkItem` objects.
 */
+ (FEMObjectMapping *) linkItemMapping;
@end
