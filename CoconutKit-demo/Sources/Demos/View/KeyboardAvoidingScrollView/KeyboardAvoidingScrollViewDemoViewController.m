//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "KeyboardAvoidingScrollViewDemoViewController.h"

@interface KeyboardAvoidingScrollViewDemoViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *backgroundView;

@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *textFields;

@property (nonatomic, weak) IBOutlet UITextView *textView;

@property (nonatomic, weak) IBOutlet UIView *smallCustomInputView;
@property (nonatomic, weak) IBOutlet UIView *largeCustomInputView;

@end

@implementation KeyboardAvoidingScrollViewDemoViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
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
    [[UIApplication sharedApplication].keyWindow.activeViewController.view endEditing:NO];
}

@end
