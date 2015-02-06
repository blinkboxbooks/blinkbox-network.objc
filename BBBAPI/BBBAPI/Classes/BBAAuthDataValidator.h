//
//  BBAAuthDataValidator.h
//  BBAAPI
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 12/08/2014.
 

#import <Foundation/Foundation.h>
@class BBAAuthData;
@interface BBAAuthDataValidator : NSObject

- (BOOL) isValid:(BBAAuthData *)data forResponse:(NSURLResponse *)response;

@end