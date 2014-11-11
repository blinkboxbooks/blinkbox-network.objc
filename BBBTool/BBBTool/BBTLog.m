//
//  BBTLog.m
//  BBBTool
//
//  Created by Owen Worley on 19/08/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import "BBTLog.h"
// print to stdout
void BBPrint(NSString *format, ...) {
    va_list args;
    va_start(args, format);

    NSString *string = [[NSString alloc] initWithFormat:format arguments:args];

    va_end(args);

    fprintf(stdout, "%s\n", [string UTF8String]);
}

// print to stderr
void BBPrintErr(NSString *format, ...) {
    va_list args;
    va_start(args, format);

    NSString *string = [[NSString alloc] initWithFormat:format arguments:args];

    va_end(args);

    fprintf(stderr, "%s\n", [string UTF8String]);
}
