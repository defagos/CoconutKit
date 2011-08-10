//
//  SleepTask.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface SleepTask : HLSTask {
@private
    NSUInteger m_secondsToSleep;
}

- (id)initWithSecondsToSleep:(NSUInteger)secondsToSleep;

- (NSUInteger)secondsToSleep;

@end
