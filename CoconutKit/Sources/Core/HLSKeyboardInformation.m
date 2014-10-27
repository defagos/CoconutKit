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

// FIXME: There is a bug with keyboard undocking in iOS 8 / 8.1 (the UIKeyboardWill/DidHideNotification are not sent correctly
//        when the keyboard is undocked). See http://openradar.appspot.com/18010127. Remove all code below when this has been
//        fixed and CoconutKit minimum required OS version includes the bug fix
//
//
//        Analysis:
//
//        -postStartNotifications:withInfo: is called with value = 1 when the keyboard is moved, whether it is docked or not. Sadly,
//        the result is therefore the same in both cases: Only the frame change notification is sent, the hide notification is
//        therefore not received if the keyboard gets undocked as a result of the keyboard being moved.
//
//        When undocking the keyboard by long pressing the keyboard button, the -postStartNotifications:withInfo: is called with
//        value = 3 and both notifications are correctly received.
//
//        To fix this annoying bug until Apple takes care of it, we therefore check whether the keyboard is docked when it is
//        moved, and in this case call the method with value = 3 instead
//

typedef NS_ENUM(NSInteger, UIInputWindowNotificationMode) {
    UIInputWindowNotificationModeMoving = 1,
    UIInputWindowNotificationModeDocking = 2,
    UIInputWindowNotificationModeUndocking = 3
};

static void (*s_UIInputWindowController__postStartNotifications_withInfo_Imp)(id, SEL, UIInputWindowNotificationMode, id) = NULL;
static void (*s_UIInputWindowController__postEndNotifications_withInfo_Imp)(id, SEL, UIInputWindowNotificationMode, id) = NULL;

@protocol HLSUIInputWindowController <NSObject>

- (BOOL)isUndocked;

@end

static void swizzled_UIInputWindowController__postStartNotifications_withInfo(id<HLSUIInputWindowController> self,
                                                                              SEL _cmd,
                                                                              UIInputWindowNotificationMode mode,
                                                                              id info /* UIInputViewSetNotificationInfo */)
{
    if (mode == UIInputWindowNotificationModeMoving && ! [self isUndocked]) {
        (*s_UIInputWindowController__postStartNotifications_withInfo_Imp)(self, _cmd, UIInputWindowNotificationModeUndocking, info);
    }
    else {
        (*s_UIInputWindowController__postStartNotifications_withInfo_Imp)(self, _cmd, mode, info);
    }
}

static void swizzled_UIInputWindowController__postEndNotifications_withInfo(id<HLSUIInputWindowController> self,
                                                                            SEL _cmd,
                                                                            UIInputWindowNotificationMode mode,
                                                                            id info /* UIInputViewSetNotificationInfo */)
{
    if (mode == UIInputWindowNotificationModeMoving && ! [self isUndocked]) {
        (*s_UIInputWindowController__postEndNotifications_withInfo_Imp)(self, _cmd, UIInputWindowNotificationModeUndocking, info);
    }
    else {
        (*s_UIInputWindowController__postEndNotifications_withInfo_Imp)(self, _cmd, mode, info);
    }
}

@interface UIInputWindowControllerFixes : NSObject

@end

@implementation UIInputWindowControllerFixes

+ (void)load
{
    // TODO: Bug at least on iOS 8 and iOS 8.1. Will hopefully be fixed in 8.2, extend version range if not the case
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 && NSFoundationVersionNumber <= 1141.100000 /* iOS 8.1 */) {
        s_UIInputWindowController__postStartNotifications_withInfo_Imp = (void (*)(id, SEL, UIInputWindowNotificationMode, id))hls_class_swizzleSelector(NSClassFromString(@"UIInputWindowController"),
                                                                                                                                                         NSSelectorFromString(@"postStartNotifications:withInfo:"),
                                                                                                                                                         (IMP)swizzled_UIInputWindowController__postStartNotifications_withInfo);
        s_UIInputWindowController__postEndNotifications_withInfo_Imp = (void (*)(id, SEL, UIInputWindowNotificationMode, id))hls_class_swizzleSelector(NSClassFromString(@"UIInputWindowController"),
                                                                                                                                                       NSSelectorFromString(@"postEndNotifications:withInfo:"),
                                                                                                                                                       (IMP)swizzled_UIInputWindowController__postEndNotifications_withInfo);
    }
}

@end
