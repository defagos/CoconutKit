//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSUserInterfaceLock.h"

#import "HLSLogger.h"

#import <UIKit/UIKit.h>

@implementation HLSUserInterfaceLock {
@private
    NSUInteger _useCount;
}

#pragma mark Class methods

+ (HLSUserInterfaceLock *)sharedUserInterfaceLock
{
    static HLSUserInterfaceLock *s_instance = nil;
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
        _useCount = 0;
    }
    return self;
}

#pragma mark Locking and unlocking user interaction

- (void)lock
{    
    ++_useCount;
    HLSLoggerDebug(@"Acquire UI lock");
    
    if (_useCount == 1) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }
}

- (void)unlock
{
    // Check that the UI was locked
    if (_useCount == 0) {
        HLSLoggerDebug(@"The UI was not locked, nothing to unlock");
        return;
    }
    
    --_useCount;
    HLSLoggerDebug(@"Release UI lock");
    
    if (_useCount == 0) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

@end
