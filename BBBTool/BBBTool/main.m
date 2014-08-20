//
//  main.m
//  BBBTool
//
//  Created by Owen Worley on 18/08/2014.
//  Copyright (c) 2014 blinkbox books. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BBBAPI/BBBAPI.h>
#import "BBBTool.h"


int main(int argc, const char * argv[])
{

    @autoreleasepool {
        BBBTool *tool = [BBBTool new];
        [tool processArguments];
    }

    return 0;
}
