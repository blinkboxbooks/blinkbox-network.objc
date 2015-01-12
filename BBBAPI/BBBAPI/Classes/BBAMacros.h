//
//  BBAMacros.h
//  BBAApp
//
//  Created by Owen Worley on 23/05/2014.
//  Copyright (c) 2014 blinkbox Entertainment Ltd. All rights reserved.
//

/**
 *  An INTERNAL_BUILD is a build that is either Debug, or not flagged as TARGET_RELEASE>
 *  At the time of writing, this will be any default dev local machine, Jenkins built (and Testflight) QA, Enterprise, but NOT App Store.
 */
#if DEBUG || TARGET_RELEASE!=TRUE
    #define INTERNAL_BUILD 1
#else
    #define INTERNAL_BUILD 0
#endif

#if !defined(NS_BLOCK_ASSERTIONS)

/**
 *  Use this macro instead of NSAssert inside blocks
 *  Source http://www.takingnotes.co/blog/2011/09/27/making-nsassert-play-nice-with-blocks/
 */
#define BBABlockAssert(condition, desc, ...) \
do {\
if (!(condition)) { \
[[NSAssertionHandler currentHandler] handleFailureInFunction:NSStringFromSelector(_cmd) \
file:[NSString stringWithUTF8String:__FILE__] \
lineNumber:__LINE__ \
description:(desc), ##__VA_ARGS__]; \
}\
} while(0);

#else // NS_BLOCK_ASSERTIONS defined

#define BBABlockAssert(condition, desc, ...)

#endif

/**
 *  Can be used to make code not stringly-typed and shorter, for example in 
 *  KVO, KVC, NSSortDescriptors, NSPredicates
 */
#define BBAKEY(val) NSStringFromSelector(@selector(val))
