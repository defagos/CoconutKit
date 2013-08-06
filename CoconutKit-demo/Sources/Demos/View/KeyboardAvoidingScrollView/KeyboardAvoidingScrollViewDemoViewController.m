//
//  KeyboardAvoidingScrollViewDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "KeyboardAvoidingScrollViewDemoViewController.h"

@interface KeyboardAvoidingScrollViewDemoViewController ()

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *backgroundView;

@property (nonatomic, retain) IBOutletCollection(UITextField) NSArray *textFields;

@property (nonatomic, retain) IBOutlet UITextView *textView;

@property (nonatomic, retain) IBOutlet UIView *smallCustomInputView;
@property (nonatomic, retain) IBOutlet UIView *largeCustomInputView;

@end

@implementation KeyboardAvoidingScrollViewDemoViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.textFields = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // This property could also be conveniently set via user-defined runtime attributes
    self.scrollView.avoidingKeyboard = YES;
    self.textView.avoidingKeyboard = YES;
    
    // Wrapping the text field background view into a scroll view allows us to test that the behavior stays correct
    // in all cases
    [self.scrollView addSubview:self.backgroundView];
    self.scrollView.contentSize = self.backgroundView.bounds.size;
    
    for (UITextField *textField in self.textFields) {
        textField.delegate = self;
    }
    
    UITextField *textField1 = [self.textFields firstObject];
    textField1.resigningFirstResponderOnTap = YES;
    
    UITextField *textField3 = [self.textFields objectAtIndex:2];
    
    // Custom input views
    textField1.inputView = self.smallCustomInputView;
    textField3.inputView = self.largeCustomInputView;
    
    self.textView.resigningFirstResponderOnTap = YES;
}

#pragma mark UITextFieldDelegate protocol implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSUInteger index = [self.textFields indexOfObject:textField];
    if (index < [self.textFields count] - 1) {
        UITextField *nextTextField = [self.textFields objectAtIndex:index + 1];
        [nextTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark Localization

- (void)localize
{
    [super localize];

    self.title = NSLocalizedString(@"Scroll view avoiding the keyboard", nil);
}

#pragma mark Action callbacks

- (IBAction)closeInput:(id)sender
{
    [[[UIApplication sharedApplication] keyWindow].rootViewController.view endEditing:NO];
}

@end
