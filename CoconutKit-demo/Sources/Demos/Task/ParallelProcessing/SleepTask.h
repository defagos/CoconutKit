//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

NS_ASSUME_NONNULL_BEGIN

@interface SleepTask : HLSTask

- (instancetype)initWithSecondsToSleep:(NSUInteger)secondsToSleep;

@property (nonatomic) NSUInteger secondsToSleep;

@end

NS_ASSUME_NONNULL_END
