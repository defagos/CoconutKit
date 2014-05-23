//
//  SleepTask.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "SleepTask.h"

#import "SleepTaskOperation.h"

@implementation SleepTask {
@private
    NSUInteger _secondsToSleep;
}

#pragma mark Object creation and destruction

- (id)initWithSecondsToSleep:(NSUInteger)secondsToSleep
{
    if ((self = [super init])) {
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
