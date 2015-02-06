//
//  BBAImageItem.h
//  BBBAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 12/12/2014.
  

#import <Foundation/Foundation.h>

/**
 *  Represents image link
 */
@interface BBAImageItem : NSObject


@property (nonatomic, copy) NSString *relative;
/**
 *  URL of the given image
 */
@property (nonatomic, strong) NSURL *url;

@end
