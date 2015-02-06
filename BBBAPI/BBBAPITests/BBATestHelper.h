//
//  BBATestHelper.h
//  BBAIosApp
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 17/04/2014.
  

#import <Foundation/Foundation.h>

@interface BBATestHelper : NSObject

/**
 *  Return the contents of a resource from the Tests target as `NSData`
 *
 *  @param testBundleFileName The name of the file, e.g. mockdata.txt
 *  @param testClass The Class that this request originates, in most cases, passing
 *  [self class] is sufficient.
 *
 *  @return `NSData` containing the contents of the file
 */
+ (NSData *) dataForTestBundleFileNamed:(NSString*)testBundleFileName
                          forTestClass:(Class)testClass;

/**
 *  Return the URL of a resource from the Tests target.
 *
 *  @param fileName  The name of the file, e.g. mockdata.txt
 *  @param testClass The Class that this request originates, in most cases, passing
 *  [self class] is sufficient.
 *
 *  @return An `NSURL` containing the absolute path of the resource
 */
+ (NSURL *) absoluteURLForTestBundleFileNamed:(NSString *)fileName
                                 forTestClass:(Class)testClass;

/**
 *  Converts the provided `NSDate` into global time (UTC)
 *
 *  @param date `NSDate` in local time
 *
 *  @return `NSDate` in UTC
 */
+ (NSDate *) globalTimeDateForDate:(NSDate *)date;
@end
