//
//  BBBTestMacros.h
//  BBBIosApp
//
//  Created by Owen Worley on 21/05/2014.
//  Copyright (c) 2014 blinkbox Entertainment Ltd. All rights reserved.
//

/*
 * Make it easier to perform tests on asynchronous methods that call back on the main queue.
 *
 * The basic flow for using these macros to test main queue callback operations is this:
 *
 * //Prepare the test:
 * BBB_PREPARE_ASYNC_TEST();
 *
 * //Call something with an async callback that calls back on the main queue, in the block, call BBB_FLAG_ASYNC_TEST_COMPLETE()
 * dispatch_async(dispatch_get_main_queue(), ^{
 *      BBB_FLAG_ASYNC_TEST_COMPLETE();
 * });
 *
 * //Now call this, it will spin the mainloop for the default `BBB_DEFAULT_WAIT_TIME` seconds.
 * BBB_WAIT_FOR_ASYNC_TEST();
 *
 *  If you need to test multiple async main queue operations, you may call BBB_RESET_ASYNC_TEST() as follows:
 *
 *
 *  //Reset the test state
 *  BBB_RESET_ASYNC_TEST();
 *
 * //Call something with an async callback that calls back on the main queue, in the block, call BBB_FLAG_ASYNC_TEST_COMPLETE()
 * dispatch_async(dispatch_get_main_queue(), ^{
 *      BBB_FLAG_ASYNC_TEST_COMPLETE();
 * });
 *
 * //Wait for second test
 * BBB_WAIT_FOR_ASYNC_TEST();
 */


/** The default amount of time to wait for the callback */
#define BBB_DEFAULT_WAIT_TIME 10

/**
 *  Prepare for unit testing an async method
 *
 */
#define BBB_PREPARE_ASYNC_TEST() __block BOOL callbackReceived = NO

/**
 *  Reset the state for testing an async method
 *
 */
#define BBB_RESET_ASYNC_TEST() callbackReceived = NO

/**
 *  Signal that a test has finished.
 *
 */
#define BBB_FLAG_ASYNC_TEST_COMPLETE() callbackReceived = YES

/**
 *  Wait for the boolean passes in to be YES or the time passed in to elapse.
 *  You are strongly recommended to call the convenience methods `BBB_WAIT_FOR_ASYNC_TEST` or
 *
 */
#define BBB_WAIT_FOR_CALLBACK_ARG_TIME(callbackReceivedArg, time, assertFlagged) {NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:time]; \
while (callbackReceivedArg == NO && [loopUntil timeIntervalSinceNow] > 0) { \
[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil]; \
} if(assertFlagged){XCTAssertTrue(callbackReceivedArg, @"Async operation was not completed");}}

/**
 *  Wait for the boolean passed in to be set to YES or for the `BBB_DEFAULT_WAIT_TIME` to elapse
 */
#define BBB_WAIT_FOR_CALLBACK_ARG(callbackReceivedArg) BBB_WAIT_FOR_CALLBACK_ARG_TIME(callbackReceivedArg,BBB_DEFAULT_WAIT_TIME, YES)

/**
 *  Wait for `BBB_FLAG_ASYNC_TEST_COMPLETE()` to be called or the time passed in to elapse
 */
#define BBB_WAIT_FOR_ASYNC_TEST_UNTIL(time) BBB_WAIT_FOR_CALLBACK_ARG_TIME(callbackReceived,time,YES)

/**
 *  Wait for `BBB_FLAG_ASYNC_TEST_COMPLETE()` to be called or the time passed in to elapse.
 *  We do not assert on whether the callback was received
 */
#define BBB_WAIT_FOR_ASYNC_TEST_UNTIL_DONT_VERIFY_CALLBACK(time) BBB_WAIT_FOR_CALLBACK_ARG_TIME(callbackReceived,time,NO)

/**
 *  Wait for `BBB_FLAG_ASYNC_TEST_COMPLETE()` to be called or the `BBB_DEFAULT_WAIT_TIME` to elapse
 */
#define BBB_WAIT_FOR_ASYNC_TEST() BBB_WAIT_FOR_CALLBACK_ARG_TIME(callbackReceived,BBB_DEFAULT_WAIT_TIME,YES)
/**
 *  Assert that `BBB_FLAG_ASYNC_TEST_COMPLETE()` was called before the timer elapsed
 */
#define BBBXCTAssertAsyncTestWasFlagged() XCTAssertTrue(callbackReceived, @"BBB_FLAG_ASYNC_TEST_COMPLETE() was not called before the timer elasped")

/**
 *  Assert that `BBB_FLAG_ASYNC_TEST_COMPLETE()` was NOT called before the timer elapsed
 */
#define BBBXCTAssertAsyncTestWasNotFlagged() XCTAssertFalse(callbackReceived, @"BBB_FLAG_ASYNC_TEST_COMPLETE() was called before the timer elapsed")

#define BBB_PREPARE_SEMAPHORE() dispatch_semaphore_t bbb_test_semaphore = dispatch_semaphore_create(0)
#define BBB_SIGNAL_SEMAPHORE() dispatch_semaphore_signal(bbb_test_semaphore)
#define BBB_WAIT_FOR_SEMAPHORE() {dispatch_time_t timeoutTime = dispatch_time(DISPATCH_TIME_NOW, BBB_DEFAULT_WAIT_TIME * NSEC_PER_SEC);\
                                 if (dispatch_semaphore_wait(bbb_test_semaphore, timeoutTime)) {\
                                     XCTFail(@"timed out waiting for bbb_test_semaphore");\
                                 }}\


/**
 *  This macro disables
 *
 */

#import "BBBMockAssertionHandler.h"

/**
 *  This macro disbles current's thread assertion handler by substituting a mocked one.
 *  This macro must be called together with the next one. and this pair must not be called more than once
 *
 */
#define BBB_DISABLE_ASSERTIONS() NSAssertionHandler *handler = [NSAssertionHandler currentHandler];\
[[NSThread currentThread] threadDictionary][NSAssertionHandlerKey] = [BBBMockAssertionHandler new]

/**
 *  This macro enables
 */
#define BBB_ENABLE_ASSERTIONS() {if(handler != nil){[[NSThread currentThread] threadDictionary][NSAssertionHandlerKey] = handler;}}
