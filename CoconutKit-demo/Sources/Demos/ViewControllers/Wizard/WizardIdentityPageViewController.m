//
//  WizardIdentityPageViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/28/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "WizardIdentityPageViewController.h"

#import "Customer.h"

@interface WizardIdentityPageViewController ()

@property (nonatomic, retain) Customer *customer;

- (void)updateViewFromModel;
- (void)updateModelFromView;

@end

@implementation WizardIdentityPageViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super initWithNibName:[self className] bundle:nil])) {
        // Only one customer in the DB. If does not exist yet, create it
        Customer *customer = [Customer customer];
        if (! customer) {
            customer = [Customer insert];
        }
        self.customer = customer;
    }
    return self;
}

- (void)dealloc
{
    self.customer = nil;
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.customerInformationLabel = nil;
    self.firstNameLabel = nil;
    self.firstNameTextField = nil;
    self.lastNameLabel = nil;
    self.lastNameTextField = nil;
    self.emailLabel = nil;
    self.emailTextField = nil;
}

#pragma mark Accessors and mutators

@synthesize customer = m_customer;

@synthesize customerInformationLabel = m_customerInformationLabel;

@synthesize firstNameLabel = m_firstNameLabel;

@synthesize firstNameTextField = m_firstNameTextField;

@synthesize lastNameLabel = m_lastNameLabel;

@synthesize lastNameTextField = m_lastNameTextField;

@synthesize emailLabel = m_emailLabel;

@synthesize emailTextField = m_emailTextField;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
    
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    self.emailTextField.delegate = self;
    
    [self updateViewFromModel];
}

#pragma mark Model synchronization methods

- (void)updateViewFromModel
{
    self.firstNameTextField.text = self.customer.firstName;
    self.lastNameTextField.text = self.customer.lastName;
    self.emailTextField.text = self.customer.email;
}

- (void)updateModelFromView
{
    self.customer.firstName = self.firstNameTextField.text;
    self.customer.lastName = self.lastNameTextField.text;
    self.customer.email = self.emailTextField.text;
}

#pragma mark HLSValidable protocol implementation

- (BOOL)validate
{
    if ([self.firstNameTextField.text length] == 0
            || [self.lastNameTextField.text length] == 0
            || [self.emailTextField.text length] == 0) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                             message:NSLocalizedString(@"All fields are mandatory", @"All fields are mandatory") 
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Dismiss")
                                                   otherButtonTitles:nil]
                                  autorelease];
        [alertView show];
        return NO;
    }
    
    if (! [HLSValidators validateEmailAddress:self.emailTextField.text]) {
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                             message:NSLocalizedString(@"Invalid e-mail address", @"Invalid e-mail address") 
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Dismiss")
                                                   otherButtonTitles:nil]
                                  autorelease];
        [alertView show];
        return NO;        
    }
    
    // All fields valid; save into model object
    [self updateModelFromView];
    
    return YES;
}

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
    
    self.customerInformationLabel.text = NSLocalizedString(@"Customer Information", @"Customer Information");
    self.firstNameLabel.text = NSLocalizedString(@"First Name", @"First Name");
    self.lastNameLabel.text = NSLocalizedString(@"Last Name", @"Last Name");
    self.emailLabel.text = NSLocalizedString(@"E-mail", @"E-mail");
}

@end
