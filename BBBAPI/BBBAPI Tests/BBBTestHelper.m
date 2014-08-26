//
//  BBBTestHelper.m
//  BBBIosApp
//
//  Created by Owen Worley on 17/04/2014.
//  Copyright (c) 2014 blinkbox Entertainment Ltd. All rights reserved.
//

#import "BBBTestHelper.h"

@implementation BBBTestHelper

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

@end
