//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
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
        
        // Simulate an error during the process (cannot wait more than 20 seconds, probably
        // not so patient)
        if (i >= 20 * 100) {
            NSError *error = [NSError errorWithDomain:@"domain" code:1012 userInfo:nil];
            [self attachError:error];
            return;
        }
        
        [NSThread sleepForTimeInterval:0.01];
        [self updateProgressToValue:(double)i / ([sleepTask secondsToSleep] * 100)];
    }
}

@end
