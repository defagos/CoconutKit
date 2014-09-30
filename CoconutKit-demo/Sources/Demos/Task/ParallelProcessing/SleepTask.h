//
//  SleepTask.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

@interface SleepTask : HLSTask

- (instancetype)initWithSecondsToSleep:(NSUInteger)secondsToSleep;

- (NSUInteger)secondsToSleep;

@end
