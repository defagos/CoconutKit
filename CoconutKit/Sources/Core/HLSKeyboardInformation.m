//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSKeyboardInformation.h"

#import "HLSLogger.h"

@interface HLSKeyboardInformation ()

@property (nonatomic) CGRect beginFrame;
@property (nonatomic) CGRect endFrame;
@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic) UIViewAnimationCurve animationCurve;

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
        self.beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        self.endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        self.animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        self.animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntValue];
    }
    return self;
}

#pragma mark Notification callbacks

+ (void)keyboardWillShow:(NSNotification *)notification
{
    HLSLoggerDebug(@"Keyboard will show");
    s_instance = [[HLSKeyboardInformation alloc] initWithUserInfo:notification.userInfo];
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
    s_instance = [[HLSKeyboardInformation alloc] initWithUserInfo:notification.userInfo];
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
