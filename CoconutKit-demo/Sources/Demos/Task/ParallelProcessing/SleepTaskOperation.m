//
//  SleepTaskOperation.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "SleepTaskOperation.h"

#import "SleepTask.h"

@implementation SleepTaskOperation

- (void)operationMain
{
    SleepTask *sleepTask = (SleepTask *)self.task;
    
    for (NSUInteger i = 0; i < [sleepTask secondsToSleep] * 100; ++i) {
        // Check regularly if the task has been cancelled, and return ASAP
        if ([self isCancelled]) {
            return;
        }
        
        [NSThread sleepForTimeInterval:0.01];
        [self updateProgressToValue:(double)i / ([sleepTask secondsToSleep] * 100)];
    }
}

@end
