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

@property (nonatomic, strong) PersonInformation *personInformation;

@property (nonatomic, weak) IBOutlet UITextField *streetTextField;
@property (nonatomic, weak) IBOutlet UILabel *streetErrorLabel;
@property (nonatomic, weak) IBOutlet UITextField *cityTextField;
@property (nonatomic, weak) IBOutlet UILabel *cityErrorLabel;
@property (nonatomic, weak) IBOutlet UITextField *stateTextField;
@property (nonatomic, weak) IBOutlet UILabel *stateErrorLabel;
@property (nonatomic, weak) IBOutlet UITextField *countryTextField;
@property (nonatomic, weak) IBOutlet UILabel *countryErrorLabel;

@end

@implementation WizardAddressPageViewController

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        // Only one person in the DB. If does not exist yet, create it
        PersonInformation *personInformation = [[PersonInformation allObjects] firstObject];
        if (! personInformation) {
            personInformation = [PersonInformation insert];
        }
        self.personInformation = personInformation;
    }
    return self;
}

#pragma mark Accessors and mutators

- (void)setPersonInformation:(PersonInformation *)personInformation
{
    if (_personInformation == personInformation) {
        return;
    }
    
    _personInformation = personInformation;
    
    [self bindToObject:personInformation];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.streetTextField.delegate = self;
    self.cityTextField.delegate = self;
    self.stateTextField.delegate = self;
    self.countryTextField.delegate = self;
}

#pragma mark HLSValidable protocol implementation

- (BOOL)validate
{    
    return [self checkDisplayedValuesWithError:NULL];
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
    [self checkDisplayedValuesWithError:NULL];
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
