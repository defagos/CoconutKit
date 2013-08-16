//
//  HLSApplicationLock.m
//  CoconutKit
//
//  Created by Samuel Défago on 11/15/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSApplicationLock.h"

#import "HLSLogger.h"

@implementation HLSApplicationLock {
@private
    NSUInteger _userInteractionLockCount;
    NSUInteger _animationLockCount;
}

#pragma mark Class methods

+ (HLSApplicationLock *)sharedApplicationLock
{
    static HLSApplicationLock *s_instance = nil;
    
    if (! s_instance) {
        s_instance = [[HLSApplicationLock alloc] init];
    }
    return s_instance;
}

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        _userInteractionLockCount = 0;
        _animationLockCount = 0;
    }
    return self;
}

#pragma mark Locking and unlocking

- (void)lockUserInteractions
{    
    ++_userInteractionLockCount;
    HLSLoggerDebug(@"Acquire UI lock");
    
    if (_userInteractionLockCount == 1) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }
}

- (void)unlockUserInteractions
{
    // Check that the UI was locked
    if (_userInteractionLockCount == 0) {
        HLSLoggerDebug(@"The UI was not locked, nothing to unlock");
        return;
    }
    
    --_userInteractionLockCount;
    HLSLoggerDebug(@"Release UI lock");
    
    if (_userInteractionLockCount == 0) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

- (void)lockAnimations
{
    ++_animationLockCount;
    HLSLoggerDebug(@"Acquire animation lock");
    
    if (_animationLockCount == 1) {
        [UIView setAnimationsEnabled:NO];
    }
}

- (void)unlockAnimations
{
    // Check that the animations were locked
    if (_animationLockCount == 0) {
        HLSLoggerDebug(@"Animations were not locked, nothing to unlock");
        return;
    }
    
    --_animationLockCount;
    HLSLoggerDebug(@"Release animation lock");
    
    if (_animationLockCount == 0) {
        [UIView setAnimationsEnabled:YES];
    }
}

@end
