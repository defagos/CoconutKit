//
//  HLSKeyboardInformation.m
//  CoconutKit
//
//  Created by Samuel Défago on 2/17/11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSKeyboardInformation.h"

#import "HLSLogger.h"
#import "HLSRuntime.h"

// FIXME: There are serious bugs with the undocked keyboard in iOS 8 / 8.1:
//          - when undocked by dragging the keyboard upwards, the keyboard does not transition to undocked state. The
//            hide notifications are not received and, if you long-press the keyboard button, the keyboard can still
//            be undocked. The behavior is correct when the keyboard is undocked by long-pressing the keyboard button
//            and tapping Undock. See http://openradar.appspot.com/18010127.
//          - conversely, when the undocked keyboard is thrown against the bottom, depending on the velocity, show
//            notifications might be received or not
//          - when moving the undocked the keyboard to the top, the keyboard jumps everywhere like mad
//          - the keyboard background has a really weird behavior, sometimes appears and never disappears, sometimes
//            gets bigger and then suddenly smaller, etc.

@interface HLSKeyboardInformation ()

@property (nonatomic, assign) CGRect beginFrame;
@property (nonatomic, assign) CGRect endFrame;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) UIViewAnimationCurve animationCurve;

@end

static HLSKeyboardInformation *s_instance = nil;

@implementation HLSKeyboardInformation

#pragma mark Class methods

+ (instancetype)keyboardInformation
{
    return s_instance;
}

#pragma mark Object creation and destruction

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo
{
    if (self = [super init]) {
        self.beginFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        self.endFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        self.animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        self.animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntValue];
    }
    return self;
}

#pragma mark Notification callbacks

+ (void)keyboardWillShow:(NSNotification *)notification
{
    HLSLoggerDebug(@"Keyboard will show");
    s_instance = [[HLSKeyboardInformation alloc] initWithUserInfo:[notification userInfo]];
}

+ (void)keyboardWillHide:(NSNotification *)notification
{
    HLSLoggerDebug(@"Keyboard will hide");
    s_instance = nil;
}

#ifdef DEBUG

+ (void)keyboardDidShow:(NSNotification *)notification
{
    HLSLoggerDebug(@"Keyboard did show");
    s_instance = [[HLSKeyboardInformation alloc] initWithUserInfo:[notification userInfo]];
}

+ (void)keyboardDidHide:(NSNotification *)notification
{
    HLSLoggerDebug(@"Keyboard did hide");
}

+ (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    HLSLoggerDebug(@"Keyboard will change frame");
}

+ (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    HLSLoggerDebug(@"Keyboard did change frame");
}

#endif

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
    
#ifdef DEBUG
    [[NSNotificationCenter defaultCenter] addObserver:[HLSKeyboardInformation class]
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[HLSKeyboardInformation class]
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[HLSKeyboardInformation class]
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[HLSKeyboardInformation class]
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
#endif

}
