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

- (void)setCustomer:(Customer *)customer
{
    if (m_customer == customer) {
        return;
    }
    
    [m_customer release];
    m_customer = [customer retain];
    
    [self reloadData];
}

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
    
    [self reloadData];
}

#pragma mark Model synchronization methods

- (void)updateModelFromView
{
    self.customer.firstName = self.firstNameTextField.text;
    self.customer.lastName = self.lastNameTextField.text;
    self.customer.email = self.emailTextField.text;
}

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{
    // TODO: Sync should really be performed by bound text field itself
    self.firstNameTextField.text = self.customer.firstName;
    [self.firstNameTextField bindToField:@"firstName" managedObject:self.customer validationDelegate:self];
    
    self.lastNameTextField.text = self.customer.lastName;
    self.emailTextField.text = self.customer.email;
}

#pragma mark HLSValidable protocol implementation

- (BOOL)validate
{
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

#pragma mark HLSTextFieldValidationDelegate protocol implementation

- (void)textField:(UITextField *)textField didFailValidationWithError:(NSError *)error
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                         message:[error localizedDescription] 
                                                        delegate:nil 
                                               cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Dismiss")
                                               otherButtonTitles:nil]
                              autorelease];
    [alertView show];
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
