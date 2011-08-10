//
//  HLSKeyboardInformation.m
//  CoconutKit
//
//  Created by Samuel Défago on 2/17/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSKeyboardInformation.h"

#import "HLSAssert.h"
#import "HLSLogger.h"

@interface HLSKeyboardInformation ()

@property (nonatomic, assign) CGRect beginFrame;
@property (nonatomic, assign) CGRect endFrame;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) UIViewAnimationCurve animationCurve;

+ (void)keyboardWillShow:(NSNotification *)notification;
+ (void)keyboardWillHide:(NSNotification *)notification;

@end

static HLSKeyboardInformation *s_instance = nil;

@implementation HLSKeyboardInformation

#pragma mark Class methods

+ (void)load
{
    // Register for keyboard notifications. Note that when the keyboard is visible and the device is rotated,
    // we get a hide and a show notifications (keyboard with first orientation is dismissed, keyboard with
    // new orientation is displayed again)
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
}

+ (HLSKeyboardInformation *)keyboardInformation
{
    return s_instance;
}

#pragma mark Object creation and destruction

- (id)initWithUserInfo:(NSDictionary *)userInfo
{
    if ((self = [super init])) {
        NSValue *beginFrameValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
        CGRect beginFrame = CGRectZero;
        [beginFrameValue getValue:&beginFrame];
        self.beginFrame = beginFrame;
        
        NSValue *endFrameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect endFrame = CGRectZero;
        [endFrameValue getValue:&endFrame];
        self.endFrame = endFrame;
        
        NSNumber *animationDurationNumber = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        self.animationDuration = [animationDurationNumber doubleValue];
        
        NSNumber *animationCurveNumber = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
        self.animationCurve = [animationCurveNumber unsignedIntValue];
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

#pragma mark Accessors and mutators

@synthesize beginFrame = m_beginFrame;

@synthesize endFrame = m_endFrame;

@synthesize animationDuration = m_animationDuration;

@synthesize animationCurve = m_animationCurve;

#pragma mark Notification callbacks

+ (void)keyboardWillShow:(NSNotification *)notification
{
    HLSLoggerDebug(@"Keyboard shown");
    s_instance = [[HLSKeyboardInformation alloc] initWithUserInfo:[notification userInfo]];
}

+ (void)keyboardWillHide:(NSNotification *)notification
{
    HLSLoggerDebug(@"Keyboard hidden");
    [s_instance release];
    s_instance = nil;
}

@end
