//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SleepTask.h"

#import "SleepTaskOperation.h"

@implementation SleepTask {
@private
    NSUInteger _secondsToSleep;
}

#pragma mark Object creation and destruction

- (instancetype)initWithSecondsToSleep:(NSUInteger)secondsToSleep
{
    if (self = [super init]) {
        _secondsToSleep = secondsToSleep;
    }
    return self;
}

#pragma mark Accessors and mutators

- (Class)operationClass
{
    return [SleepTaskOperation class];
}

- (NSUInteger)secondsToSleep
{
    return _secondsToSleep;
}

@end
