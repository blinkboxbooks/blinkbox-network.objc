//
//  BBATestHelper.m
//  BBAIosApp
//
// Created by Tomek Kuźma (mapedd@mapedd.com), Owen Worley (owen@owenworley.co.uk) & Eric Yuan (mbaeric@gmail.com) on 17/04/2014.
  

#import "BBATestHelper.h"

@implementation BBATestHelper

+ (NSURL *) absoluteURLForTestBundleFileNamed:(NSString *)fileName
                                 forTestClass:(Class)testClass {
    NSBundle *testBundle = [NSBundle bundleForClass:testClass];

    NSURL *fileURL = [testBundle URLForResource:[fileName stringByDeletingPathExtension]
                                   withExtension:[fileName pathExtension]];
    return fileURL;
}

+ (NSData *) dataForTestBundleFileNamed:(NSString*)testBundleFileName
                           forTestClass:(Class)testClass{


    NSURL *filePath = [self absoluteURLForTestBundleFileNamed:testBundleFileName
                                                 forTestClass:testClass];

    NSData *data = [NSData dataWithContentsOfURL:filePath];

    return data;
}

+ (NSDate *) globalTimeDateForDate:(NSDate *)date{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: date];
    return [NSDate dateWithTimeInterval: seconds sinceDate: date];
}
@end
