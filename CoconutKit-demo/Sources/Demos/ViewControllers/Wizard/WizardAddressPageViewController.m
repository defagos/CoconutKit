//
//  WizardAddressPageViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 21.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "WizardAddressPageViewController.h"

#import "Customer.h"

@interface WizardAddressPageViewController ()

@property (nonatomic, retain) Customer *customer;

- (void)updateViewFromModel;
- (void)updateModelFromView;

@end

@implementation WizardAddressPageViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super initWithNibName:[self className] bundle:nil])) {
        self.customer = [Customer customer];
        NSAssert(self.customer != nil, @"A customer must be available");
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
    self.streetLabel = nil;
    self.streetTextField = nil;
    self.cityLabel = nil;
    self.cityTextField = nil;
    self.stateLabel = nil;
    self.stateTextField = nil;
    self.countryLabel = nil;
    self.countryTextField = nil;
}

#pragma mark Accessors and mutators

@synthesize customer = m_customer;

@synthesize customerInformationLabel = m_customerInformationLabel;

@synthesize streetLabel = m_streetLabel;

@synthesize streetTextField = m_streetTextField;

@synthesize cityLabel = m_cityLabel;

@synthesize cityTextField = m_cityTextField;

@synthesize stateLabel = m_stateLabel;

@synthesize stateTextField = m_stateTextField;

@synthesize countryLabel = m_countryLabel;

@synthesize countryTextField = m_countryTextField;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
    
    self.streetTextField.delegate = self;
    self.cityTextField.delegate = self;
    self.stateTextField.delegate = self;
    self.countryTextField.delegate = self;
    
    [self updateViewFromModel];
}

#pragma mark Model synchronization methods

- (void)updateViewFromModel
{
    self.streetTextField.text = self.customer.street;
    self.cityTextField.text = self.customer.city;
    self.stateTextField.text = self.customer.state;
    self.countryTextField.text = self.customer.country;
}

- (void)updateModelFromView
{
    self.customer.street = self.streetTextField.text;
    self.customer.city = self.cityTextField.text;
    self.customer.state = self.stateTextField.text;
    self.customer.country = self.countryTextField.text;
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

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.customerInformationLabel.text = NSLocalizedString(@"Customer Information", @"Customer Information");
    self.streetLabel.text = NSLocalizedString(@"Street", @"Street");
    self.cityLabel.text = NSLocalizedString(@"City", @"City");
    self.stateLabel.text = NSLocalizedString(@"State", @"State");
    self.countryLabel.text = NSLocalizedString(@"Country", @"Country");
}

@end
