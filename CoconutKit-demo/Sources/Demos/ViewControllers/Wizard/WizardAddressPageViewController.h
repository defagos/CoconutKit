//
//  WizardAddressPageViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 21.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

// Forward declarations
@class Person;

@interface WizardAddressPageViewController : HLSViewController <HLSTextFieldValidationDelegate, HLSValidable, UITextFieldDelegate> {
@private
    Person *_person;
    HLSTextField *_streetTextField;
    UILabel *_streetErrorLabel;
    HLSTextField *_cityTextField;
    UILabel *_cityErrorLabel;
    HLSTextField *_stateTextField;
    UILabel *_stateErrorLabel;
    HLSTextField *_countryTextField;
    UILabel *_countryErrorLabel;
}

@property (nonatomic, retain) IBOutlet HLSTextField *streetTextField;
@property (nonatomic, retain) IBOutlet UILabel *streetErrorLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *cityTextField;
@property (nonatomic, retain) IBOutlet UILabel *cityErrorLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *stateTextField;
@property (nonatomic, retain) IBOutlet UILabel *stateErrorLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *countryTextField;
@property (nonatomic, retain) IBOutlet UILabel *countryErrorLabel;

- (IBAction)resetModel:(id)sender;
- (IBAction)resetTextFields:(id)sender;

@end
