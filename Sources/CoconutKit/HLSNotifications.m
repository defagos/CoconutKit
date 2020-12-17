//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSNotifications.h"

#import "HLSLogger.h"

@import UIKit;

@implementation HLSNotificationManager  {
@private
    NSUInteger _networkActivityCount;
}

#pragma mark Class methods

+ (HLSNotificationManager *)sharedNotificationManager
{
    static HLSNotificationManager *s_instance = nil;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_instance = [[[self class] alloc] init];
    });
    return s_instance;
}

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        _networkActivityCount = 0;
    }
    return self;
}

#pragma mark Activity notification

- (void)notifyBeginNetworkActivity
{
    ++_networkActivityCount;
    
    HLSLoggerDebug(@"Network activity counter is now %@", @(_networkActivityCount));
    
    if (_networkActivityCount == 1) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

- (void)notifyEndNetworkActivity
{
    if (_networkActivityCount == 0) {
        HLSLoggerWarn(@"Warning: Notifying the end of a network activity which has not been started");
        return;
    }
    
    --_networkActivityCount;
    
    HLSLoggerDebug(@"Network activity counter is now %@", @(_networkActivityCount));
    
    if (_networkActivityCount == 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;        
    }
}

@end

#pragma mark NSObject extensions

@implementation NSObject (HLSNotificationExtensions)

- (void)postCoalescingNotificationWithName:(NSString *)name userInfo:(NSDictionary *)userInfo
{
    NSNotification *notification = [NSNotification notificationWithName:name 
                                                                 object:self
                                                               userInfo:userInfo];
    [[NSNotificationQueue defaultQueue] enqueueNotification:notification
                                               postingStyle:NSPostNow
                                               coalesceMask:NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender
                                                   forModes:nil];
}

- (void)postCoalescingNotificationWithName:(NSString *)name
{
    [self postCoalescingNotificationWithName:name userInfo:nil];
}

@end

#pragma mark NSNotificationCenter extensions

@implementation NSNotificationCenter (HLSNotificationExtensions)

- (void)addObserver:(id)observer selector:(SEL)selector name:(NSString *)name objectsInCollection:(id<NSFastEnumeration>)collection
{
    for (id object in collection) {
        [self addObserver:observer selector:selector name:name object:object];
    }
}

// FIXME: Warning! Does not work correctly for dictionaries (should iterate over the values, not the keys, which is the default
//        for each behavior for dictionaries)
- (void)removeObserver:(id)observer name:(NSString *)name objectsInCollection:(id<NSFastEnumeration>)collection
{
    for (id object in collection) {
        [self removeObserver:observer name:name object:object];
    }
}

@end
