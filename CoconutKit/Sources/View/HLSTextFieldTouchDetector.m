//
//  HLSTextFieldTouchDetector.m
//  CoconutKit
//
//  Created by Samuel Défago on 04.12.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "HLSTextFieldTouchDetector.h"

@interface HLSTextFieldTouchDetector ()

@property (nonatomic, assign) UITextField *textField;               // weak ref. Detector lifetime is managed by the text field
@property (nonatomic, retain) UIGestureRecognizer *gestureRecognizer;

@end

@implementation HLSTextFieldTouchDetector

#pragma mark Object creation and destruction

- (id)initWithTextField:(UITextField *)textField
{
    if ((self = [super init])) {
        self.textField = textField;
        
        // Create a gesture recognizer capturing taps on the whole window
        self.gestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard:)] autorelease];
        self.gestureRecognizer.cancelsTouchesInView = NO;       // Let the taps go through
        self.gestureRecognizer.delegate = self;
        
        self.resigningFirstResponderOnTap = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidBeginEditing:)
                                                     name:UITextFieldTextDidBeginEditingNotification
                                                   object:textField];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidEndEditing:)
                                                     name:UITextFieldTextDidEndEditingNotification
                                                   object:textField];
    }
    return self;
}

- (void)dealloc
{
    self.textField = nil;
    self.gestureRecognizer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

#pragma mark UIGestureRecognizerDelegate protocol implementation

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	return ! [touch.view isDescendantOfView:self.textField];
}

#pragma mark Notification callbacks

- (void)textFieldDidBeginEditing:(NSNotification *)notification
{
    [[[UIApplication sharedApplication] keyWindow] addGestureRecognizer:self.gestureRecognizer];
}

- (void)textFieldDidEndEditing:(NSNotification *)notification
{
    [[[UIApplication sharedApplication] keyWindow] removeGestureRecognizer:self.gestureRecognizer];
}

#pragma mark Event callbacks

- (void)dismissKeyboard:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.resigningFirstResponderOnTap) {
        // Dismiss the keyboard
        [self.textField resignFirstResponder];        
    }
}

@end
