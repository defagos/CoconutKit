//
//  SleepTask.m
//  nut-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "SleepTask.h"

#import "SleepTaskOperation.h"

@implementation SleepTask

#pragma mark Object creation and destruction

- (id)initWithSecondsToSleep:(NSUInteger)secondsToSleep
{
    if (self = [super init]) {
        m_secondsToSleep = secondsToSleep;
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
    return m_secondsToSleep;
}

@end
