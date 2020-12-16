//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSViewTouchDetector.h"

@interface HLSViewTouchDetector ()

@property (nonatomic, weak) UIView *view;               // weak ref. Detector lifetime is managed by the text field
@property (nonatomic) UIGestureRecognizer *gestureRecognizer;

@end

@implementation HLSViewTouchDetector

#pragma mark Object creation and destruction

- (instancetype)initWithView:(UIView *)view beginNotificationName:(NSString *)beginNotificationName endNotificationName:(NSString *)endNotificationName
{
    NSParameterAssert(view);
    NSParameterAssert(beginNotificationName);
    NSParameterAssert(endNotificationName);
    
    if (self = [super init]) {
        self.view = view;
        
        // Create a gesture recognizer capturing taps on the whole window
        self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard:)];
        self.gestureRecognizer.cancelsTouchesInView = NO;       // Let the taps go through
        self.gestureRecognizer.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewDidBeginEditing:)
                                                     name:beginNotificationName
                                                   object:view];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(viewDidEndEditing:)
                                                     name:endNotificationName
                                                   object:view];
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return [self initWithView:[UIView new] beginNotificationName:@"" endNotificationName:@""];
}

- (void)dealloc
{
    [[UIApplication sharedApplication].keyWindow removeGestureRecognizer:self.gestureRecognizer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UIGestureRecognizerDelegate protocol implementation

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	return ! [touch.view isDescendantOfView:self.view];
}

#pragma mark Notification callbacks

- (void)viewDidBeginEditing:(NSNotification *)notification
{
    [[UIApplication sharedApplication].keyWindow addGestureRecognizer:self.gestureRecognizer];
}

- (void)viewDidEndEditing:(NSNotification *)notification
{
    [[UIApplication sharedApplication].keyWindow removeGestureRecognizer:self.gestureRecognizer];
}

#pragma mark Event callbacks

- (void)dismissKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.resigningFirstResponderOnTap) {
        [self.view resignFirstResponder];
    }
}

@end
