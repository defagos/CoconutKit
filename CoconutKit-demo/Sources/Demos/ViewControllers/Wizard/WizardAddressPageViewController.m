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

- (void)reloadData;

- (UILabel *)errorLabelForTextField:(UITextField *)textField;

@end

@implementation WizardAddressPageViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.person = [[Person allObjects] firstObject_hls];
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
    
    self.streetTextField = nil;
    self.streetErrorLabel = nil;
    self.cityTextField = nil;
    self.cityErrorLabel = nil;
    self.stateTextField = nil;
    self.stateErrorLabel = nil;
    self.countryTextField = nil;
    self.countryErrorLabel = nil;
}

#pragma mark Accessors and mutators

@synthesize person = _person;

- (void)setPerson:(Person *)person
{
    if (_person == person) {
        return;
    }
    
    [_person release];
    _person = [person retain];
    
    [self reloadData];
}

@synthesize streetTextField = _streetTextField;

@synthesize streetErrorLabel = _streetErrorLabel;

@synthesize cityTextField = _cityTextField;

@synthesize cityErrorLabel = _cityErrorLabel;

@synthesize stateTextField = _stateTextField;

@synthesize stateErrorLabel = _stateErrorLabel;

@synthesize countryTextField = _countryTextField;

@synthesize countryErrorLabel = _countryErrorLabel;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.streetTextField.delegate = self;
    self.cityTextField.delegate = self;
    self.stateTextField.delegate = self;
    self.countryTextField.delegate = self;
    
    [self reloadData];
}

#pragma mark HLSValidable protocol implementation

- (BOOL)validate
{    
    return [self checkTextFields];
}

#pragma mark UITextFieldDelegate protocol implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.streetTextField) {
        [self.cityTextField becomeFirstResponder];
    }
    else if (textField == self.cityTextField) {
        [self.stateTextField becomeFirstResponder];
    }
    else if (textField == self.stateTextField) {
        [self.countryTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark HLSTextFieldValidationDelegate protocol implementation

- (void)textFieldDidPassValidation:(UITextField *)textField
{
    textField.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5f];
    
    UILabel *errorLabel = [self errorLabelForTextField:textField];
    errorLabel.text = nil;
}

- (void)textField:(UITextField *)textField didFailValidationWithError:(NSError *)error
{
    textField.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5f];
    
    UILabel *errorLabel = [self errorLabelForTextField:textField];
    errorLabel.text = [error localizedDescription];
}

#pragma mark Updating the view

- (void)reloadData
{
    [self.streetTextField bindToManagedObject:self.person
                                    fieldName:@"street"
                                    formatter:nil
                           validationDelegate:self];
    [self.streetTextField setCheckingOnChange:YES];
    [self.cityTextField bindToManagedObject:self.person
                                  fieldName:@"city"
                                  formatter:nil
                         validationDelegate:self];
    [self.cityTextField setCheckingOnChange:YES];
    [self.stateTextField bindToManagedObject:self.person
                                   fieldName:@"state"
                                   formatter:nil
                          validationDelegate:self];
    [self.stateTextField setCheckingOnChange:YES];
    [self.countryTextField bindToManagedObject:self.person
                                     fieldName:@"country"
                                     formatter:nil
                            validationDelegate:self];
    [self.countryTextField setCheckingOnChange:YES];
    
    // Performs and initial complete validation
    [self checkTextFields];
}

#pragma mark Retrieving the error label associated with a text field

- (UILabel *)errorLabelForTextField:(UITextField *)textField
{
    if (textField == self.streetTextField) {
        return self.streetErrorLabel;
    }
    else if (textField == self.cityTextField) {
        return self.cityErrorLabel;
    }
    else if (textField == self.stateTextField) {
        return self.stateErrorLabel;
    }
    else if (textField == self.countryTextField) {
        return self.countryErrorLabel;
    }
    else {
        HLSLoggerError(@"Unknown text field");
        return nil;
    }
}

#pragma mark Localization

- (void)localize
{
    [super localize];
        
    // Trigger a new validation to get localized error messages if any
    [self checkTextFields];
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
