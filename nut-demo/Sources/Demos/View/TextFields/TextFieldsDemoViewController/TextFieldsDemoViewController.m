//
//  TextFieldsDemoViewController.m
//  nut-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 HLSXibView. All rights reserved.
//

#import "TextFieldsDemoViewController.h"

@implementation TextFieldsDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if (self = [super init]) {
        self.title = NSLocalizedString(@"Text fields", @"Text fields");
    }
    return self;
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
    
    self.instructionLabel.text = NSLocalizedString(@"Alternate between text fields and rotate the device (even with the keyboard displayed) to check that the behavior is correct", 
                                                   @"Alternate between text fields and rotate the device (even with the keyboard displayed) to check that the behavior is correct");
    
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

@end
