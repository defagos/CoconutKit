//
//  WizardAddressPageViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 21.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "WizardAddressPageViewController.h"

#import "Person.h"

@interface WizardAddressPageViewController ()

@property (nonatomic, retain) Person *person;

@end

@implementation WizardAddressPageViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super initWithNibName:[self className] bundle:nil])) {
        self.person = [[Person allObjects] firstObject];
        NSAssert(self.person != nil, @"A person must be available");
    }
    return self;
}

- (void)dealloc
{
    self.person = nil;
    
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.streetLabel = nil;
    self.streetTextField = nil;
    self.cityLabel = nil;
    self.cityTextField = nil;
    self.stateLabel = nil;
    self.stateTextField = nil;
    self.countryLabel = nil;
    self.countryTextField = nil;
    self.resetModelButton = nil;
    self.resetTextFieldsButton = nil;
}

#pragma mark Accessors and mutators

@synthesize person = m_person;

- (void)setPerson:(Person *)person
{
    if (m_person == person) {
        return;
    }
    
    [m_person release];
    m_person = [person retain];
    
    [self reloadData];
}

@synthesize streetLabel = m_streetLabel;

@synthesize streetTextField = m_streetTextField;

@synthesize cityLabel = m_cityLabel;

@synthesize cityTextField = m_cityTextField;

@synthesize stateLabel = m_stateLabel;

@synthesize stateTextField = m_stateTextField;

@synthesize countryLabel = m_countryLabel;

@synthesize countryTextField = m_countryTextField;

@synthesize resetModelButton = m_resetModelButton;

@synthesize resetTextFieldsButton = m_resetTextFieldsButton;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
    
    self.streetTextField.delegate = self;
    self.cityTextField.delegate = self;
    self.stateTextField.delegate = self;
    self.countryTextField.delegate = self;
    
    [self reloadData];
}

#pragma mark HLSReloadable protocol implementation

- (void)reloadData
{
    [self.streetTextField bindToManagedObject:self.person 
                                    fieldName:@"street"
                                    formatter:nil 
                           validationDelegate:self];
    [self.cityTextField bindToManagedObject:self.person
                                  fieldName:@"city"
                                  formatter:nil 
                         validationDelegate:self];
    [self.stateTextField bindToManagedObject:self.person 
                                   fieldName:@"state"
                                   formatter:nil 
                          validationDelegate:self];
    [self.countryTextField bindToManagedObject:self.person 
                                     fieldName:@"country"
                                     formatter:nil 
                            validationDelegate:self];
}

#pragma mark HLSValidable protocol implementation

- (BOOL)validate
{    
    return [self checkTextFields];
}

#pragma mark UITextFieldDelegate protocol implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark HLSTextFieldValidationDelegate protocol implementation

- (void)textFieldDidPassValidation:(UITextField *)textField
{
    textField.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5f];
}

- (void)textField:(UITextField *)textField didFailValidationWithError:(NSError *)error
{
    textField.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5f];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.streetLabel.text = NSLocalizedString(@"Street", @"Street");
    self.cityLabel.text = NSLocalizedString(@"City", @"City");
    self.stateLabel.text = NSLocalizedString(@"State", @"State");
    self.countryLabel.text = NSLocalizedString(@"Country", @"Country");
    [self.resetModelButton setTitle:NSLocalizedString(@"Reset model fields", @"Reset model fields") forState:UIControlStateNormal];
    [self.resetTextFieldsButton setTitle:NSLocalizedString(@"Reset text fields", @"Reset text fields") forState:UIControlStateNormal];
}

#pragma mark Event callbacks

- (IBAction)resetModel:(id)sender
{
    // Reset the model programmatically. This shows that the text fields are updated accordingly
    self.person.street = nil;
    self.person.city = nil;
    self.person.state = nil;
    self.person.country = nil;
}

- (IBAction)resetTextFields:(id)sender
{
    // Reset text fields programmatically. This shows that the model is updated accordingly
    self.streetTextField.text = nil;
    self.cityTextField.text = nil;
    self.stateTextField.text = nil;
    self.countryTextField.text = nil;
}

@end
