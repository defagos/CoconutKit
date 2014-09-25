//
//  WizardAddressPageViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 21.10.11.
//  Copyright (c) 2011 Samuel Défago. All rights reserved.
//

#import "WizardAddressPageViewController.h"

#import "PersonInformation.h"

@interface WizardAddressPageViewController ()

@property (nonatomic, retain) PersonInformation *personInformation;

@property (nonatomic, retain) IBOutlet UITextField *streetTextField;
@property (nonatomic, retain) IBOutlet UILabel *streetErrorLabel;
@property (nonatomic, retain) IBOutlet UITextField *cityTextField;
@property (nonatomic, retain) IBOutlet UILabel *cityErrorLabel;
@property (nonatomic, retain) IBOutlet UITextField *stateTextField;
@property (nonatomic, retain) IBOutlet UILabel *stateErrorLabel;
@property (nonatomic, retain) IBOutlet UITextField *countryTextField;
@property (nonatomic, retain) IBOutlet UILabel *countryErrorLabel;

@end

@implementation WizardAddressPageViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super init])) {
        self.personInformation = [[PersonInformation allObjects] firstObject];
        NSAssert(self.personInformation != nil, @"A person must be available");
    }
    return self;
}

- (void)dealloc
{
    self.personInformation = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

- (void)setPersonInformation:(PersonInformation *)personInformation
{
    if (_personInformation == personInformation) {
        return;
    }
    
    [_personInformation release];
    _personInformation = [personInformation retain];
    
    [self reloadData];
}

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
    [self.streetTextField bindToManagedObject:self.personInformation
                                    fieldName:@"street"
                                    formatter:nil
                           validationDelegate:self];
    [self.streetTextField setCheckingOnChange:YES];
    [self.cityTextField bindToManagedObject:self.personInformation
                                  fieldName:@"city"
                                  formatter:nil
                         validationDelegate:self];
    [self.cityTextField setCheckingOnChange:YES];
    [self.stateTextField bindToManagedObject:self.personInformation
                                   fieldName:@"state"
                                   formatter:nil
                          validationDelegate:self];
    [self.stateTextField setCheckingOnChange:YES];
    [self.countryTextField bindToManagedObject:self.personInformation
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
    self.personInformation.street = nil;
    self.personInformation.city = nil;
    self.personInformation.state = nil;
    self.personInformation.country = nil;
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
