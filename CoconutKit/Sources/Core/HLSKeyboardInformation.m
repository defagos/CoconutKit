//
//  HLSKeyboardInformation.m
//  CoconutKit
//
//  Created by Samuel Défago on 2/17/11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSKeyboardInformation.h"

#import "HLSAssert.h"
#import "HLSLogger.h"

@interface HLSKeyboardInformation ()

@property (nonatomic, assign) CGRect beginFrame;
@property (nonatomic, assign) CGRect endFrame;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) UIViewAnimationCurve animationCurve;

@end

static HLSKeyboardInformation *s_instance = nil;

@implementation HLSKeyboardInformation

#pragma mark Class methods

+ (HLSKeyboardInformation *)keyboardInformation
{
    return s_instance;
}

#pragma mark Object creation and destruction

- (id)initWithUserInfo:(NSDictionary *)userInfo
{
    if ((self = [super init])) {
        self.beginFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        self.endFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        self.animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        self.animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntValue];
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

#pragma mark Notification callbacks

+ (void)keyboardWillShow:(NSNotification *)notification
{
    HLSLoggerDebug(@"Keyboard shown");
    s_instance = [[HLSKeyboardInformation alloc] initWithUserInfo:[notification userInfo]];
}

+ (void)keyboardWillHide:(NSNotification *)notification
{
    HLSLoggerDebug(@"Keyboard hidden");
    s_instance = nil;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; beginFrame: %@; endFrame: %@; animationDuration: %f>",
            [self class],
            self,
            NSStringFromCGRect(self.beginFrame),
            NSStringFromCGRect(self.endFrame),
            self.animationDuration];
}

@end

__attribute__ ((constructor)) static void HLSKeyboardInformationInit(void)
{
    // Register for keyboard notifications. Note that when the keyboard is visible and the device is rotated,
    // we get a hide and a show notifications (keyboard with first orientation is dismissed, keyboard with
    // new orientation is displayed again)
    [[NSNotificationCenter defaultCenter] addObserver:[HLSKeyboardInformation class]
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[HLSKeyboardInformation class]
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
