//
//  BBATestMacros.h
//  BBAIosApp
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
 * BBA_PREPARE_ASYNC_TEST();
 *
 * //Call something with an async callback that calls back on the main queue, in the block, call BBA_FLAG_ASYNC_TEST_COMPLETE()
 * dispatch_async(dispatch_get_main_queue(), ^{
 *      BBA_FLAG_ASYNC_TEST_COMPLETE();
 * });
 *
 * //Now call this, it will spin the mainloop for the default `BBA_DEFAULT_WAIT_TIME` seconds.
 * BBA_WAIT_FOR_ASYNC_TEST();
 *
 *  If you need to test multiple async main queue operations, you may call BBA_RESET_ASYNC_TEST() as follows:
 *
 *
 *  //Reset the test state
 *  BBA_RESET_ASYNC_TEST();
 *
 * //Call something with an async callback that calls back on the main queue, in the block, call BBA_FLAG_ASYNC_TEST_COMPLETE()
 * dispatch_async(dispatch_get_main_queue(), ^{
 *      BBA_FLAG_ASYNC_TEST_COMPLETE();
 * });
 *
 * //Wait for second test
 * BBA_WAIT_FOR_ASYNC_TEST();
 */


/** The default amount of time to wait for the callback */
#define BBA_DEFAULT_WAIT_TIME 10

/**
 *  Prepare for unit testing an async method
 *
 */
#define BBA_PREPARE_ASYNC_TEST() __block BOOL callbackReceived = NO

/**
 *  Reset the state for testing an async method
 *
 */
#define BBA_RESET_ASYNC_TEST() callbackReceived = NO

/**
 *  Signal that a test has finished.
 *
 */
#define BBA_FLAG_ASYNC_TEST_COMPLETE() callbackReceived = YES

/**
 *  Wait for the boolean passes in to be YES or the time passed in to elapse.
 *  You are strongly recommended to call the convenience methods `BBA_WAIT_FOR_ASYNC_TEST` or
 *
 */
#define BBA_WAIT_FOR_CALLBACK_ARG_TIME(callbackReceivedArg, time, assertFlagged) {NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:time]; \
while (callbackReceivedArg == NO && [loopUntil timeIntervalSinceNow] > 0) { \
[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil]; \
} if(assertFlagged){XCTAssertTrue(callbackReceivedArg, @"Async operation was not completed");}}

/**
 *  Wait for the boolean passed in to be set to YES or for the `BBA_DEFAULT_WAIT_TIME` to elapse
 */
#define BBA_WAIT_FOR_CALLBACK_ARG(callbackReceivedArg) BBA_WAIT_FOR_CALLBACK_ARG_TIME(callbackReceivedArg,BBA_DEFAULT_WAIT_TIME, YES)

/**
 *  Wait for `BBA_FLAG_ASYNC_TEST_COMPLETE()` to be called or the time passed in to elapse
 */
#define BBA_WAIT_FOR_ASYNC_TEST_UNTIL(time) BBA_WAIT_FOR_CALLBACK_ARG_TIME(callbackReceived,time,YES)

/**
 *  Wait for `BBA_FLAG_ASYNC_TEST_COMPLETE()` to be called or the time passed in to elapse.
 *  We do not assert on whether the callback was received
 */
#define BBA_WAIT_FOR_ASYNC_TEST_UNTIL_DONT_VERIFY_CALLBACK(time) BBA_WAIT_FOR_CALLBACK_ARG_TIME(callbackReceived,time,NO)

/**
 *  Wait for `BBA_FLAG_ASYNC_TEST_COMPLETE()` to be called or the `BBA_DEFAULT_WAIT_TIME` to elapse
 */
#define BBA_WAIT_FOR_ASYNC_TEST() BBA_WAIT_FOR_CALLBACK_ARG_TIME(callbackReceived,BBA_DEFAULT_WAIT_TIME,YES)
/**
 *  Assert that `BBA_FLAG_ASYNC_TEST_COMPLETE()` was called before the timer elapsed
 */
#define BBAXCTAssertAsyncTestWasFlagged() XCTAssertTrue(callbackReceived, @"BBA_FLAG_ASYNC_TEST_COMPLETE() was not called before the timer elasped")

/**
 *  Assert that `BBA_FLAG_ASYNC_TEST_COMPLETE()` was NOT called before the timer elapsed
 */
#define BBAXCTAssertAsyncTestWasNotFlagged() XCTAssertFalse(callbackReceived, @"BBA_FLAG_ASYNC_TEST_COMPLETE() was called before the timer elapsed")

#define BBA_PREPARE_SEMAPHORE() dispatch_semaphore_t BBA_test_semaphore = dispatch_semaphore_create(0)
#define BBA_SIGNAL_SEMAPHORE() dispatch_semaphore_signal(BBA_test_semaphore)
#define BBA_WAIT_FOR_SEMAPHORE() {dispatch_time_t timeoutTime = dispatch_time(DISPATCH_TIME_NOW, BBA_DEFAULT_WAIT_TIME * NSEC_PER_SEC);\
                                 if (dispatch_semaphore_wait(BBA_test_semaphore, timeoutTime)) {\
                                     XCTFail(@"timed out waiting for BBA_test_semaphore");\
                                 }}\

#define BBA_RESET_SEMAPHORE() BBA_test_semaphore = dispatch_semaphore_create(0)


/**
 *  This macro disables
 *
 */

#import "BBAMockAssertionHandler.h"

/**
 *  This macro disbles current's thread assertion handler by substituting a mocked one.
 *  This macro must be called together with the next one. and this pair must not be called more than once
 *
 */
#define BBA_DISABLE_ASSERTIONS() NSAssertionHandler *handler = [NSAssertionHandler currentHandler];\
[[NSThread currentThread] threadDictionary][NSAssertionHandlerKey] = [BBAMockAssertionHandler new]

/**
 *  This macro enables
 */
#define BBA_ENABLE_ASSERTIONS() {if(handler != nil){[[NSThread currentThread] threadDictionary][NSAssertionHandlerKey] = handler;}}
