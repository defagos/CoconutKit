//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@interface SleepTask : HLSTask

- (instancetype)initWithSecondsToSleep:(NSUInteger)secondsToSleep;

- (NSUInteger)secondsToSleep;

@end
