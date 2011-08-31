//
//  TextFieldsDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "TextFieldsDemoViewController.h"

@implementation TextFieldsDemoViewController

#pragma mark Object creation and destruction

- (id)initLarge:(BOOL)large
{
    // The large version is taller than the screen and therefore can be browsed vertically; no demo for horizontal
    // scrolling since issues remain (see HLSTextField documentation)
    if (large) {
        if ((self = [super initWithNibName:@"TextFieldsLargeDemoViewController" bundle:nil])) {
            self.title = @"TextFieldsDemoViewController (large)";
            m_large = YES;
        }
    }
    else {
        if ((self = [super initWithNibName:@"TextFieldsDemoViewController" bundle:nil])) {
            self.title = @"TextFieldsDemoViewController";
            m_large = NO;
        }
    }
    return self;
}

- (id)init
{
    return [self initLarge:NO];
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.instructionLabel = nil;
    self.textField1 = nil;
    self.textField2 = nil;
    self.textField3 = nil;
    self.textField4 = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Large version: Must adjust content size to make the IB-designed view scrollable
    if (m_large) {
        UIScrollView *scrollView = (UIScrollView *)self.view;
        scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 
                                            self.view.frame.size.height);
    }
    
    self.textField1.delegate = self;
    self.textField2.delegate = self;
    self.textField3.delegate = self;
    self.textField4.delegate = self;
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return YES;
}

#pragma mark Accessors and mutators

@synthesize instructionLabel = m_instructionLabel;

@synthesize textField1 = m_textField1;

@synthesize textField2 = m_textField2;

@synthesize textField3 = m_textField3;

@synthesize textField4 = m_textField4;

#pragma mark UITextFieldDelegate protocol implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.instructionLabel.text = NSLocalizedString(@"Alternate between text fields and rotate the device (even with the keyboard displayed) to check that the behavior is correct", 
                                                   @"Alternate between text fields and rotate the device (even with the keyboard displayed) to check that the behavior is correct");
}

@end
