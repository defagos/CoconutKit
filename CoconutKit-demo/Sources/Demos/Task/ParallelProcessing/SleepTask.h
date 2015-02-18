//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

@interface SleepTask : HLSTask

- (instancetype)initWithSecondsToSleep:(NSUInteger)secondsToSleep;

- (NSUInteger)secondsToSleep;

@end
