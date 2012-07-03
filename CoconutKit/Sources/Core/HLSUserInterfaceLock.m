//
//  HLSUserInterfaceLock.m
//  CoconutKit
//
//  Created by Samuel Défago on 11/15/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSLogger.h"
#import "HLSNotifications.h"
#import "HLSUserInterfaceLock.h"

@interface HLSUserInterfaceLock ()

@property (nonatomic, retain) UIView *modalView;

@end

@implementation HLSUserInterfaceLock

#pragma mark Class methods

+ (HLSUserInterfaceLock *)sharedUserInterfaceLock
{
    static HLSUserInterfaceLock *s_instance = nil;
    
    if (! s_instance) {
        s_instance = [[HLSUserInterfaceLock alloc] init];
    }
    return s_instance;
}

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        m_useCount = 0;
    }
    return self;
}

- (void)dealloc
{
    self.modalView = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize modalView = m_modalView;

#pragma mark Locking and unlocking user interaction

- (void)lock
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (! window) {
        HLSLoggerWarn(@"No key window defined when trying to acquire interface lock; please ensure that the UIWindow "
                      "-makeKeyAndVisible or -makeKeyWindow methods have been called (e.g. by implementing the "
                      "-application:didFinishLaunchingWithOptions: method and ensuring that either -makeKeyAndVisible "
                      "or -makeKeyWindow are called as early as possible, at the top of the method implementation)");
        return;
    }
    
    ++m_useCount;
    HLSLoggerDebug(@"Acquiring UI lock");
    
    if (m_useCount == 1) {
        // Prevents user interaction using a modal transparent view covering the whole screen. To get modal-like behavior 
        // for views, it suffices to add them as subviews of window, blocking interaction with the root application view
        // (usually the only child view of window)
        self.modalView = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
        // Use color with alpha = 0 to get transparency while keeping the view alive (i.e. interactive). If the alpha
        // view property is set to 0, the view is like removed and unable to trap clicks
        self.modalView.backgroundColor = [UIColor clearColor];
        [window addSubview:self.modalView];
    }
}

- (void)unlock
{
    // Check that the UI was locked
    if (m_useCount == 0) {
        HLSLoggerDebug(@"The UI was not locked, nothing to unlock");
        return;
    }
    
    --m_useCount;
    HLSLoggerDebug(@"Release UI lock");
    
    if (m_useCount == 0) {
        // Removes the modal-like view
        [self.modalView removeFromSuperview];
        self.modalView = nil;
    }
}

@end
