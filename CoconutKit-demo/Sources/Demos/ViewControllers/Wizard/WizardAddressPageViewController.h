//
//  WizardAddressPageViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 21.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

// Forward declarations
@class Person;

@interface WizardAddressPageViewController : HLSViewController <HLSReloadable, HLSTextFieldValidationDelegate, HLSValidable, UITextFieldDelegate> {
@private
    Person *m_person;
    UILabel *m_streetLabel;
    HLSTextField *m_streetTextField;
    UILabel *m_streetErrorLabel;
    UILabel *m_cityLabel;
    HLSTextField *m_cityTextField;
    UILabel *m_cityErrorLabel;
    UILabel *m_stateLabel;
    HLSTextField *m_stateTextField;
    UILabel *m_stateErrorLabel;
    UILabel *m_countryLabel;
    HLSTextField *m_countryTextField;
    UILabel *m_countryErrorLabel;
    UIButton *m_resetModelButton;
    UIButton *m_resetTextFieldsButton;
}

@property (nonatomic, retain) IBOutlet UILabel *streetLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *streetTextField;
@property (nonatomic, retain) IBOutlet UILabel *streetErrorLabel;
@property (nonatomic, retain) IBOutlet UILabel *cityLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *cityTextField;
@property (nonatomic, retain) IBOutlet UILabel *cityErrorLabel;
@property (nonatomic, retain) IBOutlet UILabel *stateLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *stateTextField;
@property (nonatomic, retain) IBOutlet UILabel *stateErrorLabel;
@property (nonatomic, retain) IBOutlet UILabel *countryLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *countryTextField;
@property (nonatomic, retain) IBOutlet UILabel *countryErrorLabel;
@property (nonatomic, retain) IBOutlet UIButton *resetModelButton;
@property (nonatomic, retain) IBOutlet UIButton *resetTextFieldsButton;

- (IBAction)resetModel:(id)sender;
- (IBAction)resetTextFields:(id)sender;

@end
