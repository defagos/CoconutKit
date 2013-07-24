//
//  HLSViewTouchDetector.m
//  CoconutKit
//
//  Created by Samuel Défago on 24.07.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSViewTouchDetector.h"

@interface HLSViewTouchDetector ()

@property (nonatomic, assign) UIView *view;               // weak ref. Detector lifetime is managed by the text field
@property (nonatomic, retain) UIGestureRecognizer *gestureRecognizer;

@end

@implementation HLSViewTouchDetector

#pragma mark Object creation and destruction

- (id)initWithView:(UIView *)view beginNotificationName:(NSString *)beginNotificationName endNotificationName:(NSString *)endNotificationName
{
    NSAssert(beginNotificationName && endNotificationName, @"Notifications required");
    
    if ((self = [super init])) {
        self.view = view;
        
        // Create a gesture recognizer capturing taps on the whole window
        self.gestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard:)] autorelease];
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

- (void)dealloc
{
    self.view = nil;
    self.gestureRecognizer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

#pragma mark UIGestureRecognizerDelegate protocol implementation

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	return ! [touch.view isDescendantOfView:self.view];
}

#pragma mark Notification callbacks

- (void)viewDidBeginEditing:(NSNotification *)notification
{
    [[[UIApplication sharedApplication] keyWindow] addGestureRecognizer:self.gestureRecognizer];
}

- (void)viewDidEndEditing:(NSNotification *)notification
{
    [[[UIApplication sharedApplication] keyWindow] removeGestureRecognizer:self.gestureRecognizer];
}

#pragma mark Event callbacks

- (void)dismissKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.resigningFirstResponderOnTap) {
        [self.view resignFirstResponder];
    }
}

@end
